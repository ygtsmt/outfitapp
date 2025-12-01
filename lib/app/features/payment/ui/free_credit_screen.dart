import 'dart:ffi';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginly/app/ui/widgets/total_credit_widget.dart';
import 'package:ginly/app/ui/widgets/rating_dialog.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class FreeCreditScreen extends StatefulWidget {
  const FreeCreditScreen({super.key});

  @override
  State<FreeCreditScreen> createState() => _FreeCreditScreenState();
}

class _FreeCreditScreenState extends State<FreeCreditScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  static const _storage = FlutterSecureStorage();
  static const _deviceIdKey = 'unique_device_fingerprint';

  /// Benzersiz cihaz ID'si al veya oluştur
  Future<String> _getDeviceId() async {
    try {
      // 1. Önce storage'da var mı kontrol et
      final storedId = await _storage.read(key: _deviceIdKey);
      if (storedId != null && storedId.isNotEmpty) {
        return storedId;
      }

      // 2. Yoksa yeni oluştur
      final deviceInfo = DeviceInfoPlugin();
      String deviceFingerprint;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final androidId = androidInfo.id ?? 'unknown';
        final model = androidInfo.model ?? 'unknown';
        final brand = androidInfo.brand ?? 'unknown';
        // UUID kaldırıldı - sadece cihaz bilgisi kullan (her seferinde aynı olacak)
        deviceFingerprint = 'android_${androidId}_${brand}_$model';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final idfv = iosInfo.identifierForVendor ?? 'unknown';
        final model = iosInfo.model ?? 'unknown';
        // UUID kaldırıldı - sadece IDFV kullan (her seferinde aynı olacak)
        deviceFingerprint = 'ios_${idfv}_$model';
      } else {
        final uniqueId = const Uuid().v4();
        deviceFingerprint = 'unknown_$uniqueId';
      }

      // 3. Storage'a kaydet
      await _storage.write(key: _deviceIdKey, value: deviceFingerprint);
      return deviceFingerprint;
    } catch (e) {
      debugPrint('❌ Error getting device ID: $e');
      final fallbackId =
          'fallback_${const Uuid().v4()}_${DateTime.now().millisecondsSinceEpoch}';
      try {
        await _storage.write(key: _deviceIdKey, value: fallbackId);
      } catch (_) {}
      return fallbackId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.logoutStatus == EventStatus.success) {
          // Logout tamamlandı, login ekranına yönlendir
          context.router.replaceAll([const LoginScreenRoute()]);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.baseColor),
            onPressed: () => context.router.pop(),
          ),
          title: Text(
            AppLocalizations.of(context).earnFreeCredits,
            style: TextStyle(
              color: context.baseColor,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          centerTitle: true,
          actionsPadding: EdgeInsets.only(right: 12.w),
          actions: const [
            TotalCreditWidget(
              navigateAvailable: false,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Header Icon
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: context.baseColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: 40.sp,
                  color: context.baseColor,
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                AppLocalizations.of(context).freeCreditWays,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: context.baseColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                AppLocalizations.of(context).freeCreditDescription,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              // Watch Ads - Sadece yetkisi olan kullanıcılara göster
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  // is_can_watch_ads false ise gösterme
                  // null veya true ise göster (eski kullanıcılar için backward compatibility)
                  final canWatchAds = profileState.profileInfo?.isCanWatchAds;
                  if (canWatchAds == false) {
                    return const SizedBox.shrink();
                  }

                  return _buildFreeCreditOption(
                    context,
                    icon: Icons.play_circle_fill,
                    iconColor: Colors.green,
                    title: AppLocalizations.of(context).watchAdEarnCredit,
                    subtitle: AppLocalizations.of(context).watchAdSubtitle,
                    reward: '60 ${AppLocalizations.of(context).credit}',
                    onTap: () {
                      // 🔒 Guest kontrolü - Misafir kullanıcılara dialog göster
                      final user = FirebaseAuth.instance.currentUser;
                      if (user?.isAnonymous == true) {
                        _showGuestAccountDialog();
                        return;
                      }
                      // Normal kullanıcı - WatchAdsScreen'e git
                      context.router.push(WatchAdsScreenRoute());
                    },
                  );
                },
              ),

              // Review seçeneği sadece iOS'ta ve review yapmamış kullanıcılara göster
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  // Review yapmışsa veya iOS değilse gösterme
                  if (!Platform.isIOS ||
                      profileState.profileInfo?.hasReceivedReviewCredit ==
                          true) {
                    return const SizedBox.shrink();
                  }

                  // Review yapmamışsa göster
                  return Column(
                    children: [
                      SizedBox(height: 16.h),
                      _buildFreeCreditOption(
                        context,
                        icon: Icons.star_rate,
                        iconColor: Colors.amber,
                        title: AppLocalizations.of(context).rateAppEarnCredit,
                        subtitle: AppLocalizations.of(context).rateAppSubtitle,
                        reward: '60 ${AppLocalizations.of(context).credit}',
                        onTap: () {
                          _handleAppReview(context);
                        },
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 32.h),

              // Info Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: context.baseColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.baseColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: context.baseColor,
                      size: 24.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppLocalizations.of(context).freeCreditInfo,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: context.baseColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      AppLocalizations.of(context).freeCreditInfoDescription,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeCreditOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String reward,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24.sp,
                color: iconColor,
              ),
            ),
            SizedBox(width: 16.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Reward Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: context.baseColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                reward,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAppReview(BuildContext context) async {
    // 1. Kullanıcı kontrolü
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showUpgradeAccountDialog(context);
      return;
    }

    // 2. Kullanıcı bazlı kontrol
    final profileBloc = context.read<ProfileBloc>();
    final profileState = profileBloc.state;
    if (profileState.profileInfo?.hasReceivedReviewCredit == true) {
      _showAlreadyClaimedMessage(context);
      return;
    }

    // 3. 🔥 CİHAZ BAZLI KONTROL - Farklı hesaptan girse bile blokla
    final deviceId = await _getDeviceId();
    final deviceDoc = await FirebaseFirestore.instance
        .collection('device_review_credits')
        .doc(deviceId)
        .get();

    if (deviceDoc.exists && deviceDoc.data()?['claimed'] == true) {
      // Bu cihazdan daha önce başka biri review credit almış
      _showDeviceAlreadyUsedMessage(context);
      return;
    }

    // Rating dialog'u göster
    final rating = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const RatingDialog(),
    );

    if (rating != null) {
      if (rating >= 3) {
        // 3+ yıldız: Gerçek review işlemi
        await _handleRealReview(context, rating);
      } else {
        // 2- yıldız: Feedback sayfasına yönlendir
        _redirectToFeedback(context, rating);
      }
    }
  }

  Future<void> _handleRealReview(BuildContext context, int rating) async {
    // 1. Loading dialog göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: context.baseColor,
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).loading_please_wait,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );

    // 2. 3 saniye bekle

    // 3. Loading dialog'u kapat
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    try {
      // 4. Review dialog'u aç
      final InAppReview inAppReview = InAppReview.instance;
      final isAvailable = await inAppReview.isAvailable();

      if (isAvailable) {
        await inAppReview.requestReview();
      } else {
        await inAppReview.openStoreListing(
          appStoreId: '6739088765',
        );
      }
      await Future.delayed(Duration(seconds: 3));

      // 5. Review işleminden sonra kullanıcıya sor (rating'i ilet)
      if (context.mounted) {
        _showReviewConfirmationDialog(context, rating);
      }
    } catch (e) {
      debugPrint('❌ Error requesting review: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).reviewPageError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _redirectToFeedback(BuildContext context, int rating) {
    // Toast mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).redirectingToFeedback),
        backgroundColor: context.baseColor,
        duration: const Duration(seconds: 2),
      ),
    );

    // Kısa bir delay sonra feedback sayfasına git
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        context.router.push(const FeedbackScreenRoute());
      }
    });
  }

  void _showUpgradeAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: context.baseColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.upgrade,
                    size: 30.sp,
                    color: context.baseColor,
                  ),
                ),
                SizedBox(height: 16.h),

                // Title
                Text(
                  AppLocalizations.of(context).upgradeAccountRequired,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: context.baseColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // Message
                Text(
                  AppLocalizations.of(context).upgradeAccountMessage,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).cancel,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          // Create Account sayfasına yönlendir
                          context.router
                              .push(CreateAccountScreenRoute(isUpgrade: true));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.baseColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(
                          AppLocalizations.of(context).upgradeAccount,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlreadyClaimedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                AppLocalizations.of(context).reviewCreditAlreadyClaimed,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  /// Cihaz daha önce kullanılmış mesajı
  void _showDeviceAlreadyUsedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.phone_android, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!
                        .deviceAlreadyClaimedReviewCredit,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.deviceReviewCreditMessage,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _showReviewConfirmationDialog(BuildContext context, int rating) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context).reviewConfirmationTitle,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            Platform.isIOS
                ? AppLocalizations.of(context).reviewConfirmationMessageIOS
                : AppLocalizations.of(context).reviewConfirmationMessageAndroid,
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showThankYouMessage(context, hasReviewed: false);
              },
              child: Text(
                AppLocalizations.of(context).no,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _giveReviewCredit(context, rating);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.baseColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).yesIRated,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Review kredisi ver - Cloud Functions üzerinden
  void _giveReviewCredit(BuildContext context, int rating) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      debugPrint('⭐ Requesting review credit via Cloud Function...');

      // Device ID al
      final deviceId = await _getDeviceId();

      // Cloud Function çağır
      final callable =
          FirebaseFunctions.instance.httpsCallable('claimReviewCredit');

      final result = await callable.call({
        'deviceId': deviceId,
        'rating': rating,
      });

      // Sonucu parse et
      final success = result.data['success'] as bool;
      final creditAmount = result.data['creditAmount'] as int;
      final message = result.data['message'] as String;

      if (success) {
        final reviewMessage = creditAmount > 0
            ? '🎉 Review credit applied! Amount: $creditAmount credits'
            : AppLocalizations.of(context).reviewCompletedNoCredit;
        debugPrint(reviewMessage);
        debugPrint('📝 Message: $message');

        // Profile bloc'u güncelle
        if (context.mounted) {
          context.read<ProfileBloc>().add(
                FetchProfileInfoEvent(user.uid),
              );
        }

        if (context.mounted) {
          _showThankYouMessage(context,
              hasReviewed: true, creditAmount: creditAmount);
        }
      } else {
        debugPrint('❌ Review credit failed');
        if (context.mounted) {
          _showThankYouMessage(context, hasReviewed: false, creditAmount: 0);
        }
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ FirebaseFunctionsException: ${e.code} - ${e.message}');

      // Hata kodlarına göre özel handling
      switch (e.code) {
        case 'already-exists':
          debugPrint('ℹ️ Review credit already claimed (user or device)');
          break;
        case 'unauthenticated':
          debugPrint('ℹ️ User not authenticated');
          break;
        case 'invalid-argument':
          debugPrint('ℹ️ Invalid parameters');
          break;
        default:
          debugPrint('ℹ️ Unknown error: ${e.code}');
      }

      if (context.mounted) {
        _showThankYouMessage(context, hasReviewed: false, creditAmount: 0);
      }
    } catch (e) {
      debugPrint('❌ Error giving review credit: $e');
      if (context.mounted) {
        _showThankYouMessage(context, hasReviewed: false, creditAmount: 0);
      }
    }
  }

  void _showThankYouMessage(BuildContext context,
      {required bool hasReviewed, int creditAmount = 0}) {
    final message = hasReviewed
        ? (creditAmount > 0
            ? AppLocalizations.of(context).reviewThanksWithCredit
            : AppLocalizations.of(context).reviewCompletedNoCredit)
        : AppLocalizations.of(context).reviewThanksWithoutCredit;

    final backgroundColor = hasReviewed ? Colors.green : context.baseColor;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              hasReviewed ? Icons.check_circle : Icons.info,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: hasReviewed ? 5 : 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  /// 👤 Misafir hesap uyarı dialog'u göster
  Future<void> _showGuestAccountDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).guestAccountTitle,
                  style: TextStyle(
                    fontSize: 20.sp,
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
                AppLocalizations.of(context).guestAccountWatchAdsMessage,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stars,
                            color: Colors.blue.shade700, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).guestAccountBenefits,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    _buildGuestBenefitItem(Icons.ad_units,
                        AppLocalizations.of(context).benefitWatchAds),
                    _buildGuestBenefitItem(Icons.cloud_upload,
                        AppLocalizations.of(context).benefitCloudSync),
                    _buildGuestBenefitItem(Icons.workspace_premium,
                        AppLocalizations.of(context).benefitPremiumFeatures),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Dialog'u kapat ve logout sinyali gönder
                      Navigator.of(dialogContext).pop(true);
                    },
                    icon: Icon(Icons.logout, size: 20.h),
                    label: Text(AppLocalizations.of(context).signInWithAccount),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.baseColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    child: Text(
                      AppLocalizations.of(context).close,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    // Dialog kapandıktan sonra, eğer kullanıcı logout'u seçtiyse işlemi yap
    if (result == true && mounted) {
      // Guest hesaptan çık ve login ekranına yönlendir
      getIt<ProfileBloc>().add(const LogoutEvent());
    }
  }

  /// Fayda listesi item builder (guest dialog için)
  Widget _buildGuestBenefitItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade600),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
