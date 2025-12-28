import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ginfit/app/features/library/ui/screens/library_videos_screen.dart';
import 'package:ginfit/app/features/library/bloc/library_bloc.dart';
import 'package:ginfit/core/core.dart';

import 'package:ginfit/generated/l10n.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Library ekranı görüntülendi

    // Get only user videos
    getIt<LibraryBloc>().add(const GetUserGeneratedVideosEvent());

    // Check pending Pixverse Original videos
    _checkPendingVideos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App foreground'a geldiğinde pending videoları check et
      _checkPendingVideos();
    }
  }

  void _checkPendingVideos() {
    getIt<LibraryBloc>().add(const CheckPendingPixverseOriginalVideosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        // Firebase Auth durumunu kontrol et
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          // Kullanıcı giriş yapmamışsa login UI'ı göster
          return _buildLoginRequiredUI(context);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            spacing: 4.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Videos header with refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [],
              ),
              // Videos content
              const Expanded(
                child: LibraryVideosScreen(),
              ),
            ],
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
              Icons.library_books,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24.h),
            Text(
              'Kütüphaneye Erişim Gerekli',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'Ürettiğiniz içeriklerinizi görmek ve yönetmek için giriş yapmanız gerekir.',
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
