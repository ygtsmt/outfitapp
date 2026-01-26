import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:comby/core/constants/layout_constants.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/generated/l10n.dart';

class PersonalInfoCard extends StatelessWidget {
  const PersonalInfoCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Container(
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
              // Info Tiles
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100]!,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  spacing: 8.h,
                  children: [
                    _buildInfoTile(
                        context,
                        AppLocalizations.of(context).username,
                        state.profileInfo?.displayName ?? '',
                        Icons.person,
                        isEditable: true),
                    Divider(
                      height: 1,
                      color: Colors.grey[300]!,
                      indent: 60.w,
                      endIndent: 16.w,
                    ),
                    _buildInfoTile(
                      context,
                      AppLocalizations.of(context).email,
                      state.profileInfo?.email ??
                          AppLocalizations.of(context).notProvided,
                      Icons.email_outlined,
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey[300]!,
                      indent: 60.w,
                      endIndent: 16.w,
                    ),
                    _buildInfoTile(
                      context,
                      AppLocalizations.of(context).authMethod,
                      _getAuthProviderDisplayName(
                          context, state.profileInfo?.authProvider),
                      _getAuthProviderIcon(state.profileInfo?.authProvider),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    bool isEditable = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: context.baseColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: context.baseColor,
            size: 20.h,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 8.sp,
                ),
              ),
              SizedBox(height: 4.h),
              if (isEditable)
                _buildEditableUsername(context, value)
              else
                Text(
                  value.isEmpty
                      ? AppLocalizations.of(context).notProvided
                      : value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableUsername(BuildContext context, String currentUsername) {
    return Row(
      children: [
        Expanded(
          child: Text(
            currentUsername.isEmpty
                ? AppLocalizations.of(context).notProvided
                : currentUsername,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 8.h),
          child: GestureDetector(
            onTap: () {
              _showEditUsernameDialog(context, currentUsername);
            },
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
    );
  }

  void _showEditUsernameDialog(BuildContext context, String currentUsername) {
    Utils.showEditUsernameDialog(
      context: context,
      currentUsername: currentUsername,
      onSave: (String newUsername) {
        getIt<ProfileBloc>().add(UpdateUsernameEvent(newUsername));
      },
    );
  }

  String _getAuthProviderDisplayName(
      BuildContext context, String? authProvider) {
    switch (authProvider?.toLowerCase()) {
      case 'google':
        return AppLocalizations.of(context).googleSignIn;
      case 'apple':
        return AppLocalizations.of(context).appleSignIn;
      case 'email':
        return AppLocalizations.of(context).emailPasswordLogin;
      default:
        return AppLocalizations.of(context).unknown;
    }
  }

  IconData _getAuthProviderIcon(String? authProvider) {
    switch (authProvider?.toLowerCase()) {
      case 'google':
        return Icons.g_mobiledata; // Google icon
      case 'apple':
        return Icons.apple; // Apple icon
      case 'email':
        return Icons.email; // Email icon
      default:
        return Icons.help_outline; // Default icon
    }
  }
}
