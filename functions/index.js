const admin = require('firebase-admin');

// Initialize Firebase Admin
if (admin.apps.length === 0) {
    admin.initializeApp();
}

// Dosyalar aynı dizinde olduğu için yollar sadeleşti
const { falWebhook } = require('./fal');

// ===== EXPORT ALL FUNCTIONS =====

// Webhook'lar
exports.falWebhook = falWebhook;

// Marathon Agent (Background)
const { checkActiveMissions } = require('./marathonAgent');
exports.checkActiveMissions = checkActiveMissions;