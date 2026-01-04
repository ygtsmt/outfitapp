const admin = require('firebase-admin');
const {
  getWeeklyCredits,
  getOneTimePurchaseCredits,
  getCurrentCredits,
  updateCredits,
  addLog,
  addOneTimePurchaseLog,
  getCurrentRefundCount,
  getOneTimePackageName
} = require('./creditManager');

/**
 * Payment Handler Functions
 * RevenueCat webhook event'lerini işler
 */

async function handleInitialPurchase(userRef, productId, entitlementId, webhookData) {
  const event = webhookData.event;
  
  // Haftalık kredileri hesapla (Firebase'den)
  const weeklyCredits = await getWeeklyCredits(productId);
  
  // Kredileri ekle
  await updateCredits(userRef, weeklyCredits, `Initial purchase: ${productId}`);
  
  // Plan adını belirle
  const planName = productId.includes('plus') ? 'Plus' : productId.includes('pro') ? 'Pro' : 'Ultra';
  
  await userRef.set({
    'purchased_info': {
      'current_plan_id': productId,
      'subscription_status': 'active',
      'entitlement_id': entitlementId,
      'subscription_start_date': admin.firestore.FieldValue.serverTimestamp(),
      'last_updated': admin.firestore.FieldValue.serverTimestamp(),
      'weekly_credits': weeklyCredits, // Haftalık kredi miktarı
      'refund_from_store': 0, // Refund counter başlat
      'logs': [], // Log array'i başlat
      'plan_history': [{
        'action': 'initial_purchase',
        'product_id': productId,
        'timestamp': new Date().toISOString(),
        'status': 'active',
        'transaction_id': event.transaction_id,
        'price': event.price,
        'currency': event.currency,
        'country_code': event.country_code,
        'store': event.store,
        'credits_added': weeklyCredits
      }],
      'subscription_details': {
        'product_id': productId,
        'status': 'active',
        'start_date': admin.firestore.FieldValue.serverTimestamp(),
        'auto_renew': true,
        'renewal_number': event.renewal_number || 1,
        'expiration_date': new Date(event.expiration_at_ms),
        'purchase_date': new Date(event.purchased_at_ms)
      }
    },

  }, { merge: true });
  
  // Detaylı log ekle
  const environment = event.environment || 'UNKNOWN';
  await addLog(userRef, `🎉 İlk abonelik başarıyla oluşturuldu! Plan: ${planName}, Haftalık Kredi: ${weeklyCredits}, Fiyat: ${event.price} ${event.currency}, Ülke: ${event.country_code}, Store: ${event.store === 'PLAY_STORE' ? 'Google Play' : 'App Store'}, Environment: ${environment}, Periyot: ${environment === 'SANDBOX' ? 'TEST (Hızlı)' : 'PRODUCTION (1 Hafta)'}`);
  
  console.log('✅ Initial purchase data written to user document');
}

async function handleRenewal(userRef, productId, webhookData) {
  const event = webhookData.event;
  
  // Haftalık kredileri hesapla ve ekle (Firebase'den)
  const weeklyCredits = await getWeeklyCredits(productId);
  await updateCredits(userRef, weeklyCredits, `Weekly renewal: ${productId}`);
  
  // Plan adını belirle
  const planName = productId.includes('plus') ? 'Plus' : productId.includes('pro') ? 'Pro' : 'Ultra';
  
  await userRef.set({
    'purchased_info': {
      'subscription_status': 'active',
      'last_renewal_date': admin.firestore.FieldValue.serverTimestamp(),
      'last_updated': admin.firestore.FieldValue.serverTimestamp(),
      'plan_history': admin.firestore.FieldValue.arrayUnion({
        'action': 'renewal',
        'product_id': productId,
        'timestamp': new Date().toISOString(),
        'status': 'active',
        'transaction_id': event.transaction_id,
        'price': event.price,
        'currency': event.currency,
        'credits_added': weeklyCredits
      }),
      'subscription_details': {
        'status': 'active',
        'last_renewal': admin.firestore.FieldValue.serverTimestamp(),
        'renewal_number': event.renewal_number || 1
      }
    }
  }, { merge: true });
  
  // Detaylı log ekle
  const environment = event.environment || 'UNKNOWN';
  const timeSinceLastRenewal = event.purchased_at_ms ? `(${Math.round((Date.now() - event.purchased_at_ms) / 1000 / 60)} dakika)` : '';
  await addLog(userRef, `🔄 Haftalık yenileme başarılı! Plan: ${planName}, Eklenen Kredi: ${weeklyCredits}, Fiyat: ${event.price} ${event.currency}, Yenileme Sayısı: ${event.renewal_number || 1}, Environment: ${environment}, Periyot: ${environment === 'SANDBOX' ? 'TEST (Hızlı)' : 'PRODUCTION (1 Hafta)'} ${timeSinceLastRenewal}`);
  
  console.log('✅ Renewal data updated in user document');
}

