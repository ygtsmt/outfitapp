import "package:firebase_auth/firebase_auth.dart";
import "package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart";
import "package:ginfit/app/features/auth/features/profile/ui/profile_info_screen.dart";
import "package:ginfit/app/features/auth/ui/side_image.dart";
import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_adaptive_ui/flutter_adaptive_ui.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:ginfit/core/core.dart";

import 'package:ginfit/generated/l10n.dart';

class ProfileScreen extends StatelessWidget {
   ProfileScreen({super.key});

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (final context, final state) {
        // Firebase Auth durumunu kontrol et
        final user = auth.currentUser;

        if (user == null) {
          // Kullanıcı giriş yapmamışsa login UI'ı göster
          return _buildLoginRequiredUI(context);
        }

        return RefreshIndicator(
          color: context.white,
          backgroundColor: context.baseColor,
          onRefresh: () async => getIt<ProfileBloc>()
              .add(FetchProfileInfoEvent(auth.currentUser?.uid ?? '')),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: AdaptiveBuilder(
                  layoutDelegate: AdaptiveLayoutDelegateWithMinimallScreenType(
                    handset: (final BuildContext context, final Screen screen) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: ProfileInfoScreen(),
                      );
                    },
                    tablet: (final BuildContext context, final Screen screen) {
                      return const Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: ProfileInfoScreen(),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                  defaultBuilder:
                      (final BuildContext context, final Screen screen) {
                    return const ProfileInfoScreen();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginRequiredUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24.h),
            Text(
              'Profil Erişimi Gerekli',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'Profil bilgilerinizi görüntülemek ve düzenlemek için giriş yapmanız gerekir.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                context.router.replace(const LoginScreenRoute());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.baseColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                AppLocalizations.of(context).loginButton,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
