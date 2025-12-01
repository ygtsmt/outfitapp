const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');
const { uploadVideoToFirebase } = require('../utils/videoUploader');

/**
 * Pollo Webhook Handler
 * Video generation tamamlandığında webhook'u yakalar
 */
exports.polloWebhook = functions.https.onRequest(async (req, res) => {
  // CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type, X-Webhook-Id, X-Webhook-Timestamp, X-Webhook-Signature');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  try {
    // Webhook headers'ı al
    const webhookId = req.headers['x-webhook-id'];
    const webhookTimestamp = req.headers['x-webhook-timestamp'];
    const signature = req.headers['x-webhook-signature'];

    if (!webhookId || !webhookTimestamp || !signature) {
      console.error('Missing webhook headers');
      res.status(400).send('Missing webhook headers');
      return;
    }

    // Webhook secret'ı environment variable'dan al
    const secret = functions.config().pollo?.webhook_secret;
    if (!secret) {
      console.error('Webhook secret not configured');
      res.status(500).send('Webhook secret not configured');
      return;
    }

    // Request body'yi al
    const body = JSON.stringify(req.body);
    
    // Signature'ı doğrula
    const signedContent = `${webhookId}.${webhookTimestamp}.${body}`;
    const secretBytes = Buffer.from(secret, 'base64');
    const computedSignature = crypto
      .createHmac('sha256', secretBytes)
      .update(signedContent)
      .digest('base64');

    // Signature'ları karşılaştır (timing-safe comparison)
    if (!crypto.timingSafeEqual(
      Buffer.from(signature, 'base64'),
      Buffer.from(computedSignature, 'base64')
    )) {
      console.error('Invalid webhook signature');
      res.status(401).send('Invalid signature');
      return;
    }

    // Webhook data'sını parse et
    const event = req.body;
    const { taskId, status } = event;

    if (!taskId || !status) {
      console.error('Invalid webhook payload');
      res.status(400).send('Invalid webhook payload');
      return;
    }

    console.log(`Webhook received: taskId=${taskId}, status=${status}`);

    // Eğer video başarılı olduysa, userGeneratedVideos array'ini güncelle
    if (status === 'succeed') {
      try {
        // Firestore database referansını al
        const db = admin.firestore();
        
        // Webhook'tan video URL'ini al
        let videoUrl = null;
        if (event.generations && event.generations.length > 0) {
          const generation = event.generations[0];
          if (generation.url && generation.url.length > 0) {
            videoUrl = generation.url;
            console.log(`Video URL from webhook: ${videoUrl}`);
          }
        }
        
        if (videoUrl) {
          console.log(`📥 Downloading video from temporary URL: ${videoUrl}`);
          
          try {
            // Videoyu indir ve Firebase Storage'a yükle
            const firebaseUrl = await uploadVideoToFirebase(videoUrl, taskId);
            
            if (firebaseUrl) {
              console.log(`✅ Video uploaded to Firebase Storage: ${firebaseUrl}`);
              
              // Tüm kullanıcıları kontrol et ve userGeneratedVideos array'inde video'yu bul
              const usersSnapshot = await db.collection('users').get();
              let videoFound = false;
              
              for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                const userData = userDoc.data();
                const userGeneratedVideos = userData?.userGeneratedVideos || [];
                
                // userGeneratedVideos array'inde video'yu bul
                const updatedVideos = userGeneratedVideos.map(video => {
                  if (video.id === taskId) {
                    videoFound = true;
                    console.log(`Found matching video for user ${userId}! Updating output from '${video.output}' to '${firebaseUrl}'`);
                    return {
                      ...video,
                      output: firebaseUrl, // Firebase Storage URL'i kullan
                      status: 'succeeded',
                      completedAt: new Date().toISOString()
                    };
                  }
                  return video;
                });
                
                if (videoFound) {
                  // Firebase'i güncelle
                  await db.collection('users').doc(userId).update({
                    userGeneratedVideos: updatedVideos,
                    lastVideoUpdate: new Date().toISOString() // Library update trigger
                  });
                  console.log(`✅ Successfully updated video output in userGeneratedVideos for taskId: ${taskId}, URL: ${firebaseUrl}, User: ${userId}`);
                  
                  // Video bulundu, diğer kullanıcıları kontrol etmeye gerek yok
                  break;
                }
              }
              
              if (!videoFound) {
                console.log(`❌ Video not found in any user's userGeneratedVideos array for taskId: ${taskId}`);
              }
            } else {
              console.log(`❌ Failed to upload video to Firebase Storage`);
            }
          } catch (uploadError) {
            console.error('Error uploading video to Firebase Storage:', uploadError);
          }
        } else {
          console.log(`❌ No video URL found in webhook generations`);
        }
      } catch (updateError) {
        console.error('Error updating userGeneratedVideos:', updateError);
      }
    }
    
    // Eğer video failed olduysa, userGeneratedVideos array'inde status'u güncelle
    if (status === 'failed') {
      try {
        console.log(`❌ Video failed for taskId: ${taskId}`);
        
        // Firestore database referansını al
        const db = admin.firestore();
        
        // Hata mesajını al (yeni format: result array)
        let failMsg = '';
        if (event.result && event.result.length > 0) {
          failMsg = event.result[0].failMsg || '';
        }
        console.log(`Fail message: ${failMsg}`);
        
        // Tüm kullanıcıları kontrol et ve userGeneratedVideos array'inde video'yu bul
        const usersSnapshot = await db.collection('users').get();
        let videoFound = false;
        
        for (const userDoc of usersSnapshot.docs) {
          const userId = userDoc.id;
          const userData = userDoc.data();
          const userGeneratedVideos = userData?.userGeneratedVideos || [];
          
          // userGeneratedVideos array'inde video'yu bul
          const updatedVideos = userGeneratedVideos.map(video => {
            if (video.id === taskId) {
              videoFound = true;
              console.log(`Found matching failed video for user ${userId}! Updating status to 'failed'`);
              return {
                ...video,
                status: 'failed',
                error: failMsg, // Hata mesajını ekle
                completedAt: new Date().toISOString()
              };
            }
            return video;
          });
          
          if (videoFound) {
            // Firebase'i güncelle
            await db.collection('users').doc(userId).update({
              userGeneratedVideos: updatedVideos,
              lastVideoUpdate: new Date().toISOString() // Library update trigger
            });
            console.log(`✅ Successfully updated failed video status in userGeneratedVideos for taskId: ${taskId}, User: ${userId}`);
            
            break;
          }
        }
        
        if (!videoFound) {
          console.log(`❌ Failed video not found in any user's userGeneratedVideos array for taskId: ${taskId}`);
        }
      } catch (updateError) {
        console.error('Error updating failed video status:', updateError);
      }
    }

    res.status(200).send('OK');
  } catch (error) {
    console.error('Webhook processing error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Webhook secret'ı set etmek için helper function
exports.setWebhookSecret = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  try {
    const { secret } = req.body;
    if (!secret) {
      res.status(400).send('Secret is required');
      return;
    }

    // Webhook secret'ı set et
    await functions.config().set({
      pollo: {
        webhook_secret: secret
      }
    });

    res.status(200).send('Webhook secret configured successfully');
  } catch (error) {
    console.error('Error setting webhook secret:', error);
    res.status(500).send('Error setting webhook secret');
  }
});

