import "dart:async";
import "dart:io";
import "package:auto_route/auto_route.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:ginfit/app/bloc/app_bloc.dart";
import "package:ginfit/app/features/auth/features/splash/bloc/splash_bloc.dart";
import "package:ginfit/app/ui/widgets/ginly_logo.dart";
import "package:ginfit/core/core.dart";
import "package:ginfit/core/services/language_service.dart";
import "package:ginfit/core/services/theme_service.dart";
import "package:ginfit/app/core/services/revenue_cat_service.dart";
import "package:ginfit/generated/l10n.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:photo_manager/photo_manager.dart";
import "package:url_launcher/url_launcher.dart";

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
      getIt<AppBloc>().add(const GetAllAppDocumentsEvent());
      getIt<AppBloc>().add(const GetPlansEvent());

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

      // 🔒 FORCE UPDATE KONTROLÜ
      if (mounted && await _checkForceUpdate()) {
        // Force update gerekiyorsa, dialog göster ve uygulamayı durdur
        return;
      }

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

  /// Force Update kontrolü yapar
  /// Returns: true ise force update gerekiyor (dialog gösterildi), false ise güncelleme yok
  Future<bool> _checkForceUpdate() async {
    try {
      // 💎 Premium/Abonelik kontrolü - Aboneleri ASLA zorunlu güncellemeye tabi tutma
      final hasSubscription = await RevenueCatService.isUserSubscribed();
      if (hasSubscription) {
        debugPrint('💎 Kullanıcı aboneliğe sahip - Force update atlanıyor');
        return false;
      }

      // AppBloc'dan version bilgilerini al
      final appBloc = context.read<AppBloc>();
      final forceUpdate = appBloc.state.forceUpdate;
      final currentVersionAndroid = appBloc.state.currentVersionAndroid;
      final currentVersionIOS = appBloc.state.currentVersionIOS;

      // Force update false ise kontrol yapma
      if (!forceUpdate) {
        debugPrint('✅ Force update: false - Güncelleme gerekmiyor');
        return false;
      }

      // Web platformunda force update yok
      if (kIsWeb) {
        debugPrint('ℹ️ Web platformu - Force update atlanıyor');
        return false;
      }

      // Kullanıcının app versiyonunu al
      final packageInfo = await PackageInfo.fromPlatform();
      final currentAppVersion = packageInfo.version;

      // Platform'a göre Firebase version'ı belirle
      String? firebaseVersion;
      if (Platform.isAndroid) {
        firebaseVersion = currentVersionAndroid;
      } else if (Platform.isIOS) {
        firebaseVersion = currentVersionIOS;
      }

      // Firebase'de version yoksa kontrol yapma
      if (firebaseVersion == null || firebaseVersion.isEmpty) {
        debugPrint('ℹ️ Firebase version boş - Force update atlanıyor');
        return false;
      }

      // Version karşılaştırması yap
      final comparison = _compareVersions(currentAppVersion, firebaseVersion);

      // Eğer kullanıcının versiyonu düşükse force update dialog göster
      if (comparison < 0) {
        debugPrint('🔒 FORCE UPDATE GEREKLİ!');
        debugPrint('  📱 Kullanıcı versiyonu: $currentAppVersion');
        debugPrint('  🔥 Firebase versiyonu: $firebaseVersion');

        if (mounted) {
          await _showForceUpdateDialog();
        }
        return true;
      } else {
        debugPrint(
            '✅ App versiyonu güncel ($currentAppVersion >= $firebaseVersion)');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Force update kontrolünde hata: $e');
      // Hata durumunda false dön (uygulamayı bloklamayalım)
      return false;
    }
  }

  /// Version karşılaştırma fonksiyonu
  /// Returns:
  /// - Negatif: version1 < version2 (güncelleme gerekli)
  /// - 0: version1 == version2
  /// - Pozitif: version1 > version2
  int _compareVersions(String version1, String version2) {
    final v1Parts =
        version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts =
        version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength =
        v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;

    for (int i = 0; i < maxLength; i++) {
      final v1 = i < v1Parts.length ? v1Parts[i] : 0;
      final v2 = i < v2Parts.length ? v2Parts[i] : 0;

      if (v1 != v2) {
        return v1 - v2;
      }
    }

    return 0;
  }

  /// Force Update dialog'unu göster
  Future<void> _showForceUpdateDialog() async {
    // Store URL'lerini belirle
    final storeUrl = Platform.isIOS
        ? 'https://apps.apple.com/us/app/ginfit.ai-ai-video-effects/id6749809985' // iOS App Store
        : 'https://play.google.com/store/apps/details?id=com.ginfit.ai.outfit.generator.fitcheck'; // Android Play Store

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog kapatılamaz
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Back button ile kapatılamaz
          child: AlertDialog(
            title: Row(
              children: [
                Icon(Icons.system_update,
                    color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).forceUpdateTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).forceUpdateMessage,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).forceUpdateInfo,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(storeUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: Text(
                  AppLocalizations.of(context).updateButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
