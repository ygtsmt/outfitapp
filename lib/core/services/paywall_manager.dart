import 'package:ginly/app/core/services/revenue_cat_service.dart';

/// Paywall gösterim yöneticisi
/// Session başına (app restart) sadece 1 kez paywall gösterir
class PaywallManager {
  // Singleton pattern
  static final PaywallManager _instance = PaywallManager._internal();
  factory PaywallManager() => _instance;
  PaywallManager._internal();

  // Bu session'da paywall gösterildi mi?
  bool _hasShownPaywallThisSession = false;

  /// Paywall gösterilmeli mi kontrol et
  ///
  /// Returns true if:
  /// - Bu session'da daha önce gösterilmemiş
  /// - Kullanıcının aktif aboneliği yok
  Future<bool> shouldShowPaywall() async {
    // Bu session'da zaten gösterildiyse tekrar gösterme
    if (_hasShownPaywallThisSession) {
      return false;
    }

    // Abonelik kontrolü
    try {
      final hasSubscription = await RevenueCatService.isUserSubscribed();

      // Aboneliği varsa gösterme
      if (hasSubscription) {
        return false;
      }

      // Aboneliği yok ve bu session'da gösterilmemiş -> göster!
      return true;
    } catch (e) {
      // Hata durumunda gösterme (güvenli taraf)
      return false;
    }
  }

  /// Paywall gösterildi olarak işaretle
  void markAsShown() {
    _hasShownPaywallThisSession = true;
  }

  /// Session'ı sıfırla (test için - production'da kullanma)
  void resetSession() {
    _hasShownPaywallThisSession = false;
  }
}
