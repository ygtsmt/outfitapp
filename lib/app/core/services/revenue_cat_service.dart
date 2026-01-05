import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:comby/generated/l10n.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RevenueCatService {
  // 🔑 Platform-specific API keys
  static const String _androidApiKey = 'goog_PfQiIBdbkajdOPOvCtFgXAVVhuQ';
  static const String _iosApiKey = 'appl_iskOhAaeCoaLtHnuQTitucvJCng';

  /// RevenueCat initialize
  static Future<void> initialize() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      final apiKey = Platform.isIOS ? _iosApiKey : _androidApiKey;
      final configuration = PurchasesConfiguration(apiKey);

      await Purchases.configure(configuration);
      debugPrint(
          '✅ RevenueCat (${Platform.isIOS ? "iOS" : "Android"}) initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize RevenueCat: $e');
    }
  }

  /// Satın alma işlemi
  static Future<CustomerInfo?> purchaseProduct(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      log(current?.availablePackages.toString() ??
          AppLocalizations.current.offeringsEmpty);
      log('Aranan Product ID: $productId');

      if (current != null) {
        // Platform'a göre farklı identifier kullan
        final package = current.availablePackages.firstWhere(
          (p) => Platform.isIOS
              ? p.storeProduct.identifier == productId // iOS için
              : p.identifier == productId, // Android için
        );

        log('Bulunan Package: ${package.storeProduct.identifier} - ${package.storeProduct.priceString}');

        // Payment started

        final purchaseResult = await Purchases.purchasePackage(package);

        if (purchaseResult.customerInfo != null) {
          debugPrint('✅ Purchase successful: '
              '${purchaseResult.customerInfo!.entitlements.active}');

          return purchaseResult.customerInfo;
        }
      }

      // Payment cancelled (no package found or null result)
      return null;
    } catch (e) {
      debugPrint('❌ Purchase failed: $e');

      // Payment failed
      return null;
    }
  }

  /// Abonelikleri geri yükleme
  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      debugPrint('✅ Restore successful: ${customerInfo.entitlements.active}');
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Restore failed: $e');
      return false;
    }
  }

  /// Kullanıcı abone mi?
  static Future<bool> isSubscribed() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Failed to check subscription status: $e');
      return false;
    }
  }

  /// Aktif subscription bilgilerini getir
  static Future<Map<String, dynamic>> getActiveSubscriptionInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final activeEntitlements = customerInfo.entitlements.active;

      if (activeEntitlements.isNotEmpty) {
        final firstEntitlement = activeEntitlements.values.first;
        return {
          'hasActiveSubscription': true,
          'productId': firstEntitlement.productIdentifier,
          'expiresDate': firstEntitlement.expirationDate?.toString(),
          'willRenew': firstEntitlement.willRenew,
        };
      }

      return {
        'hasActiveSubscription': false,
        'productId': null,
        'expiresDate': null,
        'willRenew': false,
      };
    } catch (e) {
      debugPrint('❌ Failed to get subscription info: $e');
      return {
        'hasActiveSubscription': false,
        'productId': null,
        'expiresDate': null,
        'willRenew': false,
      };
    }
  }

  /// Ürün detaylarını getir
  static Future<Map<String, String>> getProductDetails(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      log(offerings.toString());
      if (offerings.current == null) {
        return {};
      }

      final packages = offerings.current!.availablePackages;
      log('Aranan Product ID: $productId');

      // Platform'a göre farklı identifier kullan
      final package = packages.firstWhere(
        (p) => Platform.isIOS
            ? p.storeProduct.identifier == productId // iOS için
            : p.identifier == productId, // Android için
      );

      final storeProduct = package.storeProduct;
      log('Bulunan Package: ${package.storeProduct.identifier} - ${package.storeProduct.priceString}');

      return {
        'title': storeProduct.title,
        'price': storeProduct.priceString,
        'currency': storeProduct.currencyCode,
        'duration': storeProduct.subscriptionPeriod ?? '',
      };
    } catch (e) {
      debugPrint('❌ Failed to get product details: $e');
      return {};
    }
  }

  /// Dinamik plan fiyatı
  static Future<String> getDynamicPlanPrice(String productId) async {
    final details = await getProductDetails(productId);
    return details['price'] ?? AppLocalizations.current.loading;
  }

  /// Dinamik plan başlığı
  static Future<String> getDynamicPlanTitle(String productId) async {
    final details = await getProductDetails(productId);
    return details['title'] ?? AppLocalizations.current.loading;
  }

  /// Firebase User ID ile RevenueCat'i eşleştir
  static Future<void> syncWithFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await Purchases.logIn(user.uid);
        debugPrint('✅ RevenueCat synced with Firebase User ID: ${user.uid}');
      } else {
        debugPrint('⚠️ No Firebase user found, cannot sync RevenueCat');
      }
    } catch (e) {
      debugPrint('❌ Failed to sync RevenueCat with Firebase: $e');
    }
  }

  /// Mevcut RevenueCat user ID
  static Future<String?> getCurrentUserId() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.originalAppUserId;
    } catch (e) {
      debugPrint('❌ Failed to get RevenueCat user ID: $e');
      return null;
    }
  }

  /// One-time purchase için product ID'leri (Platform bağımsız)
  static List<String> getOneTimeProductIds() {
    return [
      'ginly_extra_credit',
      'ginly_boost_credit',
      'ginly_mega_credit',
    ];
  }

  /// One-time product satın alma
  static Future<CustomerInfo?> purchaseOneTimeProduct(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      if (current != null) {
        // One-time products için özel offering
        final oneTimeOffering = offerings.all['credit_packages'];
        if (oneTimeOffering != null) {
          final package = oneTimeOffering.availablePackages.firstWhere(
            (p) => p.storeProduct.identifier == productId,
          );

          debugPrint(
              '✅ One-time product found: ${package.storeProduct.identifier}');

          final purchaseResult = await Purchases.purchasePackage(package);
          if (purchaseResult.customerInfo != null) {
            debugPrint(
                '✅ One-time purchase successful: ${purchaseResult.customerInfo!.entitlements.active}');
            return purchaseResult.customerInfo;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('❌ One-time purchase failed: $e');
      return null;
    }
  }

  /// One-time product detaylarını getir
  static Future<Map<String, dynamic>> getOneTimeProductDetails(
      String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final oneTimeOffering = offerings.all['credit_packages'];

      if (oneTimeOffering == null) {
        return {};
      }

      final packages = oneTimeOffering.availablePackages;
      final package = packages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
      );

      final storeProduct = package.storeProduct;
      final creditAmount = _getCreditAmountFromProductId(productId);

      return {
        'title': storeProduct.title,
        'price': storeProduct.priceString,
        'currency': storeProduct.currencyCode,
        'creditAmount': creditAmount,
        'productId': productId,
        'packageName': _getPackageNameFromProductId(productId),
      };
    } catch (e) {
      debugPrint('❌ Failed to get one-time product details: $e');
      return {};
    }
  }

  /// Product ID'den kredi miktarını çıkar
  static int _getCreditAmountFromProductId(String productId) {
    if (productId.contains('extra')) return 150; // Extra: 150 kredi
    if (productId.contains('boost')) return 300; // Boost: 300 kredi
    if (productId.contains('mega')) return 600; // Mega: 600 kredi
    return 0;
  }

  /// Product ID'den paket adını çıkar
  static String _getPackageNameFromProductId(String productId) {
    if (productId.contains('extra')) return 'Comby AI Extra';
    if (productId.contains('boost')) return 'Comby AI Boost';
    if (productId.contains('mega')) return 'Comby AI Mega';
    return 'Unknown Package';
  }

  /// Kullanıcı abone mi kontrol et
  static Future<bool> isUserSubscribed() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Failed to check subscription status: $e');
      return false;
    }
  }
}
