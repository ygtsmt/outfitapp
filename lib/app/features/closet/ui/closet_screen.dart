import 'dart:math';
import 'dart:ui' as ui;
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';
import 'package:comby/app/features/closet/ui/widgets/wardrobe_tab_content.dart';
import 'package:comby/app/features/closet/ui/widgets/models_tab_content.dart';
import 'package:comby/app/features/closet/ui/widgets/combines_tab_content.dart';
import 'package:comby/app/features/closet/ui/widgets/critiques_tab_content.dart';

class ClosetScreen extends StatefulWidget {
  const ClosetScreen({super.key});

  /// Notifier to switch tabs externally
  static final ValueNotifier<int> tabNotifier = ValueNotifier<int>(0);

  @override
  State<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends State<ClosetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: ClosetScreen.tabNotifier.value,
    );

    ClosetScreen.tabNotifier.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    ClosetScreen.tabNotifier.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted) {
      _tabController.animateTo(ClosetScreen.tabNotifier.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildLoginRequiredUI(context);
    }

    return Container(
      padding: EdgeInsets.only(top: 4.h),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TabBar
            // Glassmorphic Premium TabBar
            /* Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      return Text(
                        _getGreeting(state.profileInfo?.displayName ?? ""),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: context.baseColor,
                        ),
                      );
                    },
                  ),
                  Builder(
                    builder: (context) {
                      final messages = AppLocalizations.of(context)
                          .closet_welcome_messages
                          .split('|');
      
                      if (messages.isEmpty) return const SizedBox.shrink();
      
                      final randomMessage =
                          messages[Random().nextInt(messages.length)];
      
                      return Text(
                        randomMessage,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: context.baseColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ), */
            TabBar(
              padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              labelStyle: TextStyle(
                fontSize: 13.sp, // Slightly smaller to fit 4 tabs
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: [
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context).wardrobe),
                  ),
                ),
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context).models),
                  ),
                ),
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context).combines),
                  ),
                ),
                Tab(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context).critiques),
                  ),
                ),
              ],
            ),
            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  WardrobeTabContent(),
                  ModelsTabContent(),
                  CombinesTabContent(),
                  CritiquesTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
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
              Icons.checkroom_outlined,
              size: 80.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24.h),
            Text(
              AppLocalizations.of(context).closetAccessRequired,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).closetAccessDescription,
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

  String _getGreeting(String username) {
    String name =
        username.split(" ").length > 1 ? username.split(" ")[0] : username;
    final noGuestName = name.toLowerCase() != 'guest' ? name : '';
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '${AppLocalizations.of(context).goodMorning} $noGuestName ☀️ ';
    } else if (hour < 18) {
      return '${AppLocalizations.of(context).goodAfternoon} $noGuestName 👋 ';
    } else {
      return '${AppLocalizations.of(context).goodEvening} $noGuestName 🌙';
    }
  }
}
