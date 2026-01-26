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
import 'package:comby/app/features/closet/ui/widgets/wardrobe_analytics_widget.dart';
import 'package:comby/app/features/closet/ui/widgets/fit_checks_tab_content.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:comby/app/features/closet/services/closet_analysis_service.dart';
import 'package:get_it/get_it.dart';
import 'package:fl_chart/fl_chart.dart';

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
  WardrobeStats? _stats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();

    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: ClosetScreen.tabNotifier.value,
    );

    ClosetScreen.tabNotifier.addListener(_handleTabChange);
  }

  Future<void> _loadStats() async {
    try {
      final stats = await GetIt.I<WardrobeAnalysisService>().getWardrobeStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
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

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 1. Premium Header with Greeting and Analytics
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderTop(context),
                    ],
                  ),
                ),
              ),

              // 2. Sticky TabBar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  maxHeight: 36.h,
                  minHeight: 36.h,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(),
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Center(
                          child: TabBar(
                            padding: EdgeInsets.only(left: 12.w, right: 12.w),
                            tabAlignment: TabAlignment.start,
                            controller: _tabController,
                            isScrollable: true,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor,
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelColor: Colors.white,
                            unselectedLabelColor: context.baseColor,
                            labelStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                            tabs: [
                              _buildTab(AppLocalizations.of(context).wardrobe),
                              _buildTab(AppLocalizations.of(context).models),
                              _buildTab(AppLocalizations.of(context).combines),
                              _buildTab(AppLocalizations.of(context).critiques),
                              _buildTab(AppLocalizations.of(context).fitChecks),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: const [
              WardrobeTabContent(),
              ModelsTabContent(),
              CombinesTabContent(),
              CritiquesTabContent(),
              FitChecksTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        alignment: Alignment.center,
        child: Text(label),
      ),
    );
  }

  Widget _buildHeaderTop(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Capsule Score Card (Moved to Left)
        Container(
          height: 52.w,
          constraints: BoxConstraints(minWidth: 52.w),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4C40F7).withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF4C40F7).withOpacity(0.08),
            ),
          ),
          child: _AddressCapsuleScore(
            isLoading: _isLoadingStats,
            score: _stats?.capsuleScore,
          ),
        ),

        if (!_isLoadingStats && _stats != null) ...[
          // Pieces Count & Color Chart
          Expanded(
            child: Container(
              height: 52.w,
              margin: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4C40F7).withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF4C40F7).withOpacity(0.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _stats != null
                              ? AppLocalizations.of(context)
                                  .piecesCount(_stats!.totalItems)
                              : AppLocalizations.of(context).piecesCount(0),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4C40F7),
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          AppLocalizations.of(context).wardrobeLabel,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tiny Pie Chart
                  Container(
                    height: 55.w,
                    width: 55.w,
                    margin: EdgeInsets.all(0),
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 0,
                        sections: _getChartSections(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else
          Spacer(),

        // Filter Button (New on Right)
        Container(
          height: 52.w,
          width: 52.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showFilterBottomSheet,
              borderRadius: BorderRadius.circular(30.r),
              child: Icon(
                Icons.tune_rounded,
                color: Colors.black87,
                size: 24.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(height: 24.h),
            Text(
              AppLocalizations.of(context).filterOptions,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            // Example Filter Options
            _buildFilterOption(AppLocalizations.of(context).category),
            _buildFilterOption(AppLocalizations.of(context).color),
            _buildFilterOption(AppLocalizations.of(context).season),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
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

  // Removed _getGreeting method
  List<PieChartSectionData> _getChartSections() {
    if (_stats == null) return [];

    final sortedColors = _stats!.colorDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topColors = sortedColors.take(5).toList();

    return topColors.map((e) {
      return PieChartSectionData(
          color: _getColorFromName(e.key),
          value: e.value.toDouble(),
          title: '',
          radius: 25, // Fill the container height (50w / 2)
          showTitle: false);
    }).toList();
  }

  // Helper to map color names to Flutter Colors (Copied from Analytics Widget)
  Color _getColorFromName(String name) {
    final lowerName = name.toLowerCase();
    switch (lowerName) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.grey.shade200;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'blue':
        return Colors.blue;
      case 'dark blue':
      case 'navy':
        return Colors.blue.shade900;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'beige':
        return Color(0xFFF5F5DC);
      default:
        // Simple fallback
        if (lowerName.contains('blue')) return Colors.blue;
        if (lowerName.contains('red')) return Colors.red;
        if (lowerName.contains('green')) return Colors.green;
        return Colors.teal;
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _AddressCapsuleScore extends StatelessWidget {
  final bool isLoading;
  final int? score;

  const _AddressCapsuleScore({
    required this.isLoading,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 48.w,
        child: Center(
          child: SizedBox(
            height: 16.w,
            width: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF4C40F7),
            ),
          ),
        ),
      );
    }

    final displayScore = score ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 4.w),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 32.w,
              width: 32.w,
              child: CircularProgressIndicator(
                value: displayScore / 100,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF4C40F7),
                strokeWidth: 4,
              ),
            ),
            Icon(
              Icons.checkroom_rounded,
              size: 16.sp,
              color: const Color(0xFF4C40F7),
            ),
          ],
        ),
        SizedBox(width: 8.w),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "%$displayScore",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF4C40F7),
                height: 1.0,
              ),
            ),
            Text(
              AppLocalizations.of(context).capsuleLabel,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                height: 1.0,
              ),
            ),
          ],
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
