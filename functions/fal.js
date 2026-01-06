const functions = require('firebase-functions');
const admin = require('firebase-admin');

const { uploadCombineImageToFirebase } = require('./combineImageUploader');
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



    if (status === 'OK' && payload) {
      // ===== COMBINE / IMAGE EDIT HANDLING =====
      try {
        const db = admin.firestore();

        // Extract image URL
        let imageUrl = null;
        if (payload && payload.images && payload.images.length > 0) {
          imageUrl = payload.images[0].url;
          console.log(`✅ Combine Image URL found: ${imageUrl}`);
        }

        if (imageUrl) {
          console.log(`📥 Downloading Combine Image from: ${imageUrl}`);

          try {
            // Upload to Firebase Storage
            const firebaseUrl = await uploadCombineImageToFirebase(imageUrl, request_id);

            if (firebaseUrl) {
              console.log(`✅ Combine Image uploaded to Firebase: ${firebaseUrl}`);

              // Check for userId in query params for direct lookup
              const userId = req.query.userId;

              if (userId) {
                console.log(`🔍 Using direct user lookup for userId: ${userId} and requestId: ${request_id}`);

                // Directly reference the subcollection document
                const docRef = db.collection('users')
                  .doc(userId)
                  .collection('combines')
                  .doc(request_id);

                try {
                  await docRef.update({
                    output: [firebaseUrl],
                    status: 'succeeded',
                    completedAt: new Date().toISOString()
                  });
                  console.log(`✅ Request updated in subcollection for user ${userId}`);
                } catch (err) {
                  console.error(`❌ Error updating subcollection doc for user ${userId}:`, err);
                }

              } else {
                console.log('❌ userId missing in webhook URL. Cannot update subcollection.');
              }
            } else {
              console.log(`❌ Failed to get Firebase URL for combine image`);
            }
          } catch (uploadError) {
            console.error('❌ Upload error in combine webhook:', uploadError);
          }
        }
      } catch (imageError) {
        console.error('Error in combine image handling:', imageError);
      }
    }

    // Eğer video failed olduysa, userGeneratedVideos array'inde status'u güncelle


    if (status === 'ERROR') {
      // ===== COMBINE / IMAGE EDIT ERROR HANDLING =====
      try {
        console.log(`❌ Checking if this was a combine request: ${request_id}`);
        const db = admin.firestore();
        const failMsg = event.error || 'Unknown processing error';
        const userId = req.query.userId;

        if (userId) {
          const docRef = db.collection('users')
            .doc(userId)
            .collection('combines')
            .doc(request_id);

          await docRef.update({
            status: 'failed',
            error: failMsg,
            completedAt: new Date().toISOString()
          });
          console.log(`✅ Updated failed status in subcollection for user ${userId}`);
        } else {
          console.log('❌ userId missing in webhook error handler.');
        }

      } catch (imageError) {
        console.error('Error updating failed combine status:', imageError);
      }
    }

    res.status(200).send('OK');
  } catch (error) {
    console.error('Fal AI Webhook processing error:', error);
    res.status(500).send('Internal Server Error');
  }
});