async function handleCancellation(userRef, productId, cancellationReason, webhookData) {
  // Cancellation'da kredi ekleme, sadece status güncelle
  // Mevcut periyot bitene kadar kredi alacak, sonra duracak
  
  await userRef.set({
    'purchased_info': {
      'subscription_status': 'cancelled',
      'cancellation_date': admin.firestore.FieldValue.serverTimestamp(),
      'cancellation_reason': cancellationReason || 'user_cancelled',
      'last_updated': admin.firestore.FieldValue.serverTimestamp(),
      'plan_history': admin.firestore.FieldValue.arrayUnion({
        'action': 'cancellation',
        'product_id': productId,
        'timestamp': new Date().toISOString(),
        'status': 'cancelled',
        'reason': cancellationReason,
        'credits_added': 0 // Cancellation'da kredi eklenmez
      }),
      'subscription_details': {
        'status': 'cancelled'
      }
    }
  }, { merge: true });
  
  // Detaylı log ekle
  const planName = productId.includes('plus') ? 'Plus' : productId.includes('pro') ? 'Pro' : 'Ultra';
  const reasonText = cancellationReason || 'Kullanıcı tarafından iptal edildi';
  await addLog(userRef, `❌ Abonelik iptal edildi! Plan: ${planName}, İptal Sebebi: ${reasonText}, Not: Mevcut periyot bitene kadar kredi almaya devam edeceksiniz`);
  
  console.log('✅ Cancellation data updated in user document - No credits added');
}

async function handleExpiration(userRef, productId, webhookData) {
  // Expiration'da son periyot kredisi eklenmiş, artık ekleme yok
  
  await userRef.set({
    'purchased_info': {
      'subscription_status': 'expired',
      'expiration_date': admin.firestore.FieldValue.serverTimestamp(),
      'last_updated': admin.firestore.FieldValue.serverTimestamp(),
      'plan_history': admin.firestore.FieldValue.arrayUnion({
        'action': 'expiration',
        'product_id': productId,
        'timestamp': new Date().toISOString(),
        'status': 'expired',
        'credits_added': 0 // Expiration'da kredi eklenmez
      }),
      'subscription_details': {
        'status': 'expired'
      }
    }
  }, { merge: true });
  
  console.log('✅ Expiration data updated in user document - No credits added');
}

async function handleRefund(userRef, productId, refundReason, webhookData) {
  // Refund'da akıllı kredi hesaplama
  const weeklyCredits = await getWeeklyCredits(productId);
  const currentCredits = await getCurrentCredits(userRef);
  
  // Harcanmamış kredileri hesapla
  const unusedCredits = Math.min(weeklyCredits, currentCredits);
  
  // Sadece harcanmamış kredileri geri al
  if (unusedCredits > 0) {
    await updateCredits(userRef, -unusedCredits, `Refund: ${productId} - Unused credits removed`);
  }
  
  await userRef.set({
    'purchased_info': {
      'subscription_status': 'refunded',
      'refund_date': admin.firestore.FieldValue.serverTimestamp(),
      'refund_reason': refundReason || 'user_requested',
      'last_updated': admin.firestore.FieldValue.serverTimestamp(),
      'refund_from_store': admin.firestore.FieldValue.increment(1), // Refund counter +1
      'plan_history': admin.firestore.FieldValue.arrayUnion({
        'action': 'refund',
        'product_id': productId,
        'timestamp': new Date().toISOString(),
        'status': 'refunded',
        'reason': refundReason,
        'credits_removed': unusedCredits, // Gerçekte geri alınan kredi
        'total_credits_from_plan': weeklyCredits, // Plandan gelen toplam kredi
        'unused_credits_refunded': unusedCredits, // Geri alınan kullanılmamış kredi
        'spent_credits': weeklyCredits - unusedCredits // Harcanan kredi
      }),
      'subscription_details': {
        'status': 'refunded'
      }
    }
  }, { merge: true });
  
  // Detaylı log ekle
  const planName = productId.includes('plus') ? 'Plus' : productId.includes('pro') ? 'Pro' : 'Ultra';
  const reasonText = refundReason || 'Kullanıcı tarafından talep edildi';
  
  // Mevcut refund counter'ı al
  const currentRefundCount = await getCurrentRefundCount(userRef);
  const newRefundCount = currentRefundCount + 1;
  
  await addLog(userRef, `💰 İade işlemi gerçekleşti! Plan: ${planName}, İade Sebebi: ${reasonText}, Plandan Gelen Kredi: ${weeklyCredits}, Harcanan Kredi: ${weeklyCredits - unusedCredits}, Geri Alınan Kredi: ${unusedCredits}, Toplam İade Sayısı: ${newRefundCount}, Not: Sadece kullanılmamış krediler geri alındı`);
  
  console.log('✅ Refund data updated in user document - Smart credits calculation');
}

