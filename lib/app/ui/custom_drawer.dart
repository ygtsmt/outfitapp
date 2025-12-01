// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/app/core/services/revenue_cat_service.dart';
import 'package:ginly/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginly/app/features/auth/features/profile/data/profile_usecase.dart';
import 'package:ginly/app/ui/widgets/language_dropdown.dart';
import 'package:ginly/core/constants/layout_constants.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ginly/core/data_sources/local_data_source/secure_data_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ginly/core/utils.dart';
import 'package:in_app_review/in_app_review.dart';

class CustomDrawer extends StatefulWidget {
  final AppState state;
  const CustomDrawer({
    super.key,
    required this.state,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isRestoring = false;
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> _restorePurchases() async {
    setState(() => _isRestoring = true);

    try {
      final success = await RevenueCatService.restorePurchases();

      if (success) {
        // Refresh profile to get updated subscription status
        if (auth.currentUser != null) {
          getIt<ProfileBloc>()
              .add(FetchProfileInfoEvent(auth.currentUser!.uid));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchases restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No purchases found to restore.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restore purchases. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isRestoring = false);
    }
  }

  /// Dil'e göre document URL'ini çözümle
  String resolveDocumentByLocale(
    String currentLocale,
    String enUrl,
    String trUrl,
    String deUrl,
    String frUrl,
  ) {
    switch (currentLocale) {
      case 'tr':
        return trUrl;
      case 'de':
        return deUrl;
      case 'fr':
        return frUrl;
      case 'en':
      default:
        return enUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width / 1.5,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 8.h,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset(
                    PngPaths.logo,
                    height: 100,
                  ),
                  Text(AppLocalizations.of(context).appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Futura',
                              color: context.baseColor)),
                ],
              ),
              /*   Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4.w,
                        height: 24.h,
                        color: context.baseColor,
                        margin: const EdgeInsets.only(
                            right: 8), // Yazıdan biraz boşluk
                      ),
                      Text(
                        AppLocalizations.of(context)
                            .app_settings,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
     */
              Divider(),
              LanguageDropdown(
                selectedLocale:
                    widget.state.languageLocale?.languageCode ?? 'en',
              ),
              // Spacer(),
              LayoutConstants.tinyEmptyHeight,
              /* ListTile(
                leading: Icon(
                  Icons.star_border_outlined,
                ),
                title: Text(
                  AppLocalizations.of(context).rateUs,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  final Uri url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.example.ginly');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ), */
              // Feedback
              ListTile(
                leading: const Icon(
                  Icons.feedback_outlined,
                ),
                title: Text(
                  AppLocalizations.of(context).feedback,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  context.router.push(const FeedbackScreenRoute());
                },
              ),
              // Rate App - Sadece review yapmamış kullanıcılara göster
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  // Review yapmışsa butonu gösterme
                  if (profileState.profileInfo?.hasReceivedReviewCredit == true) {
                    return const SizedBox.shrink();
                  }
                  
                  return ListTile(
                    leading: const Icon(
                      Icons.star_rate_rounded,
                      color: Colors.amber,
                    ),
                    title: Text(
                      AppLocalizations.of(context).rateOurApp,
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      _requestInAppReview(context);
                    },
                  );
                },
              ),
              // Debug: Reset Bonus (Only for testing)

