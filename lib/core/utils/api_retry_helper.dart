import 'dart:async';
import 'dart:developer';

/// Hackathon için basit retry helper
/// API çağrılarında geçici hatalar için otomatik retry yapar
class ApiRetryHelper {
  /// API çağrısını retry ile çalıştırır
  /// [operation] - Çalıştırılacak async fonksiyon
  /// [maxRetries] - Maksimum retry sayısı (default: 2)
  /// [delay] - Retry arası bekleme süresi (default: 1 saniye)
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 2,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    
    while (attempt <= maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;
        
        // Son deneme de başarısız olduysa hatayı fırlat
        if (attempt > maxRetries) {
          log('❌ API call failed after $maxRetries retries: $e');
          rethrow;
        }
        
        // Rate limit hatası ise daha uzun bekle
        final errorStr = e.toString().toLowerCase();
        final waitTime = (errorStr.contains('429') || errorStr.contains('rate limit'))
            ? delay * 3  // Rate limit için 3x bekle
            : delay;
        
        log('⚠️ API call failed (attempt $attempt/$maxRetries), retrying in ${waitTime.inSeconds}s...');
        await Future.delayed(waitTime);
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}
