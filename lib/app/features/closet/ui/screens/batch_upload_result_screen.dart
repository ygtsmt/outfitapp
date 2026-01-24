import 'package:auto_route/auto_route.dart';
import 'package:comby/core/constants/layout_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/closet/ui/screens/batch_upload_progress_screen.dart';
import 'package:comby/core/core.dart';

class BatchUploadResultScreen extends StatefulWidget {
  final BatchUploadResult result;

  const BatchUploadResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<BatchUploadResultScreen> createState() =>
      _BatchUploadResultScreenState();
}

class _BatchUploadResultScreenState extends State<BatchUploadResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDone() {
    // Pop all the way back to closet screen
    context.router.popUntilRoot();
  }

  void _onReview() {
    context.router.push(
      FailedPhotoReviewScreenRoute(failedPhotos: widget.result.failedPhotos),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final successCount = result.successfulItems.length;
    final failCount = result.failedPhotos.length;
    final totalCount = result.totalCount;
    final hasFailures = result.hasFailures;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'İşlem Tamamlandı',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                LayoutConstants.highEmptyHeight,
                // Animated Success/Warning Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasFailures
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      boxShadow: [
                        BoxShadow(
                          color: (hasFailures ? Colors.orange : Colors.green)
                              .withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      hasFailures
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_rounded,
                      size: 64.sp,
                      color: hasFailures ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
                LayoutConstants.highEmptyHeight,
                // Main Message
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        hasFailures
                            ? '$totalCount fotoğraftan $successCount\'${successCount == 1 ? 'i' : 'si'} başarıyla eklendi!'
                            : 'Tüm fotoğraflar başarıyla eklendi!',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (hasFailures) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '$failCount fotoğraf kıyafet olarak algılanamadı',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                LayoutConstants.highEmptyHeight,
                // Stats Cards
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.check_circle,
                        iconColor: Colors.green,
                        label: 'Başarılı',
                        value: successCount.toString(),
                      ),
                      SizedBox(width: 16.w),
                      _buildStatCard(
                        icon: Icons.error,
                        iconColor: Colors.red,
                        label: 'Başarısız',
                        value: failCount.toString(),
                      ),
                    ],
                  ),
                ),
                LayoutConstants.ultraEmptyHeight,
                // Action Buttons
                if (hasFailures) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _onReview,
                      icon: Icon(Icons.visibility, size: 20.sp),
                      label: Text(
                        'Başarısız Fotoğrafları Gözden Geçir',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        side: BorderSide(color: context.baseColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onDone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.baseColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Tamam',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
