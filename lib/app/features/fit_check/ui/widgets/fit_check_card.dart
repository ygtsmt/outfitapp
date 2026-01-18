import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/app/features/fit_check/services/fit_check_service.dart';
import 'package:comby/app/features/fit_check/ui/widgets/streak_widget.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FitCheckCard extends StatefulWidget {
  const FitCheckCard({super.key});

  @override
  State<FitCheckCard> createState() => _FitCheckCardState();
}

class _FitCheckCardState extends State<FitCheckCard> {
  bool _isProcessing = false;

  Future<void> _takeFitCheck() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    if (!mounted) return;

    // Show preview and confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _FitCheckPreviewDialog(imageFile: File(pickedFile.path)),
    );

    if (confirmed == true) {
      _processFitCheck(File(pickedFile.path));
    }
  }

  Future<void> _processFitCheck(File image) async {
    setState(() => _isProcessing = true);

    try {
      final service = GetIt.I<FitCheckService>();

      // Upload
      final imageUrl = await service.uploadFitCheckImage(image);

      // Analyze
      final metadata = await service.analyzeFitCheckImage(image);

      // Save
      final log = FitCheckLog(
        id: DateTime.now().toIso8601String(),
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        colorPalette: metadata['colorPalette'] != null
            ? Map<String, double>.from(metadata['colorPalette'])
            : null,
        overallStyle: metadata['overallStyle'],
        detectedItems: metadata['detectedItems'] != null
            ? List<String>.from(metadata['detectedItems'])
            : null,
        aiDescription: metadata['aiDescription'],
        isPublic: false,
      );

      await service.saveFitCheck(log);

      if (!mounted) return;

      // Show Success
      showDialog(
        context: context,
        builder: (context) => _FitCheckSuccessDialog(log: log),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
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
          onTap: _isProcessing ? null : _takeFitCheck,
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
                      child: _isProcessing
                          ? LoadingAnimationWidget.fourRotatingDots(
                              color: Colors.white,
                              size: 24.w,
                            )
                          : Icon(
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
                                'Günlük Fit Check',
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
                            'Bugün ne giydin? Outfit check yapalım mı?',
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
                              "History",
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

class _FitCheckPreviewDialog extends StatelessWidget {
  final File imageFile;

  const _FitCheckPreviewDialog({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bu fotoğraf nasıl?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
              height: 300.h,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Analiz Et 🔥'),
        ),
      ],
    );
  }
}

class _FitCheckSuccessDialog extends StatelessWidget {
  final FitCheckLog log;

  const _FitCheckSuccessDialog({required this.log});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Harika Görünüyorsun! ✨',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                log.imageUrl,
                height: 200.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16.h),
            if (log.aiDescription != null)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  log.aiDescription!,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.purple.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 12.h),
            if (log.overallStyle != null)
              Text('Tarz: ${log.overallStyle}',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                context.router.push(DashbordTabRouter());
              },
              child: Text('Harika!'),
            ),
          ],
        ),
      ),
    );
  }
}
