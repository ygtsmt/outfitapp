const admin = require('firebase-admin');

/**
 * Videoyu URL'den indir ve Firebase Storage'a yükle
 * @param {string} videoUrl - İndirilecek video URL'i
 * @param {string} taskId - Video task ID'si
 * @returns {Promise<string|null>} - Firebase Storage public URL veya null
 */
async function uploadVideoToFirebase(videoUrl, taskId) {
  try {
    console.log(`📥 Starting download for taskId: ${taskId}`);
    
    const https = require('https');
    const http = require('http');
    
    const protocol = videoUrl.startsWith('https:') ? https : http;
    
    const videoBuffer = await new Promise((resolve, reject) => {
      protocol.get(videoUrl, (response) => {
        if (response.statusCode !== 200) {
          reject(new Error(`Failed to download video: ${response.statusCode}`));
          return;
        }
        
        const chunks = [];
        response.on('data', (chunk) => chunks.push(chunk));
        response.on('end', () => resolve(Buffer.concat(chunks)));
        response.on('error', reject);
      }).on('error', reject);
    });
    
    console.log(`📥 Video downloaded, size: ${videoBuffer.length} bytes`);
    
    // Firebase Storage'a yükle
    const bucket = admin.storage().bucket();
    const fileName = `user_videos/${taskId}/${Date.now()}.mp4`;
    const file = bucket.file(fileName);
    
    await file.save(videoBuffer, {
      metadata: {
        contentType: 'video/mp4',
        metadata: {
          taskId: taskId,
          uploadedAt: new Date().toISOString()
        }
      }
    });
    
    console.log(`📤 Video uploaded to Firebase Storage: ${fileName}`);
    
    // Public URL oluştur
    await file.makePublic();
    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
    
    console.log(`🔗 Public URL created: ${publicUrl}`);
    return publicUrl;
    
  } catch (error) {
    console.error('Error in uploadVideoToFirebase:', error);
    return null;
  }
}

/**
 * Pixverse URL'den videoyu indir ve Firebase Storage'a yükle
 * @param {string} pixverseUrl - Pixverse video URL'i
 * @param {string} userId - Kullanıcı ID'si
 * @param {string} videoId - Video ID'si
 * @returns {Promise<string|null>} - Firebase Storage public URL veya null
 */
async function uploadPixverseVideoToFirebase(pixverseUrl, userId, videoId) {
  try {
    console.log(`📥 Downloading video from Pixverse: ${pixverseUrl}`);
    const axios = require('axios');
    
    // Videoyu indir
    const response = await axios.get(pixverseUrl, {
      responseType: 'arraybuffer',
      timeout: 60000 // 60 saniye timeout
    });
    
    const videoBuffer = Buffer.from(response.data);
    console.log(`✅ Video downloaded, size: ${videoBuffer.length} bytes`);
    
    // Firebase Storage'a yükle
    const bucket = admin.storage().bucket();
    const fileName = `pixverse_videos/${userId}/${videoId}_${Date.now()}.mp4`;
    const file = bucket.file(fileName);
    
    await file.save(videoBuffer, {
      metadata: {
        contentType: 'video/mp4',
        metadata: {
          userId: userId,
          videoId: videoId,
          source: 'pixverse-original',
          uploadedAt: new Date().toISOString()
        }
      }
    });
    
    // Public URL oluştur
    await file.makePublic();
    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
    
    console.log(`✅ Video uploaded to Firebase Storage: ${publicUrl}`);
    return publicUrl;
    
  } catch (error) {
    console.error(`❌ Error uploading video to Firebase Storage:`, error.message);
    throw error;
  }
}

module.exports = {
  uploadVideoToFirebase,
  uploadPixverseVideoToFirebase
};

