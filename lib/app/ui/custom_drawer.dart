import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/bloc/app_bloc.dart';
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comby/app/ui/widgets/language_dropdown.dart';
import 'package:comby/core/constants/layout_constants.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:comby/core/routes/app_router.dart';
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
                    'assets/png/launcher_icon_android.png',
                    height: 150.h,
                  ),
                  SizedBox(height: 16.h),
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
              const Divider(),
              LanguageDropdown(
                selectedLocale:
                    widget.state.languageLocale?.languageCode ?? 'en',
              ),
              LayoutConstants.tinyEmptyHeight,

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
                  if (profileState.profileInfo?.hasReceivedReviewCredit ==
                      true) {
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
}
