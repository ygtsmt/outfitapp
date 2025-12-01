const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { uploadPixverseVideoToFirebase } = require('../utils/videoUploader');

/**
 * Pixverse Original API Polling
 * Her 2 dakikada bir pending videoları kontrol eder
 */
exports.checkPendingPixverseVideos = functions.pubsub
  .schedule('every 2 minutes')
  .onRun(async (context) => {
    try {
      console.log('🔍 Checking pending Pixverse Original videos...');
      
      const db = admin.firestore();
      const axios = require('axios');
      
      // Pixverse API key'i environment variable'dan al
      const pixverseApiKey = functions.config().pixverse?.apikey;
      if (!pixverseApiKey) {
        console.error('❌ Pixverse API key not configured');
        return null;
      }
      
      // Sadece pending videoları olan kullanıcıları kontrol et
      const usersSnapshot = await db.collection('users')
        .where('hasPendingVideos', '==', true)
        .get();
      
      // Eğer hiç pending video yoksa, tüm kullanıcıları kontrol et (fallback)
      if (usersSnapshot.empty) {
        console.log('📭 No users with pending videos flag, checking all users...');
        const allUsersSnapshot = await db.collection('users').get();
        let totalPendingVideos = 0;
        let totalCheckedVideos = 0;
        let totalCompletedVideos = 0;
        
        for (const userDoc of allUsersSnapshot.docs) {
          const userId = userDoc.id;
          const userData = userDoc.data();
          const videos = userData.userGeneratedVideos || [];
          
          // Processing statusundeki Pixverse Original videoları filtrele
          const pendingVideos = videos.filter(v =>
            v.model === 'pixverse-original-4.5' &&
            v.status === 'processing' &&
            (v.output === null || v.output === '') &&
            v.id != null &&
            v.trace_id != null
          );
          
          if (pendingVideos.length === 0) continue;
          
          totalPendingVideos += pendingVideos.length;
          console.log(`📋 User ${userId}: Found ${pendingVideos.length} pending videos`);
          
          // Her pending video için status check
          for (const video of pendingVideos) {
            const videoId = video.id;
            const traceId = video.trace_id;
            
            try {
              totalCheckedVideos++;
              console.log(`🔍 Checking video ${videoId} for user ${userId}`);
              
              // Pixverse API'ye status check
              const response = await axios.get(
                `https://app-api.pixverse.ai/openapi/v2/video/result/${videoId}`,
                {
                  headers: {
                    'API-KEY': pixverseApiKey,
                    'Ai-trace-id': traceId
                  }
                }
              );
              
              if (response.status === 200 && response.data.ErrCode === 0) {
                const resp = response.data.Resp;
                
                // Status: 0 = processing, 1 = succeeded, 2 = failed
                if (resp.status === 1 && resp.url) {
                  // ✅ Video başarılı
                  console.log(`✅ Video ${videoId} completed! URL: ${resp.url}`);
                  
                  // Videoyu Firebase Storage'a yükle
                  const firebaseUrl = await uploadPixverseVideoToFirebase(resp.url, userId, videoId);
                  
                  if (firebaseUrl) {
                    const updatedVideos = videos.map(v => {
                      if (v.id === videoId) {
                        return {
                          ...v,
                          output: firebaseUrl,
                          status: 'succeeded',
                          completedAt: new Date().toISOString()
                        };
                      }
                      return v;
                    });
                    
                    await db.collection('users').doc(userId).update({
                      userGeneratedVideos: updatedVideos,
                      lastVideoUpdate: new Date().toISOString(),
                      hasPendingVideos: false // Pending video yok artık
                    });
                    
                    totalCompletedVideos++;
                    console.log(`💾 Completed video ${videoId} updated in Firebase for user ${userId}`);
                  }
                  
                } else if (resp.status === 2) {
                  // ❌ Video başarısız
                  console.log(`❌ Video ${videoId} failed!`);
                  
                  const updatedVideos = videos.map(v => {
                    if (v.id === videoId) {
                      return {
                        ...v,
                        status: 'failed',
                        error: 'Video generation failed',
                        completedAt: new Date().toISOString()
                      };
                    }
                    return v;
                  });
                  
                  await db.collection('users').doc(userId).update({
                    userGeneratedVideos: updatedVideos,
                    lastVideoUpdate: new Date().toISOString(),
                    hasPendingVideos: false // Pending video yok artık
                  });
                  
                  console.log(`💾 Failed video ${videoId} updated in Firebase for user ${userId}`);
                  
                } else {
                  // ⏳ Hala processing
                  console.log(`⏳ Video ${videoId} still processing (status: ${resp.status})`);
                }
              }
              
            } catch (error) {
              console.error(`⚠️ Error checking video ${videoId}:`, error.message);
              // Continue with next video
            }
          }
        }
        
        console.log(`✅ Fallback polling completed! Pending: ${totalPendingVideos}, Checked: ${totalCheckedVideos}, Completed: ${totalCompletedVideos}`);
        return null;
      }
      
      let totalPendingVideos = 0;
      let totalCheckedVideos = 0;
      let totalCompletedVideos = 0;
      
      for (const userDoc of usersSnapshot.docs) {
        const userId = userDoc.id;
        const userData = userDoc.data();
        const videos = userData.userGeneratedVideos || [];
        
            // Processing statusundeki Pixverse Original videoları filtrele
            const pendingVideos = videos.filter(v =>
              v.model === 'pixverse-original-4.5' &&
              v.status === 'processing' &&
              (v.output === null || v.output === '') &&
              v.id != null &&
              v.trace_id != null
            );
        
        if (pendingVideos.length === 0) continue;
        
        totalPendingVideos += pendingVideos.length;
        console.log(`📋 User ${userId}: Found ${pendingVideos.length} pending videos`);
        
            // Her pending video için status check
            for (const video of pendingVideos) {
              const videoId = video.id;
              const traceId = video.trace_id;
          
          try {
            totalCheckedVideos++;
            console.log(`🔍 Checking video ${videoId} for user ${userId}`);
            
            // Pixverse API'ye status check
            const response = await axios.get(
              `https://app-api.pixverse.ai/openapi/v2/video/result/${videoId}`,
              {
                headers: {
                  'API-KEY': pixverseApiKey,
                  'Ai-trace-id': traceId
                }
              }
            );
            
            if (response.status === 200 && response.data.ErrCode === 0) {
              const resp = response.data.Resp;
              
              // Status: 0 = processing, 1 = succeeded, 2 = failed
              if (resp.status === 1 && resp.url) {
                // ✅ Video tamamlandı!
                console.log(`✅ Video ${videoId} completed! Pixverse URL: ${resp.url}`);
                totalCompletedVideos++;
                
                // Pixverse URL'den videoyu Firebase Storage'a yükle
                let firebaseUrl;
                try {
                  firebaseUrl = await uploadPixverseVideoToFirebase(resp.url, userId, videoId);
                  console.log(`✅ Video uploaded to Firebase Storage: ${firebaseUrl}`);
                } catch (uploadError) {
                  console.error(`⚠️ Failed to upload to Firebase Storage, using Pixverse URL: ${uploadError.message}`);
                  firebaseUrl = resp.url; // Fallback to Pixverse URL
                }
                
                // Firebase'i güncelle
                const updatedVideos = videos.map(v => {
                  if (v.id === videoId) {
                    return {
                      ...v,
                      status: 'succeeded',
                      output: firebaseUrl,
                      pixverseUrl: resp.url, // Orijinal URL'i de sakla
                      completedAt: new Date().toISOString()
                    };
                  }
                  return v;
                });
                
                await db.collection('users').doc(userId).update({
                  userGeneratedVideos: updatedVideos,
                  lastVideoUpdate: new Date().toISOString(),
                  hasPendingVideos: false // Pending video yok artık
                });
                
                console.log(`💾 Video ${videoId} updated in Firebase for user ${userId}`);
                
              } else if (resp.status === 2) {
                // ❌ Video başarısız
                console.log(`❌ Video ${videoId} failed!`);
                
                const updatedVideos = videos.map(v => {
                  if (v.id === videoId) {
                    return {
                      ...v,
                      status: 'failed',
                      error: 'Video generation failed',
                      completedAt: new Date().toISOString()
                    };
                  }
                  return v;
                });
                
                await db.collection('users').doc(userId).update({
                  userGeneratedVideos: updatedVideos,
                  lastVideoUpdate: new Date().toISOString(),
                  hasPendingVideos: false // Pending video yok artık
                });
                
                console.log(`💾 Failed video ${videoId} updated in Firebase for user ${userId}`);
                
              } else {
                // ⏳ Hala processing
                console.log(`⏳ Video ${videoId} still processing (status: ${resp.status})`);
              }
            }
            
          } catch (error) {
            console.error(`⚠️ Error checking video ${videoId}:`, error.message);
            // Continue with next video
          }
        }
      }
      
      console.log(`✅ Polling completed! Pending: ${totalPendingVideos}, Checked: ${totalCheckedVideos}, Completed: ${totalCompletedVideos}`);
      return null;
      
    } catch (error) {
      console.error('❌ Error in checkPendingPixverseVideos:', error);
      return null;
    }
  });
