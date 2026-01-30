const admin = require('firebase-admin');

// Initialize Firebase Admin
if (admin.apps.length === 0) {
    admin.initializeApp();
}

// Dosyalar aynı dizinde olduğu için yollar sadeleşti
const { falWebhook } = require('./fal');
const { revenueCatWebhook } = require('./revenuecat');
const { claimFirstInstallBonus } = require('./firstInstallBonus');
const { claimReviewCredit } = require('./reviewCredit');

// ===== EXPORT ALL FUNCTIONS =====

// Webhook'lar
exports.falWebhook = falWebhook;
exports.revenueCatWebhook = revenueCatWebhook;

// Bonus Sistemi
exports.claimFirstInstallBonus = claimFirstInstallBonus;
exports.claimReviewCredit = claimReviewCredit;

// Marathon Agent (Background)
const { checkActiveMissions } = require('./marathonAgent');
exports.checkActiveMissions = checkActiveMissions;