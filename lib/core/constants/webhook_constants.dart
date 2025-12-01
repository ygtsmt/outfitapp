class WebhookConstants {
  // Firebase Functions webhook URL'i
  // Bu URL'i Firebase project'inize göre güncelleyin
  static const String polloWebhookUrl =
      'https://us-central1-disciplify-26970.cloudfunctions.net/polloWebhook';

  // Development için local webhook URL'i (opsiyonel)
  static const String localWebhookUrl =
      'https://us-central1-disciplify-26970.cloudfunctions.net/polloWebhook';

  // Production webhook URL'i
  static String get webhookUrl {
    // Burada environment'a göre URL seçebilirsiniz
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? polloWebhookUrl : localWebhookUrl;
  }
}
