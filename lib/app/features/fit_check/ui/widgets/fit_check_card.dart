import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:comby/app/features/fit_check/ui/screens/fit_check_result_screen.dart';
import 'package:comby/core/core.dart'; // Added for ReusableGalleryPicker
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/app/features/fit_check/services/fit_check_service.dart';
import 'package:comby/app/features/fit_check/ui/widgets/streak_widget.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:comby/generated/l10n.dart';

class FitCheckCard extends StatefulWidget {
  const FitCheckCard({super.key});

  @override
  State<FitCheckCard> createState() => _FitCheckCardState();
}

class _FitCheckCardState extends State<FitCheckCard> {
  Future<void> _showSelectionSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 8.h),

            // Camera Option
            _buildOptionCard(
              icon: Icons.camera_alt_outlined,
              title: AppLocalizations.of(context).takePhoto,
              color: const Color(0xFFFF416C),
              onTap: () {
                Navigator.pop(sheetContext);
                _takePhoto();
              },
            ),
            SizedBox(height: 4.h),

            // Gallery Option
            _buildOptionCard(
              icon: Icons.photo_library_outlined,
              title: AppLocalizations.of(context).selectFromGallery,
              color: const Color(0xFF8E2DE2),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;
    _navigateToResult(File(pickedFile.path));
  }

  Future<void> _pickFromGallery() async {
    final result = await ReusableGalleryPicker.show(
      context: context,
      title: AppLocalizations.of(context).fitCheckPhoto,
      mode: GallerySelectionMode.single,
    );

    if (result?.singleFile != null) {
      _navigateToResult(result!.singleFile!);
    }
  }

  void _navigateToResult(File imageFile) {
    if (!mounted) return;
    context.router.push(FitCheckResultScreenRoute(imageFile: imageFile));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE94057), Color(0xFFF27121)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFE94057).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showSelectionSheet,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              spacing: 8.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context).dailyFitCheck,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            AppLocalizations.of(context).dailyFitCheckSubtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const StreakWidget(isOverlay: true),
                    GestureDetector(
                      onTap: () {
                        context.router
                            .push(const FitCheckCalendarScreenRoute());
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4), width: 1.5),
                        ),
                        child: Row(
                          spacing: 4.w,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context).history,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                            Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