async function handleRestoration(userRef, productId, entitlementId, webhookData) {
  // Restoration'da kredileri tekrar ekle
  const weeklyCredits = await getWeeklyCredits(productId);
  await updateCredits(userRef, weeklyCredits, `Restoration: ${productId} - Credits restored`);
  
  // Plan adını belirle
  const planName = productId.includes('plus') ? 'Plus' : productId.includes('pro') ? 'Pro' : 'Ultra';
  
  await userRef.set({
    'purchased_info': {
      'subscription_status': 'active',
      'restoration_date': admin.firestore.FieldValue.serverTimestamp(),
      'last_updated': admin.firestore.FieldValue.serverTimestamp(),
      'plan_history': admin.firestore.FieldValue.arrayUnion({
        'action': 'restoration',
        'product_id': productId,
        'timestamp': new Date().toISOString(),
        'status': 'active',
        'credits_added': weeklyCredits
      }),
      'subscription_details': {
        'status': 'active',
        'restoration_date': admin.firestore.FieldValue.serverTimestamp()
      }
    }
  }, { merge: true });
  
  console.log('✅ Restoration data updated in user document - Credits restored');
}

async function handleTransfer(userRef, productId, webhookData) {
  // Transfer'da kredi ekleme, sadece status güncelle
  await userRef.set({
    'purchased_info': {
      'subscription_status': 'transferred',
      'transfer_date': admin.firestore.FieldValue.serverTimestamp(),
      'last_updated': admin.firestore.FieldValue.serverTimestamp(),
      'plan_history': admin.firestore.FieldValue.arrayUnion({
        'action': 'transfer',
        'product_id': productId,
        'timestamp': new Date().toISOString(),
        'status': 'transferred',
        'credits_added': 0
      }),
      'subscription_details': {
        'status': 'transferred'
      }
    }
  }, { merge: true });
  
  console.log('✅ Transfer data updated in user document - No credits added');
}

async function handleUncancellation(userRef, productId, webhookData) {
  // Uncancellation'da kredileri tekrar ekle
  const weeklyCredits = await getWeeklyCredits(productId);
  await updateCredits(userRef, weeklyCredits, `Uncancellation: ${productId} - Credits restored`);
  
  // Plan adını belirle
  const planName = productId.includes('plus') ? 'Plus' : productId.includes('pro') ? 'Pro' : 'Ultra';
  
  await userRef.set({
    'purchased_info': {
      'subscription_status': 'active',
      'uncancellation_date': admin.firestore.FieldValue.serverTimestamp(),
      'last_updated': admin.firestore.FieldValue.serverTimestamp(),
      'plan_history': admin.firestore.FieldValue.arrayUnion({
        'action': 'uncancellation',
        'product_id': productId,
        'timestamp': new Date().toISOString(),
        'status': 'active',
        'credits_added': weeklyCredits
      }),
      'subscription_details': {
        'status': 'active'
      }
    }
  }, { merge: true });
  
  console.log('✅ Uncancellation data updated in user document - Credits restored');
}

// One-time purchase handler
async function handleOneTimePurchase(userRef, productId, webhookData) {
  const event = webhookData.event;
  
  // One-time purchase kredilerini hesapla (Firebase'den)
  const creditAmount = await getOneTimePurchaseCredits(productId);
  
  // Mevcut kredileri al
  const currentCredits = await getCurrentCredits(userRef);
  const newCredits = currentCredits + creditAmount;
  
  // Kredileri ekle
  await updateCredits(userRef, creditAmount, `One-time purchase: ${productId}`);
  
  // Paket adını belirle
  const packageName = getOneTimePackageName(productId);
  
  const updateData = {
    'one_time_purchases': admin.firestore.FieldValue.arrayUnion({
      'product_id': productId,
      'package_name': packageName,
      'credit_amount': creditAmount,
      'transaction_id': event.transaction_id,
      'purchase_date': new Date(),
      'price': event.price,
      'currency': event.currency,
      'status': 'completed'
    }),
    'profile_info': {
      'lastOneTimePurchase': admin.firestore.FieldValue.serverTimestamp(),
      'totalOneTimePurchases': admin.firestore.FieldValue.increment(1)
    }
  };
  
  // set() with merge: true kullan - user dokümanı yoksa oluşturur
  await userRef.set(updateData, { merge: true });
  
  // One-time purchase için ayrı log sistemi
  const environment = event.environment || 'UNKNOWN';
  await addOneTimePurchaseLog(userRef, `🎁 Tek seferlik kredi paketi satın alındı! Paket: ${packageName}, Önceki Kredi: ${currentCredits}, Eklenen Kredi: ${creditAmount}, Yeni Kredi: ${newCredits}, Fiyat: ${event.price} ${event.currency}, Ülke: ${event.country_code}, Store: ${event.store === 'PLAY_STORE' ? 'Google Play' : 'App Store'}, Environment: ${environment}`);
  
  console.log('✅ One-time purchase data written to user document');
}

// One-time purchase paket adını belirle


module.exports = {
  handleInitialPurchase,
  handleRenewal,
  handleCancellation,
  handleExpiration,
  handleRefund,
  handleRestoration,
  handleTransfer,
  handleUncancellation,
  handleOneTimePurchase
};
