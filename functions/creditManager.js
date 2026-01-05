const admin = require('firebase-admin');

/**
 * Firebase'den plan bilgilerini çek
 */
async function getPlanFromFirebase(productId) {
  try {
    const planDoc = await admin.firestore().collection('plans').doc(productId).get();
    if (planDoc.exists) {
      const planData = planDoc.data();
      return {
        purchasedCredit: planData.purchased_credit || 0,
        benefits: planData.benefits || {}
      };
    }
    return null;
  } catch (error) {
    console.error('❌ Error getting plan from Firebase:', error);
    return null;
  }
}

/**
 * Plan tipine göre haftalık kredi hesapla (Firebase'den)
 */
async function getWeeklyCredits(productId) {
  const plan = await getPlanFromFirebase(productId);
  if (plan && plan.purchasedCredit > 0) {
    return plan.purchasedCredit;
  }
  
  console.error(`❌ Plan not found in Firebase: ${productId}`);
  return 0;
}

/**
 * One-time purchase için kredi hesapla (Firebase'den)
 */
async function getOneTimePurchaseCredits(productId) {
  const plan = await getPlanFromFirebase(productId);
  if (plan && plan.purchasedCredit > 0) {
    return plan.purchasedCredit;
  }
  
  console.error(`❌ One-time plan not found in Firebase: ${productId}`);
  return 0;
}

/**
 * Kullanıcının mevcut kredilerini al
 */
async function getCurrentCredits(userRef) {
  try {
    const userDoc = await userRef.get();
    if (userDoc.exists) {
      const profileInfo = userDoc.data()?.profile_info;
      return profileInfo?.totalCredit || 0;
    }
    return 0;
  } catch (error) {
    console.error('❌ Error getting current credits:', error);
    return 0;
  }
}

/**
 * Kredileri güncelle
 */
async function updateCredits(userRef, creditChange, reason) {
  try {
    const currentCredits = await getCurrentCredits(userRef);
    const newCredits = Math.max(0, currentCredits + creditChange);
    
    // set() with merge: true + dot notation - diğer fieldlara dokunmaz
    await userRef.set({
      'profile_info.totalCredit': newCredits,
      'profile_info.lastCreditUpdate': admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });
    
    console.log(`✅ Credits updated: ${currentCredits} → ${newCredits} (${reason})`);
    return newCredits;
  } catch (error) {
    console.error('❌ Error updating credits:', error);
    throw error;
  }
}

/**
 * Log ekleme helper function
 */
async function addLog(userRef, logMessage) {
  try {
    const timestamp = new Date().toLocaleString('tr-TR', {
      timeZone: 'Europe/Istanbul',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
    
    const fullLogMessage = `[${timestamp}] ${logMessage}`;
    
    // set() with merge: true + dot notation - diğer fieldlara dokunmaz
    await userRef.set({
      'purchased_info.logs': admin.firestore.FieldValue.arrayUnion(fullLogMessage)
    }, { merge: true });
    
    console.log(`📝 Log added: ${fullLogMessage}`);
  } catch (error) {
    console.error('❌ Error adding log:', error);
  }
}

/**
 * One-time purchase log ekleme helper function
 */
async function addOneTimePurchaseLog(userRef, logMessage) {
  try {
    const timestamp = new Date().toLocaleString('tr-TR', {
      timeZone: 'Europe/Istanbul',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    });
    
    const fullLogMessage = `[${timestamp}] ${logMessage}`;
    
    // set() with merge: true + dot notation - top-level field
    await userRef.set({
      'one_time_purchased_logs': admin.firestore.FieldValue.arrayUnion(fullLogMessage)
    }, { merge: true });
    
    console.log(`📝 One-time purchase log added: ${fullLogMessage}`);
  } catch (error) {
    console.error('❌ Error adding one-time purchase log:', error);
  }
}

/**
 * Mevcut refund counter'ı al
 */
async function getCurrentRefundCount(userRef) {
  try {
    const userDoc = await userRef.get();
    if (userDoc.exists) {
      const purchasedInfo = userDoc.data()?.purchased_info;
      return purchasedInfo?.refund_from_store || 0;
    }
    return 0;
  } catch (error) {
    console.error('❌ Error getting refund count:', error);
    return 0;
  }
}

/**
 * One-time purchase paket adını belirle
 */
function getOneTimePackageName(productId) {
  if (productId.includes('extra')) return 'Comby AI Extra';
  if (productId.includes('boost')) return 'Comby AI Boost';
  if (productId.includes('mega')) return 'Comby AI Mega';
  return 'Unknown Package';
}

module.exports = {
  getPlanFromFirebase,
  getWeeklyCredits,
  getOneTimePurchaseCredits,
  getCurrentCredits,
  updateCredits,
  addLog,
  addOneTimePurchaseLog,
  getCurrentRefundCount,
  getOneTimePackageName
};

