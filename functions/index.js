/**
 * Firebase Cloud Functions - Main Export File
 * Modüler yapıda organize edilmiş fonksiyonları export eder
 * 
 * Klasör Yapısı:
 * - src/webhooks/         : Webhook handlers (Pollo, Fal AI, RevenueCat)
 * - src/bonusSystem/      : Bonus credit system (First Install, Review)
 * - src/videoProcessing/  : Video processing (Pixverse polling, Upload)
 * - src/payment/          : Payment processing (Handlers, Credit manager)
 * - src/utils/            : Utility functions (Video uploader, Helpers)
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

// Initialize Firebase Admin (sadece bir kere)
admin.initializeApp();

// ===== WEBHOOKS =====
const { polloWebhook, setWebhookSecret } = require('./src/webhooks/pollo');
const { falWebhook } = require('./src/webhooks/fal');
const { revenueCatWebhook } = require('./src/webhooks/revenuecat');

// ===== BONUS SYSTEM =====
const { claimFirstInstallBonus } = require('./src/bonusSystem/firstInstallBonus');
const { claimReviewCredit } = require('./src/bonusSystem/reviewCredit');

// ===== VIDEO PROCESSING =====
const { checkPendingPixverseVideos } = require('./src/videoProcessing/pixversePolling');

// ===== EXPORT ALL FUNCTIONS =====

// Webhook'lar
exports.polloWebhook = polloWebhook;
exports.setWebhookSecret = setWebhookSecret;
exports.falWebhook = falWebhook;
exports.revenueCatWebhook = revenueCatWebhook;

// Bonus Sistemi
exports.claimFirstInstallBonus = claimFirstInstallBonus;
exports.claimReviewCredit = claimReviewCredit;

// Video Processing
exports.checkPendingPixverseVideos = checkPendingPixverseVideos;

// Yeni fonksiyonlar eklendiğinde buraya ekleyin
