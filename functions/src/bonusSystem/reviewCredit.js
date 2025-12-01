const functions = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * Review Completion - Yorum yapma flag'i
 * Artık kredi vermiyor, sadece review yapıldığını işaretliyor
 * 
 * ⚠️ ÖNEMLI: Bu sistem SADECE iOS İÇİN AKTİF
 * Android: Play Store politikası gereği review karşılığında teşvik YASAK
 * iOS: App Store politikası review teşvikine izin veriyor
 * 
 * Free kullanıcılar (sadece iOS) 2. video için review gerekli
 * Cloud Function (Callable)
 */
exports.claimReviewCredit = functions.https.onCall(async (data, context) => {
  try {
    // 1. Auth kontrolü
    if (!context.auth) {
      console.error('❌ Unauthenticated request for review credit');
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı girişi gerekli');
    }
    
    const userId = context.auth.uid;
    const deviceId = data.deviceId;
    const rating = data.rating;
    
    console.log(`⭐ Review credit request: userId=${userId}, deviceId=${deviceId}, rating=${rating}`);
    
    // 2. Parametreleri kontrol et
    if (!deviceId || typeof deviceId !== 'string' || deviceId.length < 10) {
      console.error('❌ Invalid device ID:', deviceId);
      throw new functions.https.HttpsError('invalid-argument', 'Geçersiz cihaz ID');
    }
    
    if (!rating || typeof rating !== 'number' || rating < 1 || rating > 5) {
      console.error('❌ Invalid rating:', rating);
      throw new functions.https.HttpsError('invalid-argument', 'Geçersiz rating değeri');
    }
    
    const db = admin.firestore();
    
    // 3. Kullanıcı kontrolü - BU KULLANICI DAHA ÖNCE ALDI MI?
    const userDoc = await db.collection('users').doc(userId).get();
    if (userDoc.exists) {
      const userData = userDoc.data();
      const hasReviewCredit = userData?.profile_info?.hasReceivedReviewCredit || false;
      if (hasReviewCredit) {
        console.log(`❌ User already received review credit: ${userId}`);
        throw new functions.https.HttpsError('already-exists', 'Bu kullanıcı daha önce review kredisi aldı');
      }
    }
    
    // 4. Cihaz kontrolü - BU CİHAZ DAHA ÖNCE KULLANILDI MI?
    const deviceDoc = await db.collection('device_review_credits').doc(deviceId).get();
    if (deviceDoc.exists && deviceDoc.data()?.claimed === true) {
      console.log(`❌ Device already used for review credit: ${deviceId}`);
      throw new functions.https.HttpsError('already-exists', 'Bu cihazdan daha önce review kredisi alındı');
    }
    
    // 5. Transaction ile atomik işlem
    // ⚠️ ARTIK KREDİ VERMİYORUZ - Sadece flag işaretliyoruz
    await db.runTransaction(async (transaction) => {
      // User'da sadece review yapıldı flag'ini işaretle (KREDİ YOK)
      const userRef = db.collection('users').doc(userId);
      transaction.update(userRef, {
        'profile_info.hasReceivedReviewCredit': true,
        'profile_info.reviewCreditDate': admin.firestore.FieldValue.serverTimestamp(),
        'profile_info.reviewRating': rating
      });
      
      // Cihazı işaretle - BU CİHAZ ARTIK KULLANILAMAZ
      const deviceRef = db.collection('device_review_credits').doc(deviceId);
      transaction.set(deviceRef, {
        claimed: true,
        claimedAt: admin.firestore.FieldValue.serverTimestamp(),
        deviceId: deviceId,
        userId: userId,
        userEmail: context.auth.token.email || 'unknown',
        creditAmount: 0, // ⚠️ Artık kredi verilmiyor
        rating: rating,
        userAgent: context.rawRequest?.headers?.['user-agent'] || 'unknown',
        ipAddress: context.rawRequest?.ip || 'unknown'
      });
    });
    
    console.log(`✅ Review completed (no credit): ${userId}`);
    
    return {
      success: true,
      creditAmount: 0, // ⚠️ Artık kredi yok
      message: 'Review tamamlandı! Artık 2. videoyu oluşturabilirsiniz.'
    };
    
  } catch (error) {
    console.error('❌ Error in claimReviewCredit:', error);
    
    // Eğer zaten HttpsError ise, direkt throw et
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    // Diğer hatalar için genel hata mesajı
    throw new functions.https.HttpsError('internal', 'Review kredisi eklenirken hata oluştu');
  }
});

