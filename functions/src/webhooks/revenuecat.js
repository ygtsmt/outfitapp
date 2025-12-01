const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {
  handleInitialPurchase,
  handleRenewal,
  handleCancellation,
  handleExpiration,
  handleRefund,
  handleRestoration,
  handleTransfer,
  handleUncancellation,
  handleOneTimePurchase
} = require('../payment/paymentHandlers');

/**
 * RevenueCat Payment System
 * Direct Webhook Processing (Cloud Tasks kaldırıldı)
 */

/**
 * RevenueCat Webhook Handler
 */
exports.revenueCatWebhook = functions.https.onRequest(async (req, res) => {
  // CORS headers
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  try {
    console.log('🔔 RevenueCat Webhook received:', req.body);
    
    // RevenueCat test event'leri için özel handling
    let eventData = req.body;
    
    // Eğer test event ise, event objesi içinden al
    if (req.body.event && req.body.event.type === 'TEST') {
      eventData = {
        event_type: 'TEST_INITIAL_PURCHASE', // Test için özel event type
        app_user_id: req.body.event.app_user_id,
        product_id: req.body.event.product_id,
        entitlement_id: null,
        cancellation_reason: null,
        refund_reason: null
      };
      console.log('🧪 Test event detected, using event data');
    } else {
      // Normal webhook event
      eventData = {
        event_type: req.body.event_type || req.body.event?.type,
        app_user_id: req.body.app_user_id || req.body.event?.app_user_id,
        product_id: req.body.product_id || req.body.event?.product_id,
        entitlement_id: req.body.entitlement_id || req.body.event?.entitlement_id,
        cancellation_reason: req.body.cancellation_reason,
        refund_reason: req.body.refund_reason
      };
    }

    // Gerekli alanları kontrol et
    if (!eventData.app_user_id || !eventData.event_type || !eventData.product_id) {
      console.error('❌ Missing required fields:', req.body);
      return res.status(400).json({ 
        error: 'Missing required fields',
        required: ['app_user_id', 'event_type', 'product_id'],
        received: eventData
      });
    }

    // 🔥 DİREKT PROCESSING - Cloud Tasks kullanmadan direkt işle
    const result = await _processPaymentEvent({
      userId: eventData.app_user_id,
      eventType: eventData.event_type,
      productId: eventData.product_id,
      entitlementId: eventData.entitlement_id,
      cancellationReason: eventData.cancellation_reason,
      refundReason: eventData.refund_reason,
      timestamp: Date.now(),
      webhookData: req.body
    });

    console.log('✅ Payment processed successfully:', result);

    // Başarılı response
    res.status(200).json({ 
      success: true, 
      message: 'Payment processed successfully',
      result: result,
      eventType: eventData.event_type,
      userId: eventData.app_user_id
    });

  } catch (error) {
    console.error('❌ Webhook processing error:', error);
    
    // Error response
    res.status(500).json({ 
      error: 'Failed to process webhook',
      details: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Ana payment processing logic - User payment data yazıyor
async function _processPaymentEvent(eventData) {
  const { 
    userId, 
    eventType, 
    productId, 
    entitlementId, 
    cancellationReason, 
    refundReason,
    webhookData 
  } = eventData;
  
  console.log(`📝 Processing ${eventType} for user ${userId}, product ${productId}`);
  console.log(`📊 Event data:`, eventData);
  
  try {
    // User dokümanına payment bilgilerini yaz
    const userRef = admin.firestore().collection('users').doc(userId);
    
    // Event type'a göre farklı işlemler
    switch (eventType) {
      case 'INITIAL_PURCHASE':
      case 'TEST_INITIAL_PURCHASE':
        await handleInitialPurchase(userRef, productId, entitlementId, webhookData);
        break;
        
      case 'RENEWAL':
        await handleRenewal(userRef, productId, webhookData);
        break;
        
      case 'CANCELLATION':
        await handleCancellation(userRef, productId, cancellationReason, webhookData);
        break;
        
      case 'EXPIRATION':
        await handleExpiration(userRef, productId, webhookData);
        break;
        
      case 'REFUND':
        await handleRefund(userRef, productId, refundReason, webhookData);
        break;
        
      case 'TRANSFER':
        await handleTransfer(userRef, productId, webhookData);
        break;
        
      case 'PRODUCT_CHANGE':
      case 'RESTORATION':
        await handleRestoration(userRef, productId, entitlementId, webhookData);
        break;
        
      case 'UNCANCELLATION':
        await handleUncancellation(userRef, productId, webhookData);
        break;
        
      // One-time purchase event'leri
      case 'NON_RENEWING_PURCHASE':
      case 'ONE_TIME_PURCHASE':
        await handleOneTimePurchase(userRef, productId, webhookData);
        break;
        
      default:
        console.log(`⚠️ Unknown event type: ${eventType}, only logging`);
        return { 
          status: 'unknown_event', 
          eventType, 
          userId, 
          productId,
          message: 'Unknown event type, only logged'
        };
    }
    
    console.log(`✅ Payment data written to Firestore for ${eventType}`);
    return { 
      status: 'payment_data_written', 
      eventType, 
      userId, 
      productId,
      message: 'Payment data written to user document'
    };
    
  } catch (error) {
    console.error('❌ Error writing payment data:', error);
    throw error;
  }
}
