import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';
import 'package:comby/app/ui/widgets/personal_info_card_widget.dart';
import 'package:comby/app/ui/widgets/profile_security_card_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comby/core/utils.dart';
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:comby/app/ui/widgets/custom_gradient_button.dart';
import 'package:get_it/get_it.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: Text(
          "Ayarlar",
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
            _buildSectionHeader(context, "Hesap & Güvenlik"),
            SizedBox(height: 12.h),

            // Reusing existing logic but wrapped in a cleaner container if needed,
            // or we could just use them directly if they look good enough.
            // Let's use them directly but maybe add some spacing or dividers.
            const PersonalInfoCard(),
            SizedBox(height: 16.h),
            const ProfileSecurityCardWidget(),

            SizedBox(height: 32.h),

            // Preferences Section (Placeholder for future)
            _buildSectionHeader(context, "Uygulama Tercihleri"),
            SizedBox(height: 12.h),
            _buildMenuTile(
              context,
              icon: Icons.notifications_outlined,
              title: "Bildirimler",
              onTap: () {
                // Future impl
              },
            ),
            SizedBox(height: 12.h),
            _buildMenuTile(
              context,
              icon: Icons.language,
              title: "Dil & Bölge",
              subtitle: "Türkçe (TR)",
              onTap: () {
                // Future impl
              },
            ),

            SizedBox(height: 48.h),

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
              // textColor: Colors.redAccent, // Was undefined
              // borderColor: Colors.redAccent.withOpacity(0.5), // Was undefined
            ),

            SizedBox(height: 24.h),
            Text(
              "Versiyon 1.0.0",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: context.baseColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(BuildContext context,
      {required IconData icon,
      required String title,
      String? subtitle,
      VoidCallback? onTap}) {
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
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: Colors.grey[700], size: 22.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
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
        trailing:
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey[300]),
      ),
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
