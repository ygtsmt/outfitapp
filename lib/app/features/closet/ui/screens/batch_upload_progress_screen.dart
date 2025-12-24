import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/closet/bloc/closet_bloc.dart';
import 'package:ginly/app/features/closet/data/closet_usecase.dart';
import 'package:ginly/app/features/closet/models/closet_item_model.dart';
import 'package:ginly/app/features/closet/services/clothing_analysis_service.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/core/services/background_removal_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Result model for batch upload
class BatchUploadResult {
  final List<ClosetItem> successfulItems;
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

  final List<ClosetItem> _successfulItems = [];
  final List<FailedPhotoInfo> _failedPhotos = [];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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
      final autoCategory = ClosetItem.getCategoryFromSubcategory(subcategory);

      final item = ClosetItem(
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
    final progress = widget.imageFiles.isEmpty
        ? 0.0
        : (_currentIndex + 1) / widget.imageFiles.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Fotoğraflar İşleniyor'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              SizedBox(height: 24.h),

              // Circular Progress with Counter
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120.w,
                    height: 120.w,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.baseColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_currentIndex + 1}',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: context.baseColor,
                        ),
                      ),
                      Text(
                        '/ ${widget.imageFiles.length}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Current Photo Preview
              if (_currentIndex < widget.imageFiles.length)
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    height: 280.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.file(
                        widget.imageFiles[_currentIndex],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

              SizedBox(height: 24.h),

              // Status Text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  key: ValueKey(_currentStatus),
                  children: [
                    if (_isProcessing)
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: context.baseColor,
                        size: 24.sp,
                      ),
                    SizedBox(width: 12.w),
                    Text(
                      _currentStatus,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Remaining count
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Başarılı: ${_successfulItems.length}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    if (_failedPhotos.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Başarısız: ${_failedPhotos.length}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8.h,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(context.baseColor),
                ),
              ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
