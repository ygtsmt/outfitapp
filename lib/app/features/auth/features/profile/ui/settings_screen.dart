import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comby/app/core/services/revenue_cat_service.dart';
import 'package:comby/app/features/auth/features/profile/data/profile_usecase.dart';
import 'package:comby/app/bloc/app_bloc.dart';
import 'package:comby/app/ui/widgets/language_dropdown.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/data_sources/local_data_source/secure_data_storage.dart';
import 'package:comby/generated/l10n.dart';
import 'package:comby/app/ui/widgets/personal_info_card_widget.dart';
import 'package:comby/app/ui/widgets/profile_security_card_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comby/core/utils.dart';
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:comby/app/ui/widgets/custom_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context).restorePurchasesSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).restorePurchasesEmpty),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).restorePurchasesError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          AppLocalizations.of(context).settingsTitle,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            // Modern "Account" Section
            _buildSectionHeader(
                context, AppLocalizations.of(context).accountAndSecurity),
            SizedBox(height: 12.h),

            const PersonalInfoCard(),
            SizedBox(height: 16.h),
            const ProfileSecurityCardWidget(),

            SizedBox(height: 32.h),

            // Satın Alma Section (iOS Only)

            // Yasal & Bilgi Section
            _buildSectionHeader(
                context, AppLocalizations.of(context).legalAndInfo),
            SizedBox(height: 12.h),
            _buildMenuTile(
              context,
              icon: Icons.description_outlined,
              title: AppLocalizations.of(context).termsOfService,
              onTap: () {
                context.router.push(
                  DocumentsWebViewScreenRoute(
                    pdfUrl: "https://www.comby.ai/#/terms",
                    title: AppLocalizations.of(context).termsOfService,
                  ),
                );
              },
            ),
            SizedBox(height: 12.h),
            _buildMenuTile(
              context,
              icon: Icons.privacy_tip_outlined,
              title: AppLocalizations.of(context).privacyPolicy,
              onTap: () {
                context.router.push(
                  DocumentsWebViewScreenRoute(
                    pdfUrl: 'https://www.comby.ai/#/privacy',
                    title: AppLocalizations.of(context).privacyPolicy,
                  ),
                );
              },
            ),
            if (Platform.isIOS) ...[
              SizedBox(height: 12.h),
              _buildMenuTile(
                context,
                icon: Icons.gavel_outlined,
                title: AppLocalizations.of(context).appleEula,
                onTap: () {
                  context.router.push(
                    DocumentsWebViewScreenRoute(
                      pdfUrl:
                          'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                      title: AppLocalizations.of(context).appleEula,
                    ),
                  );
                },
              ),
            ],

            SizedBox(height: 32.h),

            // Preferences Section
            _buildSectionHeader(
                context, AppLocalizations.of(context).appPreferences),
            SizedBox(height: 12.h),
            _buildMenuTile(
              context,
              icon: Icons.notifications_outlined,
              title: AppLocalizations.of(context).notifications,
              onTap: () {
                // Future impl
              },
            ),
            SizedBox(height: 12.h),
            BlocBuilder<AppBloc, AppState>(
              builder: (context, state) {
                return _buildMenuTile(
                  context,
                  icon: Icons.language,
                  title: AppLocalizations.of(context).changeLanguage,
                  subtitle: AppLocalizations.of(context).currentLanguageName,
                  onTap: () {
                    _showLanguageBottomSheet(
                        context, state.languageLocale?.languageCode ?? 'en');
                  },
                );
              },
            ),
            SizedBox(height: 12.h),
            _buildMenuTile(
              context,
              icon: Icons.feedback_outlined,
              title: AppLocalizations.of(context).feedback,
              onTap: () {
                context.router.push(const FeedbackScreenRoute());
              },
            ),

            SizedBox(height: 32.h),

            // Hesap Silme (Dangerous Zone)
            _buildSectionHeader(
                context, AppLocalizations.of(context).accountOperations,
                color: Colors.redAccent),
            SizedBox(height: 12.h),
            _buildMenuTile(
              context,
              icon: Icons.delete_forever_outlined,
              title: AppLocalizations.of(context).deleteAccount,
              titleColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _showDeleteAccountDialog(context),
            ),

            SizedBox(height: 24.h),
            if (Platform.isIOS) ...[
              _buildSectionHeader(
                  context, AppLocalizations.of(context).purchases),
              SizedBox(height: 12.h),
              _buildMenuTile(
                context,
                icon: Icons.restore,
                title: AppLocalizations.of(context).restorePurchases,
                trailing: _isRestoring
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(context.baseColor),
                        ),
                      )
                    : Icon(Icons.arrow_forward_ios,
                        size: 14.sp, color: Colors.grey[300]),
                onTap: _isRestoring ? null : _restorePurchases,
              ),
              SizedBox(height: 32.h),
            ],
            // Logout Button
            CustomGradientButton(
              title: AppLocalizations.of(context).logout,
              leading: Icon(
                Icons.logout,
                color: Colors.redAccent,
                size: 20.h,
              ),
              onTap: () => _handleLogout(context),
              isFilled: false,
            ),

            SizedBox(height: 24.h),
            FutureBuilder<PackageInfo>(
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
                          final Uri url =
                              Uri.parse('https://www.linkedin.com/in/ygtsmt/');
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
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {Color? color}) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: color ?? context.baseColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(BuildContext context,
      {required IconData icon,
      required String title,
      String? subtitle,
      VoidCallback? onTap,
      Color? titleColor,
      Color? iconColor,
      Widget? trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.grey[700])!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor ?? Colors.grey[700], size: 22.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: titleColor ?? Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              )
            : null,
        trailing: trailing ??
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey[300]),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, String selectedLanguage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                AppLocalizations.of(context).selectLanguage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Language list with scroll
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: languages.map((LanguageItem lang) {
                      final isSelected = lang.code == selectedLanguage;
                      return ListTile(
                        leading: Image.asset(
                          lang.flagAsset,
                          width: 32,
                          height: 32,
                        ),
                        title: Text(
                          lang.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                        onTap: () async {
                          setState(() {
                            selectedLanguage = lang.code;
                          });
                          // Dil ayarını kalıcı olarak sakla
                          await getIt<SecureDataStorage>()
                              .setAppLanguage(Locale(lang.code));
                          getIt<AppBloc>()
                              .add(SetLanguageEvent(Locale(lang.code)));
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.isAnonymous == true) {
      Utils.showItemsAlertDialog(
        context: context,
        title: "⚠️ ${AppLocalizations.of(context).warning}",
        content: Column(
          children: [
            Text(
              AppLocalizations.of(context).guest_logout_warning,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
            SizedBox(height: 16.h),
            CustomGradientButton(
              title: AppLocalizations.of(context).logout,
              isFilled: false,
              onTap: () {
                getIt<ProfileBloc>().add(const LogoutEvent());
              },
            )
          ],
        ),
      );
    } else {
      Utils.showItemsAlertDialog(
        context: context,
        title: AppLocalizations.of(context).logout_confirmation,
        content: Column(
          children: [
            CustomGradientButton(
              title: AppLocalizations.of(context).logout,
              isFilled: false,
              onTap: () {
                getIt<ProfileBloc>().add(const LogoutEvent());
              },
            )
          ],
        ),
      );
    }
  }
}
