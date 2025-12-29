import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

import "package:ginfit/app/features/auth/features/splash/bloc/splash_bloc.dart";
import "package:ginfit/app/ui/widgets/ginly_logo.dart";
import "package:ginfit/core/core.dart";
import "package:ginfit/core/services/language_service.dart";
import "package:ginfit/core/services/theme_service.dart";
import "package:ginfit/app/core/services/revenue_cat_service.dart";
import "package:ginfit/generated/l10n.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";

import "package:photo_manager/photo_manager.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      // Progress: 10% - Başlangıç
      _updateProgress(0.1);

      // Bloc ile gerekli dataları çek (asenkron, await etme)

      // Progress: 30% - Bloc işlemleri başladı
      _updateProgress(0.3);

      // BEST PRACTICE: Paralel çalıştır
      try {
        await Future.wait([
          // Kritik işlemler - hızlı
          getIt<ThemeService>().setSavedThemeMode(),
          getIt<LanguageService>().setSavedLanuage(),

          // Ağır işlemler - hata kontrolü ile
          MobileAds.instance.initialize().catchError((e) {
            debugPrint("MobileAds error: $e");
            return InitializationStatus({});
          }),
          RevenueCatService.initialize().catchError((e) {
            debugPrint("RevenueCat error: $e");
          }),
        ]);

        // Progress güncellemeleri
        _updateProgress(0.5);

        // Fotoğraf erişim izni iste (tam erişim)
        _updateProgress(0.6);
        await _requestPhotoPermission();

        _updateProgress(0.7);

        _updateProgress(0.85);

        _updateProgress(0.95);
      } catch (e) {
        debugPrint("Init error: $e");
        // Hata olsa bile devam et
      }

      // Progress: 100% - Tamamlandı
      _updateProgress(1.0);

      // Login durumunu kontrol et
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 🔥 RevenueCat'i Firebase User ID ile sync et
        await RevenueCatService.syncWithFirebase();

        if (mounted) {
          context.router.replace(const HomeScreenRoute());
        }
      } else {
        if (mounted) {
          context.router.replace(const LoginScreenRoute());
        }
      }
    } catch (e) {
      // Genel hata yakalama
      debugPrint("Fatal splash error: $e");

      // Hata olsa bile login ekranına yönlendir
      if (mounted) {
        context.router.replace(const LoginScreenRoute());
      }
    }
  }

  void _updateProgress(double progress) {
    if (mounted) {
      setState(() {
        _progress = progress;
      });
    }
  }

  /// Fotoğraf erişim izni ister (tam erişim)
  Future<void> _requestPhotoPermission() async {
    try {
      if (kIsWeb) return; // Web platformunda izin kontrolü yok

      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      // İzin durumu kontrol edilir, ancak uygulama akışını engellemez
      debugPrint("Photo permission state: ${ps.toString()}");
    } catch (e) {
      debugPrint("Photo permission request error: $e");
      // Hata olsa bile devam et
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        // İleride ekstra yönlendirmeler buradan yapılabilir
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Text('GINLY AI',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Futura',
                      color: context.baseColor)),
              SizedBox(height: 16.h),

              SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: GinlyLogo(haveText: false)),
              SizedBox(height: 40.h),

              // App Name

              // Subtitle

              // Loading Bar
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 4.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.r),
                  color: Colors.grey[200],
                ),
                child: Stack(
                  children: [
                    // Background
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.r),
                        color: Colors.grey[200],
                      ),
                    ),
                    // Progress Bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      width:
                          MediaQuery.of(context).size.width * 0.8 * _progress,
                      height: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.r),
                          color: context.baseColor),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Loading Text
              Text(
                _getLoadingText(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 12.sp,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLoadingText() {
    final l10n = AppLocalizations.of(context);

    if (_progress < 0.3) return l10n.initializing;
    if (_progress < 0.5) return l10n.loadingThemes;
    if (_progress < 0.7) return l10n.settingLanguage;
    if (_progress < 0.85) return l10n.loadingAds;
    if (_progress < 0.95) return l10n.configuringPayments;
    if (_progress < 1.0) return l10n.almostReady;
    return l10n.ready;
  }
}
