const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { uploadVideoToFirebase } = require('../utils/videoUploader');

/**
 * Fal AI Webhook Handler
 * Video generation tamamlandığında webhook'u yakalar
 */
exports.falWebhook = functions.https.onRequest(async (req, res) => {
  // CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  try {
    console.log('🎯 Fal AI Webhook received:', JSON.stringify(req.body, null, 2));
    
    const event = req.body;
    const { request_id, status, payload } = event;

    if (!request_id) {
      console.error('Invalid Fal AI webhook payload - missing request_id');
      res.status(400).send('Invalid webhook payload');
      return;
    }

    console.log(`Fal AI Webhook received: requestId=${request_id}, status=${status}`);

    // Eğer video başarılı olduysa, userGeneratedVideos array'ini güncelle
    if (status === 'OK' && payload) {
      try {
        // Firestore database referansını al
        const db = admin.firestore();
        
        // Webhook'tan video URL'ini al (Fal AI format: payload.video.url)
        let videoUrl = null;
        if (payload && payload.video && payload.video.url) {
          videoUrl = payload.video.url;
          console.log(`Fal AI Video URL from webhook: ${videoUrl}`);
        }
        
        if (videoUrl) {
          console.log(`📥 Downloading Fal AI video from temporary URL: ${videoUrl}`);
          
          try {
            // Videoyu indir ve Firebase Storage'a yükle
            const firebaseUrl = await uploadVideoToFirebase(videoUrl, request_id);
            
            if (firebaseUrl) {
              console.log(`✅ Fal AI Video uploaded to Firebase Storage: ${firebaseUrl}`);
              
              // Tüm kullanıcıları kontrol et ve userGeneratedVideos array'inde video'yu bul
              const usersSnapshot = await db.collection('users').get();
              let videoFound = false;
              
              for (const userDoc of usersSnapshot.docs) {
                const userId = userDoc.id;
                const userData = userDoc.data();
                const userGeneratedVideos = userData?.userGeneratedVideos || [];
                
                // userGeneratedVideos array'inde video'yu bul
                const updatedVideos = userGeneratedVideos.map(video => {
                  if (video.id === request_id) {
                    videoFound = true;
                    console.log(`Found matching Fal AI video for user ${userId}! Updating output from '${video.output}' to '${firebaseUrl}'`);
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
                  console.log(`✅ Successfully updated Fal AI video output in userGeneratedVideos for requestId: ${request_id}, URL: ${firebaseUrl}, User: ${userId}`);
                  
                  // Video bulundu, diğer kullanıcıları kontrol etmeye gerek yok
                  break;
                }
              }
              
              if (!videoFound) {
                console.log(`❌ Fal AI Video not found in any user's userGeneratedVideos array for requestId: ${request_id}`);
              }
            } else {
              console.log(`❌ Failed to upload Fal AI video to Firebase Storage`);
            }
          } catch (uploadError) {
            console.error('Error uploading Fal AI video to Firebase Storage:', uploadError);
          }
        } else {
          console.log(`❌ No video URL found in Fal AI webhook output`);
        }
      } catch (updateError) {
        console.error('Error updating Fal AI userGeneratedVideos:', updateError);
      }
    }
    
    // Eğer video failed olduysa, userGeneratedVideos array'inde status'u güncelle
    if (status === 'ERROR') {
      try {
        console.log(`❌ Fal AI Video failed for requestId: ${request_id}`);
        
        // Firestore database referansını al
        const db = admin.firestore();
        
        // Hata mesajını al (Fal AI format: error field)
        let failMsg = '';
        if (event.error) {
          failMsg = event.error;
        }
        console.log(`Fal AI Fail message: ${failMsg}`);
        
        // Tüm kullanıcıları kontrol et ve userGeneratedVideos array'inde video'yu bul
        const usersSnapshot = await db.collection('users').get();
        let videoFound = false;
        
        for (const userDoc of usersSnapshot.docs) {
          const userId = userDoc.id;
          const userData = userDoc.data();
          const userGeneratedVideos = userData?.userGeneratedVideos || [];
          
          // userGeneratedVideos array'inde video'yu bul
          const updatedVideos = userGeneratedVideos.map(video => {
            if (video.id === request_id) {
              videoFound = true;
              console.log(`Found matching failed Fal AI video for user ${userId}! Updating status to 'failed'`);
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
            console.log(`✅ Successfully updated failed Fal AI video status in userGeneratedVideos for requestId: ${request_id}, User: ${userId}`);
            
            break;
          }
        }
        
        if (!videoFound) {
          console.log(`❌ Failed Fal AI video not found in any user's userGeneratedVideos array for requestId: ${request_id}`);
        }
      } catch (updateError) {
        console.error('Error updating failed Fal AI video status:', updateError);
      }
    }

    res.status(200).send('OK');
  } catch (error) {
    console.error('Fal AI Webhook processing error:', error);
    res.status(500).send('Internal Server Error');
  }
});

