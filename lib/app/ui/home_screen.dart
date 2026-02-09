// ignore_for_file: public_member_api_docs, sort_constructors_first

import "package:auto_route/auto_route.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_adaptive_ui/flutter_adaptive_ui.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";

import "package:comby/app/bloc/app_bloc.dart";
import "package:comby/app/features/auth/features/login/bloc/login_bloc.dart";
import "package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart";
import "package:comby/app/features/chat/ui/chat_screen.dart";
import "package:comby/app/ui/custom_drawer.dart";
import "package:comby/core/core.dart";
import "package:comby/generated/l10n.dart";
import "package:google_fonts/google_fonts.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    getIt<ProfileBloc>()
        .add(FetchProfileInfoEvent(auth.currentUser?.uid ?? ''));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AppBloc>().add(InitializeLanguageEvent());
      // _checkAndShowPaywall();
    });
  }

  /// CHAT → gerçek fullscreen route (Scaffold YOK!)
  void _showChatModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ChatScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return AutoTabsRouter(
          routes: const [
            DashbordTabRouter(),
            ClosetTabRouter(),
            TryOnTabRouter(),
            ProfileTabRouter(),
          ],
          builder: (context, child, animation) {
            final tabsRouter = AutoTabsRouter.of(context);

            return Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: () {
                  // ⚠️ Chat açıkken unfocus tetiklenmez
                  if (ModalRoute.of(context)?.isCurrent ?? true) {
                    FocusScope.of(context).unfocus();
                  }
                },
                child: Scaffold(
                  key: _scaffoldKey,
                  appBar: (tabsRouter.activeIndex == 3 ||
                          tabsRouter.activeIndex == 2)
                      ? null
                      : AppBar(
                          centerTitle: true,
                          forceMaterialTransparency: true,
                          leading: IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {},
                          ),
                          title: Text(
                            'Comby',
                            style: GoogleFonts.balooBhai2(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () {
                                context.router
                                    .push(const SettingsScreenRoute());
                              },
                            ),
                          ],
                        ),
                  body: SafeArea(
                    bottom: true,
                    child: AdaptiveBuilder(
                      defaultBuilder: (_, __) => child,
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: _showChatModal,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(Icons.chat_bubble,
                        color: Colors.white, size: 28.sp),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  bottomNavigationBar: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    selectedFontSize: 10.sp,
                    unselectedFontSize: 9.sp,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(tabsRouter.activeIndex == 0
                            ? Icons.dashboard
                            : Icons.dashboard_outlined),
                        label: AppLocalizations.of(context).homeDashboard,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(tabsRouter.activeIndex == 1
                            ? Icons.checkroom
                            : Icons.checkroom_outlined),
                        label: AppLocalizations.of(context).homeCloset,
                      ),
                      const BottomNavigationBarItem(
                        icon: SizedBox(),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(tabsRouter.activeIndex == 2
                            ? Icons.history_edu
                            : Icons.history_edu_outlined),
                        label: AppLocalizations.of(context).homeTryOn,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(tabsRouter.activeIndex == 3
                            ? Icons.person
                            : Icons.person_outline),
                        label: AppLocalizations.of(context).profile,
                      ),
                    ],
                    currentIndex: _mapTabIndex(tabsRouter.activeIndex),
                    onTap: (index) {
                      if (index == 0) tabsRouter.setActiveIndex(0);
                      if (index == 1) tabsRouter.setActiveIndex(1);
                      if (index == 3) tabsRouter.setActiveIndex(2);
                      if (index == 4) tabsRouter.setActiveIndex(3);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _mapTabIndex(int routerIndex) {
    if (routerIndex == 0) return 0;
    if (routerIndex == 1) return 1;
    if (routerIndex == 2) return 3;
    if (routerIndex == 3) return 4;
    return 0;
  }
}
