import 'package:firebase_auth/firebase_auth.dart';
import 'package:comby/app/features/auth/features/profile/ui/widgets/change_password_bottom_sheet.dart';

import 'package:comby/core/constants/layout_constants.dart';
import 'package:comby/core/utils.dart';
import 'package:comby/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/generated/l10n.dart';

class ProfileSecurityCardWidget extends StatelessWidget {
  const ProfileSecurityCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(top: 4.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            spacing: 8.h,
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.baseColor,
                      context.baseColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Icon(
                Icons.security_outlined,
                color: context.baseColor,
                size: 20.h,
              ),
              Text(
                AppLocalizations.of(context).accountInformation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.grey[200],
          ),
          LayoutConstants.tinyEmptyHeight,

          // Password Info
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850]! : Colors.grey[100]!,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: context.baseColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: context.baseColor,
                    size: 20.h,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 8.h,
                        children: [
                          Text(
                            AppLocalizations.of(context).password,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 8.sp,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppLocalizations.of(context).secure,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 8.sp,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.verified_outlined,
                            color: Colors.green,
                            size: 20.h,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "••••••••",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              letterSpacing: 2,
                            ),
                          ),

                          /*  */
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user != null) {
                      final isEmailPasswordLogin = user.providerData.any(
                        (info) => info.providerId == 'password',
                      );

                      if (isEmailPasswordLogin) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (context) =>
                              const ChangePasswordBottomSheet(),
                        );
                      } else {
                        Utils.showToastMessage(
                          content:
                              AppLocalizations.of(context).noPasswordChange,
                          context: context,
                        );
                      }
                    } else {
                      Utils.showToastMessage(
                        content: AppLocalizations.of(context).userNotFound,
                        context: context,
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: context.baseColor,
                          size: 14.h,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          AppLocalizations.of(context).edit,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: context.baseColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
