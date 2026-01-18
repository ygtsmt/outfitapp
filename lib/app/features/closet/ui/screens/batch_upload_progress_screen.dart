import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/closet/bloc/closet_bloc.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/app/features/closet/services/clothing_analysis_service.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/services/background_removal_service.dart';

/// Result model for batch upload
class BatchUploadResult {
  final List<WardrobeItem> successfulItems;
  final List<FailedPhotoInfo> failedPhotos;

  BatchUploadResult({
    required this.successfulItems,
    required this.failedPhotos,
  });

  int get totalCount => successfulItems.length + failedPhotos.length;
  bool get hasFailures => failedPhotos.isNotEmpty;
}

/// Info about a failed photo
class FailedPhotoInfo {
  final File imageFile;
  final String reason;

  FailedPhotoInfo({
    required this.imageFile,
    required this.reason,
  });
}

class BatchUploadProgressScreen extends StatefulWidget {
  final List<File> imageFiles;

  const BatchUploadProgressScreen({
    super.key,
    required this.imageFiles,
  });

  @override
  State<BatchUploadProgressScreen> createState() =>
      _BatchUploadProgressScreenState();
}

class _BatchUploadProgressScreenState extends State<BatchUploadProgressScreen>
    with SingleTickerProviderStateMixin {
  final ClothingAnalysisService _analysisService = ClothingAnalysisService();
  final BackgroundRemovalService _backgroundRemovalService =
      BackgroundRemovalService();

  int _currentIndex = 0;
  bool _isProcessing = true;
  String _currentStatus = 'Hazırlanıyor...';

  final List<WardrobeItem> _successfulItems = [];
  final List<FailedPhotoInfo> _failedPhotos = [];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _startProcessing();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startProcessing() async {
    for (int i = 0; i < widget.imageFiles.length; i++) {
      if (!mounted) return;

      setState(() {
        _currentIndex = i;
        _currentStatus = 'AI ile analiz ediliyor...';
      });

      _animationController.forward(from: 0);

      await _processPhoto(widget.imageFiles[i]);
    }

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    // Navigate to result screen
    _navigateToResult();
  }

  Future<void> _processPhoto(File imageFile) async {
    try {
      setState(() {
        _currentStatus = 'AI ile analiz ediliyor...';
      });

      // Step 1: AI Analysis
      final analysisResult = await _analysisService.analyzeClothing(imageFile);

      // Check if valid fashion item
      final isValid =
          analysisResult['isValidFashionItem']?.toLowerCase() == 'true';

      if (!isValid) {
        final reason = analysisResult['invalidReason'] ??
            'Bu fotoğraf bir kıyafet veya aksesuar değil';
        _failedPhotos.add(FailedPhotoInfo(
          imageFile: imageFile,
          reason: reason,
        ));
        return;
      }

      setState(() {
        _currentStatus = 'Arka plan kaldırılıyor...';
      });

      // Step 2: Upload and remove background
      final closetUseCase = getIt<ClosetUseCase>();

      // Upload original for fal.ai to access
      final tempOriginalUrl = await closetUseCase.uploadClosetImage(imageFile);

      String finalImageUrl;
      try {
        setState(() {
          _currentStatus = 'Görsel işleniyor...';
        });

        final falAiTransparentUrl =
            await _backgroundRemovalService.removeBackground(tempOriginalUrl);

        final transparentBytes = await _backgroundRemovalService
            .downloadImageBytes(falAiTransparentUrl);

        finalImageUrl =
            await closetUseCase.uploadTransparentClosetImage(transparentBytes);

        await closetUseCase.deleteImageFromStorage(tempOriginalUrl);
      } catch (e) {
        // Background removal failed, keep original
        debugPrint('Background removal failed: $e');
        finalImageUrl = tempOriginalUrl;
      }

      setState(() {
        _currentStatus = 'Kaydediliyor...';
      });

      // Step 3: Create closet item
      final subcategory = analysisResult['subcategory'];
      final autoCategory = WardrobeItem.getCategoryFromSubcategory(subcategory);

      final item = WardrobeItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: finalImageUrl,
        category: autoCategory,
        subcategory: subcategory,
        color: analysisResult['color'],
        pattern: analysisResult['pattern'],
        season: analysisResult['season'],
        material: analysisResult['material'],
        brand: analysisResult['brand'],
        createdAt: DateTime.now(),
      );

      // Add to bloc
      getIt<ClosetBloc>().add(AddClosetItemEvent(item));

      _successfulItems.add(item);
    } catch (e) {
      _failedPhotos.add(FailedPhotoInfo(
        imageFile: imageFile,
        reason: 'İşlem hatası: ${e.toString()}',
      ));
    }
  }

  void _navigateToResult() {
    final result = BatchUploadResult(
      successfulItems: _successfulItems,
      failedPhotos: _failedPhotos,
    );

    context.router.replace(
      BatchUploadResultScreenRoute(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current file
    final currentFile = _currentIndex < widget.imageFiles.length
        ? widget.imageFiles[_currentIndex]
        : widget.imageFiles.last;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image (Full Screen)
          Image.file(
            currentFile,
            fit: BoxFit.cover,
          ),

          // 2. Black Overlay (for readability)
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // 3. Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Counter Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20.r),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${_currentIndex + 1} / ${widget.imageFiles.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Center Progress Circle
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 100.w,
                      height: 100.w,
                      child: Stack(
                        fit: StackFit.passthrough,
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _isProcessing ? null : 0,
                            strokeWidth: 3,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                          Center(
                            child: Text(
                              '${((_currentIndex + 1) / widget.imageFiles.length * 100).toInt()}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // animated status text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _currentStatus,
                        key: ValueKey(_currentStatus),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Bottom Stats Card
                Container(
                  margin: EdgeInsets.all(24.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF4CAF50), // Bright Green
                        label: 'Başarılı',
                        value: _successfulItems.length.toString(),
                      ),
                      if (_failedPhotos.isNotEmpty) ...[
                        Container(
                          width: 1,
                          height: 40.h,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _buildStatItem(
                          icon: Icons.error_outline,
                          color: const Color(0xFFFF5252), // Bright Red
                          label: 'Başarısız',
                          value: _failedPhotos.length.toString(),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
