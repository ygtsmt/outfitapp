import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ginly/app/core/services/revenue_cat_service.dart';

/// Banner reklam widget'ı
/// Sadece aboneliği olmayan kullanıcılara gösterilir
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _hasSubscription = true; // Default: true (gösterilmesin)
  bool _isCheckingSubscription = true;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionAndLoadAd();
  }

  /// Abonelik kontrolü yap ve reklam yükle
  Future<void> _checkSubscriptionAndLoadAd() async {
    try {
      final hasSubscription = await RevenueCatService.isUserSubscribed();
      setState(() {
        _hasSubscription = hasSubscription;
        _isCheckingSubscription = false;
      });

      // Aboneliği yoksa reklam yükle
      if (!hasSubscription) {
        _loadBannerAd();
      }
    } catch (e) {
      debugPrint('❌ Error checking subscription for banner ad: $e');
      setState(() {
        _isCheckingSubscription = false;
        // Hata durumunda reklam gösterme (güvenli taraf)
        _hasSubscription = true;
      });
    }
  }

  /// Banner reklam yükle
  void _loadBannerAd() {
    // Platform-specific ad unit IDs
    final String adUnitId = Platform.isIOS
        ? 'ca-app-pub-9293946059678095/1081621721' // iOS banner ad unit ID
        : 'ca-app-pub-9293946059678095/7188591424'; // Android banner ad unit ID

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
          debugPrint('✅ Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner ad failed to load: ${error.message}');
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
        onAdOpened: (_) {
          debugPrint('📱 Banner ad opened');
        },
        onAdClosed: (_) {
          debugPrint('📱 Banner ad closed');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Abonelik kontrolü yapılıyorsa boş widget dön
    if (_isCheckingSubscription) {
      return const SizedBox.shrink();
    }

    // Aboneliği varsa reklam gösterme
    if (_hasSubscription) {
      return const SizedBox.shrink();
    }

    // Reklam yüklenmediyse boş widget dön
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    // Banner reklamı göster
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: AdSize.banner.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
