import 'package:comby/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:auto_route/auto_route.dart';
import 'package:comby/core/services/wrapped_data_service.dart';
import 'package:comby/app/features/wrapped/models/wrapped_result.dart';

/// Style Wrapped Card - Spotify Wrapped-style feature
/// Showcases Gemini 3 Flash's 1M token context window
class StyleWrappedCard extends StatefulWidget {
  const StyleWrappedCard({super.key});

  @override
  State<StyleWrappedCard> createState() => _StyleWrappedCardState();
}

class _StyleWrappedCardState extends State<StyleWrappedCard> {
  bool _isLoading = true;
  bool _hasWrapped = false;
  Map<String, dynamic>? _existingData;

  @override
  void initState() {
    super.initState();
    _checkWrappedStatus();
  }

  Future<void> _checkWrappedStatus() async {
    final service = GetIt.I<WrappedDataService>();
    final year = DateTime.now().year;
    final exists = await service.hasWrappedForYear(year);

    // Pre-fetch if exists to pass it directly
    if (exists) {
      _existingData = await service.getWrappedResult(year);
    }

    if (mounted) {
      setState(() {
        _hasWrapped = exists;
        _isLoading = false;
      });
    }
  }

  void _onViewTap() {
    if (_existingData != null) {
      final result = WrappedResult.fromJson(_existingData!);
      // Note: We might need to handle images separately or let the screen fetch them.
      // For now, let's pass the result and let the screen rebuild image map from user data if needed?
      // Actually, passing existingResult skips generation. Images are built from collectedUserData.
      // StyleWrappedScreen logic: if existingResult provided, it skips generation.
      // BUT it needs existingImages too.
      // To keep it simple, let's just pass the result. The screen might need to fetch images again.
      // Wait, StyleWrappedScreen needs itemImages for PowerPieces.
      // If we pass existingResult only, itemImages will be empty unless we also pass them or fetch them.
      // Let's rely on WrappedDataService to collect user data quickly just for images?
      // Or better: Modify StyleWrappedScreen to fetch images even if result exists.

      // Let's modify StyleWrappedScreen slightly to fetch images if existingResult is passed but images are missing.
      // For now, let's just navigate. We'll fix items afterwards if they are missing images.
      context.router.push(StyleWrappedScreenRoute(existingResult: result));
    }
  }

  void _onCreateTap() {
    // Force new generation
    context.router.push(StyleWrappedScreenRoute());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(); // Or a shimmer placeholder

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B46C1), Color(0xFFEC4899), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // Title
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 28.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "Your Style Wrapped ${DateTime.now().year.toString()}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Year badge

              SizedBox(height: 16.h),

              // Powered by badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      "Powered by Gemini 3 Flash",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // 1M token badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      "1M Token Context",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8.h,
              ),

              // Action Buttons
              if (_hasWrapped) ...[
                _buildButton(
                  text: "View Your Wrapped",
                  icon: Icons.play_arrow_rounded,
                  onTap: _onViewTap,
                  isPrimary: true,
                ),
                SizedBox(height: 12.h),
                _buildButton(
                  text: "Create New",
                  icon: Icons.refresh_rounded,
                  onTap: _onCreateTap,
                  isPrimary: false,
                ),
              ] else
                _buildButton(
                  text: "Create Your Wrapped",
                  icon: Icons.auto_awesome,
                  onTap: _onCreateTap,
                  isPrimary: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
            border: isPrimary
                ? null
                : Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isPrimary ? const Color(0xFF6B46C1) : Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                icon,
                color: isPrimary ? const Color(0xFF6B46C1) : Colors.white,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
