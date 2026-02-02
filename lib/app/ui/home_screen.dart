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
import "package:comby/app/features/payment/ui/payment_screen.dart";
import "package:comby/app/ui/custom_drawer.dart";

import "package:comby/app/ui/widgets/comby_logo_small.dart";
import "package:comby/app/ui/widgets/total_credit_widget.dart";
import "package:comby/core/core.dart";

import "package:comby/core/services/paywall_manager.dart";
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
    getIt<ProfileBloc>()
        .add(FetchProfileInfoEvent(auth.currentUser?.uid ?? ''));

    // App dilini initialize et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AppBloc>().add(InitializeLanguageEvent());

      // 🎯 PAYWALL KONTROLÜ - Session başına 1 kez
      //  _checkAndShowPaywall();
    });

    super.initState();
  }

  /// Paywall gösterilmeli mi kontrol et ve göster
  Future<void> _checkAndShowPaywall() async {
    // Biraz bekle (UX için - ekran tam yüklendikten sonra)
    await Future.delayed(const Duration(milliseconds: 1500));

    // PaywallManager'dan kontrol et
    final shouldShow = await PaywallManager().shouldShowPaywall();

    if (shouldShow && mounted) {
      // Bottom sheet olarak göster
      _showPaywallBottomSheet();

      // İşaretle ki bu session'da bir daha gösterilmesin
      PaywallManager().markAsShown();
    }
  }

  /// Payment screen'i bottom sheet olarak göster
  void _showPaywallBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Full height
      backgroundColor:
          Colors.transparent, // Transparan yap ki backdrop görünsün
      barrierColor: Colors.black.withOpacity(0.5), // Backdrop (sabit kalır!)
      isDismissible: true, // Dışarı tıklayarak kapatılabilir
      enableDrag: true, // Aşağı çekip kapatılabilir
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9, // Ekranın %90'ı
        minChildSize: 0.5, // Minimum %50
        maxChildSize: 0.95, // Maximum %95
        snap: true, // Snap özelliği (kapatırken otomatik kapanır)
        snapSizes: const [0.9], // Snap noktası
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Drag handle (kapatma çubuğu)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Payment screen - isPaywall: true (back button gizli)
              const Expanded(
                child: PaymentsScreen(isPaywall: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Chat screen'i tam ekran modal (yeni sayfa) olarak göster
  void _showChatModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Comby AI Agent',
              style: GoogleFonts.balooBhai2(
                  fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.video_call),
                  onPressed: () {
                    context.router.push(const LiveStylistPageRoute());
                  })
            ],
            centerTitle: true,
          ),
          body: const ChatScreen(),
        ),
        fullscreenDialog: true, // Aşağıdan yukarı kayarak açılmasını sağlar
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (final context, final state) {
        return AutoTabsRouter(
          routes: [
            DashbordTabRouter(),
            ClosetTabRouter(),
            TryOnTabRouter(),
            ProfileTabRouter(),
          ],
          builder: (final context, final child, final animation) {
            final tabsRouter = AutoTabsRouter.of(context);
            return Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, loginBuilderState) {
                    return Scaffold(
                      key: _scaffoldKey,
                      drawer:
                          tabsRouter.activeIndex == 3 // Profile is now index 3
                              ? CustomDrawer(state: state)
                              : null,
                      // Update indices: Closet is 1, Try-On is 2, Profile is 3
                      appBar: ( // Closet
                              tabsRouter.activeIndex == 1 ||
                                  tabsRouter.activeIndex == 2) // Profile
                          ? null
                          : AppBar(
                              forceMaterialTransparency: true,
                              leading: GestureDetector(
                                onTap: () {
                                  _scaffoldKey.currentState?.openDrawer();
                                },
                                child: Icon(
                                  Icons.menu,
                                  color: context.baseColor,
                                ),
                              ),
                              leadingWidth: 64.w,
                              actionsPadding: EdgeInsets.only(right: 12.w),
                              title: Text(
                                'Comby',
                                style: GoogleFonts.balooBhai2(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700),
                              ),
                              actions: [
                                GestureDetector(
                                  onTap: () {
                                    context.router
                                        .push(const SettingsScreenRoute());
                                  },
                                  child: Icon(
                                    Icons.settings,
                                    color: context.baseColor,
                                  ),
                                ),
                              ],
                            ),
                      body: SafeArea(
                        child: AdaptiveBuilder(
                          defaultBuilder: (final BuildContext context,
                              final Screen screen) {
                            return child;
                          },
                        ),
                      ),
                      floatingActionButton: FloatingActionButton(
                        onPressed: _showChatModal,
                        elevation: 4,
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: const CircleBorder(),
                        child: Icon(Icons.chat_bubble,
                            color: Colors.white, size: 28.sp),
                      ),
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerDocked,
                      bottomNavigationBar: Container(
                        decoration: const BoxDecoration(),
                        child: BottomNavigationBar(
                          enableFeedback: true,
                          type: BottomNavigationBarType.fixed,
                          showSelectedLabels: true,
                          selectedFontSize: 10.sp,
                          unselectedFontSize: 9.sp,
                          showUnselectedLabels: true,
                          selectedLabelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          unselectedLabelStyle:
                              const TextStyle(fontWeight: FontWeight.w500),
                          items: <BottomNavigationBarItem>[
                            BottomNavigationBarItem(
                              icon: tabsRouter.activeIndex == 0
                                  ? const Icon(Icons.dashboard)
                                  : const Icon(Icons.dashboard_outlined),
                              label: AppLocalizations.of(context).homeDashboard,
                            ),
                            BottomNavigationBarItem(
                              icon: tabsRouter.activeIndex == 1
                                  ? const Icon(Icons.checkroom)
                                  : const Icon(Icons.checkroom_outlined),
                              label: AppLocalizations.of(context).homeCloset,
                            ),
                            // Chat Item Removed - Replaced by FAB space
                            const BottomNavigationBarItem(
                              icon: SizedBox(), // Görünmez placeholder
                              label: '', // Boş label
                            ),
                            BottomNavigationBarItem(
                              icon: tabsRouter.activeIndex == 2
                                  ? const Icon(Icons.history_edu)
                                  : const Icon(Icons.history_edu_outlined),
                              label: AppLocalizations.of(context).homeTryOn,
                            ),
                            BottomNavigationBarItem(
                              icon: tabsRouter.activeIndex == 3
                                  ? const Icon(
                                      Icons.person,
                                    )
                                  : const Icon(Icons.person_outline),
                              label: AppLocalizations.of(context).profile,
                            ),
                          ],
                          currentIndex:
                              _getBottomNavIndex(tabsRouter.activeIndex),
                          onTap: (value) {
                            if (value == 0) tabsRouter.setActiveIndex(0);
                            if (value == 1) tabsRouter.setActiveIndex(1);
                            // Value 2 is empty/FAB
                            if (value == 3)
                              tabsRouter.setActiveIndex(
                                  2); // TryOn (Index 2 in routes)
                            if (value == 4)
                              tabsRouter.setActiveIndex(
                                  3); // Profile (Index 3 in routes)
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _getBottomNavIndex(int routerIndex) {
    if (routerIndex == 0) return 0; // Dashboard
    if (routerIndex == 1) return 1; // Closet
    if (routerIndex == 2) return 2; // Chat
    if (routerIndex == 3) return 3; // Try-On
    if (routerIndex == 4) return 4; // Profile
    return 0;
  }
}
