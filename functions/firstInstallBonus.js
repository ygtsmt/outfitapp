const functions = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * First Install Bonus - İlk yüklemede kredi verme
 * Cloud Function (Callable)
 */
exports.claimFirstInstallBonus = functions.https.onCall(async (data, context) => {
  try {
    // 1. Auth kontrolü
    if (!context.auth) {
      console.error('❌ Unauthenticated request for first install bonus');
      throw new functions.https.HttpsError('unauthenticated', 'Kullanıcı girişi gerekli');
    }
    
    const userId = context.auth.uid;
    const deviceId = data.deviceId;
    const authProvider = data.authProvider || 'unknown';
    
    console.log(`🎁 First install bonus request: userId=${userId}, deviceId=${deviceId}, provider=${authProvider}`);
    
    // 2. Parametreleri kontrol et
    if (!deviceId || typeof deviceId !== 'string' || deviceId.length < 10) {
      console.error('❌ Invalid device ID:', deviceId);
      throw new functions.https.HttpsError('invalid-argument', 'Geçersiz cihaz ID');
    }
    
    const db = admin.firestore();
    
    // 3. Kullanıcı kontrolü - BU KULLANICI DAHA ÖNCE ALDI MI?
    const userDoc = await db.collection('users').doc(userId).get();
    const userRef = db.collection('users').doc(userId);
    
    if (userDoc.exists) {
      const userData = userDoc.data();
      const hasUserBonus = userData?.profile_info?.hasReceivedFirstInstallBonus || false;
      if (hasUserBonus) {
        const bonusDate = userData?.profile_info?.firstInstallBonusDate?.toDate();
        const dateStr = bonusDate ? bonusDate.toLocaleDateString('tr-TR') : 'bilinmeyen tarih';
        const logMessage = `İlk yükleme bonusu verilmedi. Bu kullanıcı hesabı daha önce ${dateStr} tarihinde bonus aldı.`;
        
        console.log(`❌ User already received first install bonus: ${userId}`);
        
        // Log'u profile_info'ya yaz
        await userRef.update({
          'profile_info.firstInstallBonusLog': logMessage,
          'profile_info.lastBonusCheckDate': admin.firestore.FieldValue.serverTimestamp()
        });
        
        throw new functions.https.HttpsError('already-exists', logMessage);
      }
    }
    
    // 4. Cihaz kontrolü - BU CİHAZ DAHA ÖNCE KULLANILDI MI?
    const deviceDoc = await db.collection('device_first_install_bonus').doc(deviceId).get();
    if (deviceDoc.exists && deviceDoc.data()?.claimed === true) {
      const deviceData = deviceDoc.data();
      const claimedDate = deviceData?.claimedAt?.toDate();
      const dateStr = claimedDate ? claimedDate.toLocaleDateString('tr-TR') : 'bilinmeyen tarih';
      const claimedByUser = deviceData?.userId || 'başka bir hesap';
      const isSameUser = claimedByUser === userId;
      
      const logMessage = isSameUser 
        ? `İlk yükleme bonusu verilmedi. Bu cihazdan ${dateStr} tarihinde bonus alındı (aynı hesapla).`
        : `İlk yükleme bonusu verilmedi. Bu cihazdan ${dateStr} tarihinde başka bir hesap tarafından bonus alındı.`;
      
      console.log(`❌ Device already used for first install bonus: ${deviceId}`);
      
      // Log'u profile_info'ya yaz
      await userRef.set({
        'profile_info': {
          'firstInstallBonusLog': logMessage,
          'lastBonusCheckDate': admin.firestore.FieldValue.serverTimestamp(),
          'hasReceivedFirstInstallBonus': false
        }
      }, { merge: true });
      
      throw new functions.https.HttpsError('already-exists', logMessage);
    }
    
    // 5. Firebase'den bonus miktarını al
    const creditDoc = await db.collection('generate_credit').doc('credit_campaign').get();
    let bonusAmount = 120; // Default fallback
    
    if (creditDoc.exists && creditDoc.data()) {
      bonusAmount = creditDoc.data().opened_credit_count || 120;
    }
    
    console.log(`💰 First install bonus amount: ${bonusAmount}`);
    
    // 6. Transaction ile atomik işlem
    await db.runTransaction(async (transaction) => {
      // User'a kredi ekle ve flag güncelle
      const logMessage = `İlk yükleme bonusu başarıyla verildi! +${bonusAmount} kredi eklendi. Hoş geldiniz! 🎉`;
      
      transaction.update(userRef, {
        'profile_info.totalCredit': admin.firestore.FieldValue.increment(bonusAmount),
        'profile_info.hasReceivedFirstInstallBonus': true,
        'profile_info.firstInstallBonusDate': admin.firestore.FieldValue.serverTimestamp(),
        'profile_info.firstInstallBonusLog': logMessage,
        'profile_info.lastBonusCheckDate': admin.firestore.FieldValue.serverTimestamp()
      });
      
      // Cihazı işaretle - BU CİHAZ ARTIK KULLANILAMAZ
      const deviceRef = db.collection('device_first_install_bonus').doc(deviceId);
      transaction.set(deviceRef, {
        claimed: true,
        claimedAt: admin.firestore.FieldValue.serverTimestamp(),
        deviceId: deviceId,
        userId: userId,
        authProvider: authProvider,
        creditAmount: bonusAmount,
        userAgent: context.rawRequest?.headers?.['user-agent'] || 'unknown',
        ipAddress: context.rawRequest?.ip || 'unknown'
      });
    });
    
    console.log(`🎉 First install bonus granted: ${userId}, ${bonusAmount} credits`);
    
    const successMessage = `İlk yükleme bonusu başarıyla eklendi! +${bonusAmount} kredi`;
    return {
      success: true,
      creditAmount: bonusAmount,
      message: successMessage
    };
    
  } catch (error) {
    console.error('❌ Error in claimFirstInstallBonus:', error);
    
    // Eğer zaten HttpsError ise, direkt throw et
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    // Diğer hatalar için genel hata mesajı ve log
    const errorMessage = `İlk yükleme bonusu verilmedi. Teknik bir hata oluştu: ${error.message || 'Bilinmeyen hata'}`;
    
    try {
      // Hata durumunda da log yazmayı dene
      const db = admin.firestore();
      const userId = context.auth?.uid;
      if (userId) {
        await db.collection('users').doc(userId).set({
          'profile_info': {
            'firstInstallBonusLog': errorMessage,
            'lastBonusCheckDate': admin.firestore.FieldValue.serverTimestamp(),
            'hasReceivedFirstInstallBonus': false
          }
        }, { merge: true });
      }
    } catch (logError) {
      console.error('❌ Error writing error log:', logError);
    }
    
    throw new functions.https.HttpsError('internal', errorMessage);
  }
});

