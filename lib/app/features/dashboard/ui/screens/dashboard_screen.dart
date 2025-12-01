// ignore_for_file: public_member_api_docs, sort_constructors_first
import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:ginly/app/features/dashboard/ui/widgets/slider_widget.dart";
import "package:ginly/app/bloc/app_bloc.dart";

import "package:ginly/app/features/dashboard/ui/screens/videos_ai_effects_view.dart";
import "package:ginly/app/features/video_generate/bloc/video_generate_bloc.dart";
import "package:ginly/core/constants/layout_constants.dart";
import "package:ginly/core/core.dart";
import "package:ginly/generated/l10n.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController aiEffectsCategoriesTabbarController;
  late final PageController _pageController;

  int currentPage = 0;
  Timer? _pageTimer;

  void _startAutoSlide(int itemCount) {
    _pageTimer?.cancel();
    if (itemCount <= 1) return;

    _pageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        currentPage = (currentPage + 1) % itemCount;
        _pageController.animateToPage(currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    aiEffectsCategoriesTabbarController = TabController(length: 2, vsync: this);
    _pageController = PageController();

    getIt<AppBloc>().add(const GetAllAppDocsEvent());
    getIt<AppBloc>().add(const GetAllAppDocumentsEvent());
    getIt<AppBloc>().add(const GetGenerateCreditRequirementsEvent());
  }

  @override
  void dispose() {
    _pageTimer?.cancel();
    _pageController.dispose();
    aiEffectsCategoriesTabbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);

    return BlocConsumer<VideoGenerateBloc, VideoGenerateState>(
      listener: (context, state) {
        if (state.status == EventStatus.success) {
          tabsRouter.setActiveIndex(2);
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 16.h,
                          color: context.baseColor,
                          margin: const EdgeInsets.only(right: 8),
                        ),
                        Expanded(
                          child: Row(
                            spacing: 4.h,
                            children: [
                              Text(
                                AppLocalizations.of(context)
                                    .viralEffectsOnTiktok,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: context.baseColor,
                                        fontSize: 11.sp),
                              ),
                              Image.asset(
                                PngPaths.viralOnTiktok,
                                height: 12.h,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.router.push(AllEffectsScreenRoute());
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(context).allEffects,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: context.baseColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.sp,
                                      ),
                                ),
                                SizedBox(width: 3.w),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 10.sp,
                                  color: context.baseColor.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                LayoutConstants.tinyEmptyHeight,
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    BlocConsumer<AppBloc, AppState>(
                      listener: (context, state) {
                        // Bloc'ta hazırlanan trendingTemplates state'ini kullan
                        _startAutoSlide(state.trendingTemplates?.length ?? 0);
                      },
                      builder: (context, state) {
                        // Bloc'ta hazırlanan trendingTemplates state'ini kullan

                        if (state.trendingTemplates?.isEmpty ?? true) {
                          return const SizedBox.shrink();
                        }

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: AspectRatio(
                            aspectRatio: 1.8 / 1,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (value) {
                                setState(() {
                                  currentPage = value;
                                });
                              },
                              itemCount: state.trendingTemplates?.length ?? 0,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: SliderWidget(
                                    isForPayments: false,
                                    videoTemplate:
                                        state.trendingTemplates![index],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 16.h,
                      right: 8.h,
                      child: BlocBuilder<AppBloc, AppState>(
                        builder: (context, state) {
                          // Bloc'ta hazırlanan trendingTemplates state'ini kullan
                          final trendingTemplates =
                              state.trendingTemplates ?? [];

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              trendingTemplates.length,
                              (index) {
                                final isActive = index == currentPage;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: isActive ? 24.w : 8.w,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? context.white
                                        : context.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                LayoutConstants.defaultEmptyHeight,
                //  _buildEffectsCategoryRow(context),
                //  LayoutConstants.defaultEmptyHeight,
                Container(child: const VideosAiEffectsView()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEffectsCategoryRow(BuildContext context) {
    return Row(
      spacing: 8.h,
      children: [
        Expanded(
          child: _buildEffectsCategoryCard(
            context,
            title: 'Viral on TikTok',
            path: PngPaths.viralOnTiktok,
          ),
        ),
        Expanded(
          child: _buildEffectsCategoryCard(
            context,
            title: 'WTF Effects',
            path: null,
          ),
        ),
      ],
    );
  }

  Widget _buildEffectsCategoryCard(
    BuildContext context, {
    required String title,
    String? path,
  }) {
    return GestureDetector(
      onTap: () {
        // Handle tap event here
        // You can add onTap callback parameter if needed
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: context.baseColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.h,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.baseColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
            ),
            if (path != null)
              Image.asset(
                path,
                height: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}

 /*  TabBar(
                          labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          indicatorColor: Colors.transparent,
                          dividerColor: Colors.transparent,
                          controller: aiEffectsCategoriesTabbarController,
                          tabs: [
                            libraryCategorisTabbarChildWidget(
                                context, 0, 'Video', () {
                              changeTabbarMethod(0);
                            }),
                            libraryCategorisTabbarChildWidget(
                                context, 1, 'Image', () {
                              changeTabbarMethod(1);
                            }),
                          ],
                        ), */
  /*   IndexedStack(
                  index: aiEffectsCategoriesTabbarController.index,
                  children: const [
                    VideosAiEffectsView(),
                    Text('Image Templates')
                  ],
                ), */
/*   void changeTabbarMethod(int index) {
    aiEffectsCategoriesTabbarController.animateTo(index);
    setState(() {});
  } */

 /* 
 Widget libraryCategorisTabbarChildWidget(
    BuildContext context,
    int index,
    String title,
    void Function()? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
            color: aiEffectsCategoriesTabbarController.index == index
                ? context.baseColor
                : context.white,
            borderRadius: BorderRadius.circular(4),
            border: aiEffectsCategoriesTabbarController.index == index
                ? null
                : Border.all()),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: aiEffectsCategoriesTabbarController.index == index
                  ? context.white
                  : context.baseColor,
              fontWeight: aiEffectsCategoriesTabbarController.index == index
                  ? FontWeight.bold
                  : FontWeight.w500),
        ),
      ),
    );
  }
  */