              // Delete Account
              ListTile(
                leading: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red,
                ),
                title: Text(
                  AppLocalizations.of(context).deleteAccount,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
              ),
              // Privacy Policy ve Terms of Service
              ListTile(
                leading: Icon(
                  Icons.privacy_tip_outlined,
                  color: context.baseColor,
                ),
                title: Text(
                  AppLocalizations.of(context).privacyPolicy,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  context.router.push(
                    DocumentsWebViewScreenRoute(
                      pdfUrl: 'https://www.ginlyai.com/#/privacy',
                      title: AppLocalizations.of(context).privacyPolicy,
                    ),
                  );
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.description_outlined,
                  color: context.baseColor,
                ),
                title: Text(
                  AppLocalizations.of(context).termsOfService,
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  context.router.push(
                    DocumentsWebViewScreenRoute(
                      pdfUrl: "https://www.ginlyai.com/#/terms",
                      title: AppLocalizations.of(context).termsOfService,
                    ),
                  );
                },
              ),
              if (Platform.isIOS)
                // Apple Standard EULA
                ListTile(
                  leading: Icon(
                    Icons.gavel_outlined,
                    color: context.baseColor,
                  ),
                  title: Text(
                    'Apple Standard EULA',
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    context.router.push(
                      DocumentsWebViewScreenRoute(
                        pdfUrl:
                            'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                        title: 'Apple Standard EULA',
                      ),
                    );
                  },
                ),
              if (Platform.isIOS)
                ListTile(
                  onTap: _isRestoring ? null : _restorePurchases,
                  leading: _isRestoring
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                context.baseColor),
                          ),
                        )
                      : Icon(Icons.restore, size: 18.sp),
                  title: Text(
                    AppLocalizations.of(context).restorePurchases,
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              ListTile(
                title: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        spacing: 4,
                        children: [
                          Text(
                            'Version ${snapshot.data!.version}-${snapshot.data!.buildNumber}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(
                                  'https://www.linkedin.com/in/ygtsmt/');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Made by ',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: context.baseColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Ginowl',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: context.baseColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: context.baseColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                    // Debug için snapshot durumunu yazdır
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestInAppReview(BuildContext context) async {
    try {
      final InAppReview inAppReview = InAppReview.instance;

      // Check if in-app review is available
      final isAvailable = await inAppReview.isAvailable();
      debugPrint('🔍 In-app review available: $isAvailable');

      if (isAvailable) {
        debugPrint('🚀 Requesting in-app review...');
        await inAppReview.requestReview();
        debugPrint('✅ In-app review request completed');

        // Review işlemi tamamlandıktan sonra toast mesajı göster
        _showReviewCompletedToast(context);
      } else {
        debugPrint('📱 Opening store listing as fallback...');
        // Fallback: Open store listing
        await inAppReview.openStoreListing(
          appStoreId: '6739088765', // iOS App Store ID
          microsoftStoreId: '', // Not needed for mobile
        );

        // Store açıldıktan sonra da toast mesajı göster
        _showReviewCompletedToast(context);
      }
    } catch (e) {
      debugPrint('❌ Error requesting in-app review: $e');
      // Ultimate fallback: Show a simple message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).rateOurApp} 🌟'),
            action: SnackBarAction(
              label: 'Open Store',
              onPressed: () async {
                final inAppReview = InAppReview.instance;
                await inAppReview.openStoreListing(
                  appStoreId: '6739088765',
                );
                // Store açıldıktan sonra toast mesajı göster
                _showReviewCompletedToast(context);
              },
            ),
          ),
        );
      }
    }
  }

  void _showReviewCompletedToast(BuildContext context) {
    // Kısa bir delay ile toast mesajını göster (review dialog'u kapandıktan sonra)
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Uygulamamızı değerlendirdiğiniz için teşekkürler! 🌟',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).deleteAccountWarning,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(context).deleteAccountWarningDescription,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                AppLocalizations.of(context).cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteAccount(context);
              },
              child: Text(
                AppLocalizations.of(context).deleteMyAccount,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // ProfileUseCase'i kullanarak hesabı sil
      final profileUseCase = ProfileUseCase(
        auth: FirebaseAuth.instance,
        googleSignIn: GoogleSignIn(),
        firestore: FirebaseFirestore.instance,
        secureDataStorage: SecureDataStorage(const FlutterSecureStorage()),
      );

      await profileUseCase.deleteAccount();

      // Başarılı silme sonrası toast mesajı göster
      if (context.mounted) {
        Utils.showToastMessage(
          context: context,
          content: AppLocalizations.of(context).accountDeletedSuccessfully,
        );

        // Kısa bir süre sonra splash screen'e yönlendir
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            context.router.replaceAll([const SplashScreenRoute()]);
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        Utils.showToastMessage(
          context: context,
          content: '${AppLocalizations.of(context).accountDeletionError}: $e',
        );
      }
    }
  }
  }


