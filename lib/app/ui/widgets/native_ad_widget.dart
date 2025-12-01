import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ginly/app/core/services/revenue_cat_service.dart';

/// Native Advanced reklam widget'ı
/// Video card gibi görünecek şekilde tasarlandı
class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _hasSubscription = true; // Default: true (gösterilmesin)
  bool _isCheckingSubscription = true;
  LoadAdError? _adError;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionAndLoadAd();
  }

  /// Abonelik kontrolü yap ve reklam yükle
  Future<void> _checkSubscriptionAndLoadAd() async {
    try {
      debugPrint('🔍 [NativeAd] Checking subscription...');
      final hasSubscription = await RevenueCatService.isUserSubscribed();
      debugPrint('🔍 [NativeAd] Has subscription: $hasSubscription');
      setState(() {
        _hasSubscription = hasSubscription;
        _isCheckingSubscription = false;
      });

      // Aboneliği yoksa reklam yükle
      if (!hasSubscription) {
        debugPrint('🔍 [NativeAd] No subscription, loading ad...');
        _loadNativeAd();
      } else {
        debugPrint('🔍 [NativeAd] User has subscription, skipping ad');
      }
    } catch (e) {
      debugPrint('❌ [NativeAd] Error checking subscription: $e');
      setState(() {
        _isCheckingSubscription = false;
        // Hata durumunda reklam gösterme (güvenli taraf)
        _hasSubscription = true;
      });
    }
  }

  /// Native Advanced reklam yükle
  void _loadNativeAd() {
    // Platform-specific ad unit IDs
    final String adUnitId = Platform.isIOS
        ? 'ca-app-pub-9293946059678095/2917447573' // iOS native ad unit ID
        : 'ca-app-pub-9293946059678095/8473752936'; // Android native ad unit ID

    debugPrint('🔍 [NativeAd] Loading ad with unit ID: $adUnitId');

    // Native template style - video card gibi görünmesi için medium template kullan
    final nativeTemplateStyle = NativeTemplateStyle(
      templateType: TemplateType.medium,
      mainBackgroundColor: Colors.white,
      cornerRadius: 12.0,
    );

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: nativeTemplateStyle,
      listener: NativeAdListener(
        onAdLoaded: (_) {
          debugPrint('✅ [NativeAd] Ad loaded successfully');
          setState(() {
            _isAdLoaded = true;
            _adError = null;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ [NativeAd] Ad failed to load: ${error.message}');
          debugPrint('❌ [NativeAd] Error code: ${error.code}');
          debugPrint('❌ [NativeAd] Error domain: ${error.domain}');
          debugPrint('❌ [NativeAd] Response info: ${error.responseInfo}');
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
            _adError = error;
          });
        },
        onAdOpened: (_) {
          debugPrint('📱 [NativeAd] Ad opened');
        },
        onAdClosed: (_) {
          debugPrint('📱 [NativeAd] Ad closed');
        },
        onAdImpression: (_) {
          debugPrint('👁️ [NativeAd] Ad impression recorded');
        },
      ),
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Abonelik kontrolü yapılıyorsa loading göster
    if (_isCheckingSubscription) {
      return AspectRatio(
        aspectRatio: 1.2,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    // Aboneliği varsa reklam gösterme
    if (_hasSubscription) {
      return const SizedBox.shrink();
    }

    // Hata varsa göster
    if (_adError != null) {
      debugPrint('⚠️ [NativeAd] Showing error state: ${_adError!.message}');
      return AspectRatio(
        aspectRatio: 1.2,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.grey,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  'Ad Error',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Reklam yükleniyorsa loading göster
    if (!_isAdLoaded || _nativeAd == null) {
      return AspectRatio(
        aspectRatio: 1.2,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    // Native reklamı video card gibi göster
    debugPrint('✅ [NativeAd] Rendering ad widget');
    return AspectRatio(
      aspectRatio: 1.2,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AdWidget(ad: _nativeAd!),
        ),
      ),
    );
  }
}
