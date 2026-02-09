import 'package:animate_do/animate_do.dart';
import 'package:auto_route/auto_route.dart';
import 'package:comby/core/injection/injection.dart';
import 'package:comby/core/services/mock_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: "Your AI Fashion Companion",
      description:
          "Comby analyzes your style, organizes your closet, and helps you look your best every day.",
      icon: Icons.checkroom,
      color: Colors.purple,
    ),
    OnboardingSlide(
      title: "Live Video Stylist",
      description:
          "Connect via video for real-time feedback on your current look. Your assistant can even suggest better alternatives from your own closet!",
      icon: Icons.videocam,
      color: Colors.blue,
    ),
    OnboardingSlide(
      title: "Advanced Al Chat Agent",
      description:
          "Your Al agent can search your wardrobe, check current weather, and manage your fashion missions with powerful built-in tools.",
      icon: Icons.psychology,
      color: Colors.orange,
    ),
    OnboardingSlide(
      title: "Jump Start Your Experience",
      description:
          "New here? We can load a sample wardrobe ensuring you can try all features immediately without adding items manually.",
      icon: Icons.rocket_launch,
      color: Colors.green,
      isActionSlide: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _slides[_currentPage].color.withOpacity(0.1),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Skip Button
                if (_currentPage < _slides.length - 1)
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () =>
                          _pageController.jumpToPage(_slides.length - 1),
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(height: 48.h),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      return _buildSlide(_slides[index]);
                    },
                  ),
                ),

                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      height: 8.h,
                      width: _currentPage == index ? 24.w : 8.w,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _slides[_currentPage].color
                            : Colors.grey[
                                600], // Further increased contrast for visibility
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Navigation Buttons or Action Buttons
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: _currentPage == _slides.length - 1
                      ? _isLoading
                          ? const CircularProgressIndicator()
                          : Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: ElevatedButton(
                                    onPressed: _completeWithMockData,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      "Yes, Load Demo Wardrobe",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                TextButton(
                                  onPressed: _completeWithoutMockData,
                                  child: Text(
                                    "No, Start Fresh",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )
                      : SizedBox(
                          width: double.infinity,
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _slides[_currentPage].color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              elevation: 8,
                              shadowColor:
                                  _slides[_currentPage].color.withOpacity(0.4),
                            ),
                            child: Text(
                              "Next",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            from: 20,
            duration: const Duration(milliseconds: 600),
            child: Container(
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: slide.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                slide.icon,
                size: 80.sp,
                color: slide.color,
              ),
            ),
          ),
          SizedBox(height: 48.h),
          FadeInUp(
            from: 20,
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            child: Text(
              slide.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          FadeInUp(
            from: 20,
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 600),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeWithMockData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final mockService = getIt<MockDataService>();
      await mockService.copyMockDataToUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Demo wardrobe loaded successfully! 🎉"),
            backgroundColor: Colors.green,
          ),
        );
        _finishOnboarding();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load demo data: $e"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completeWithoutMockData() async {
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (mounted) {
      context.router.pop();
    }
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isActionSlide;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isActionSlide = false,
  });
}
