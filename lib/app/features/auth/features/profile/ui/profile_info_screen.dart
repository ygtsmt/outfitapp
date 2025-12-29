import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/app/ui/widgets/custom_gradient_button.dart';
import 'package:ginfit/app/ui/widgets/profile_image_network.dart';
import 'package:ginfit/app/ui/widgets/personal_info_card_widget.dart';
import 'package:ginfit/app/ui/widgets/profile_security_card_widget.dart';
import 'package:ginfit/core/utils.dart';
import 'package:ginfit/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginfit/core/helpers/error_message_handle.dart';
import 'package:ginfit/generated/l10n.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Profile sayfası açıldığında otomatik olarak profil bilgilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        getIt<ProfileBloc>().add(FetchProfileInfoEvent(
            currentUser.uid)); // AppBloc'tan satın alma bilgilerini al
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state.logoutStatus == EventStatus.success) {
              // Logout tamamlandı
              context.router.replaceAll([const LoginScreenRoute()]);
            }
            if (state.deleteAccountStatus == EventStatus.success) {
              context.router.replaceAll([const LoginScreenRoute()]);
            }

            if (state.changePasswordStatus == EventStatus.failure) {
              Utils.showToastMessage(
                  context: context,
                  content: ErrorMessageHandle.getFirebaseAuthErrorMessage(
                      state.profileGeneralErrorMessage));
            } else if (state.changePasswordStatus == EventStatus.success) {
              Utils.showToastMessage(
                context: context,
                content: AppLocalizations.of(context).passwordChangedSuccess,
              );
            }

            if (state.updateUsernameStatus == EventStatus.success) {
              Utils.showToastMessage(
                context: context,
                content:
                    AppLocalizations.of(context).usernameUpdatedSuccessfully,
              );
            } else if (state.updateUsernameStatus == EventStatus.failure) {
              Utils.showToastMessage(
                context: context,
                content: ErrorMessageHandle.getFirebaseAuthErrorMessage(
                    state.profileGeneralErrorMessage),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, appState) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[50]!,
                      Colors.white,
                    ],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Profile Image
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              ProfileImageNetwork(
                                url: profileState.profileInfo?.photoURL,
                              ),
                              Positioned(
                                bottom: 16.w,
                                right: 8.w,
                                child: Icon(Icons.change_circle,
                                    color: context.baseColor),
                              ),
                            ],
                          ),
                          SizedBox(width: 16.w),
                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // User Name
                                Text(
                                  profileState.profileInfo?.displayName ??
                                      AppLocalizations.of(context).user,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: 8.h),

                                // UID with Copy (Hidden for anonymous users)
                                if (auth.currentUser?.isAnonymous == true)
                                  // Guest User Badge
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.orange[200]!),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: 16.sp,
                                          color: Colors.orange[600],
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          AppLocalizations.of(context)
                                              .guestUser,
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                        text:
                                            profileState.profileInfo?.uid ?? '',
                                      ));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${AppLocalizations.of(context).uidCopied}!'),
                                          backgroundColor: context.baseColor,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                      ),
                                      child: Text(
                                        'UID:${profileState.profileInfo?.uid?.toString()}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'monospace',
                                            ),
                                      ),
                                    ),
                                  ),

                                SizedBox(height: 8.h),

                                // Plan Badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        context.baseColor.withOpacity(0.1),
                                        context.baseColor.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.baseColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 6.w),
                                      Text(
                                        _getPlanDisplayName(appState
                                            .purchasedInfo?.lastProductId),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: context.baseColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Info Cards
                      const PersonalInfoCard(),
                      SizedBox(height: 16.h),
                      const ProfileSecurityCardWidget(),
                      SizedBox(height: 16.h),

                      // Action Buttons

                      CustomGradientButton(
                        title: AppLocalizations.of(context).logout,
                        leading: Icon(
                          Icons.logout,
                          color: context.baseColor,
                          size: 20.h,
                        ),
                        onTap: () {
                          // ⚠️ Guest kontrolü
                          final user = FirebaseAuth.instance.currentUser;
                          if (user?.isAnonymous == true) {
                            // Guest user - özel uyarı göster
                            Utils.showItemsAlertDialog(
                              context: context,
                              title:
                                  "⚠️ ${AppLocalizations.of(context).warning}",
                              content: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)
                                        .guest_logout_warning,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  CustomGradientButton(
                                    title: AppLocalizations.of(context).logout,
                                    isFilled: false,
                                    onTap: () {
                                      getIt<ProfileBloc>()
                                          .add(const LogoutEvent());
                                    },
                                  )
                                ],
                              ),
                            );
                          } else {
                            // Normal user - standart logout
                            Utils.showItemsAlertDialog(
                              context: context,
                              title: AppLocalizations.of(context)
                                  .logout_confirmation,
                              content: Column(
                                children: [
                                  CustomGradientButton(
                                    title: AppLocalizations.of(context).logout,
                                    isFilled: false,
                                    onTap: () {
                                      getIt<ProfileBloc>()
                                          .add(const LogoutEvent());
                                    },
                                  )
                                ],
                              ),
                            );
                          }
                        },
                        isFilled: false,
                      ),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getPlanDisplayName(String? planId) {
    if (planId == null) return AppLocalizations.of(context).freePlan;

    if (planId.contains('plus')) {
      return AppLocalizations.of(context).ginlyAiPlusPlan;
    } else if (planId.contains('pro')) {
      return AppLocalizations.of(context).ginlyAiProPlan;
    } else if (planId.contains('ultra')) {
      return AppLocalizations.of(context).ginlyAiUltraPlan;
    }

    return AppLocalizations.of(context).freePlan;
  }
}
