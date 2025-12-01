import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/dashboard/ui/widgets/slider_widget.dart';
import 'package:ginly/app/features/payment/ui/widgets/payment_watch_ad_button.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/app/data/models/features_doc_model.dart';
import 'package:ginly/generated/l10n.dart';

class PaymentHeaderWidget extends StatefulWidget {
  final List<VideoTemplate> trendingTemplates;
  final VoidCallback? onBackPressed;
  final bool? isPaywall;

  const PaymentHeaderWidget({
    super.key,
    required this.trendingTemplates,
    this.onBackPressed,
    this.isPaywall = false,
  });

  @override
  State<PaymentHeaderWidget> createState() => _PaymentHeaderWidgetState();
}

class _PaymentHeaderWidgetState extends State<PaymentHeaderWidget> {
  late final PageController _pageController;
  Timer? _pageAutoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageAutoScrollTimer?.cancel();
    super.dispose();
  }

  void _startAutoScroll() {
    _pageAutoScrollTimer?.cancel();
    if (widget.trendingTemplates.length <= 1) return;

    _pageAutoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.trendingTemplates.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        _currentPage = nextPage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            // Slider
            AspectRatio(
              aspectRatio: widget.isPaywall ?? false ? 1.8 / 1 : 1.5 / 1,
              child: ClipRRect(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) {
                    _currentPage = value;
                  },
                  itemCount: widget.trendingTemplates.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      child: SliderWidget(
                        isForPayments: true,
                        videoTemplate: widget.trendingTemplates[index],
                      ),
                    );
                  },
                ),
              ),
            ),

            // Overlay
            Positioned.fill(
              child: ClipRRect(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              top: 16.h,
              right: 8.h,
              child: PaymentWatchAdButton(),
            ),

            // Logo ve Title
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      PngPaths.logo,
                      height: 60.h,
                      color: context.white,
                    ),
                    Text(
                      'Ginly AI',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Page Indicator

            // Back Button - Sadece onBackPressed varsa göster
            widget.onBackPressed != null
                ? Positioned(
                    top: 32.h,
                    left: 8.h,
                    child: BackButton(
                      color: Colors.white,
                      onPressed: widget.onBackPressed,
                    ))
                : Positioned(
                    top: 8.h,
                    left: 8.h,
                    child: Container(
                      margin: EdgeInsets.only(top: 8.h),
                      child: IconButton(
                        onPressed: () {
                          // Eğer giriş yapılmış hesap yoksa guest olarak giriş yap
                          context.router.pop();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 24.sp,
                          color: context.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: context.baseColor,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
