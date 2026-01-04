import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/closet/bloc/closet_bloc.dart';
import 'package:ginfit/app/features/closet/data/closet_usecase.dart';
import 'package:ginfit/app/features/closet/models/model_item_model.dart';
import 'package:ginfit/app/features/closet/services/model_analysis_service.dart';
import 'package:ginfit/core/core.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Result model for batch model upload
class BatchModelUploadResult {
  final List<ModelItem> successfulItems;
  final List<FailedModelInfo> failedPhotos;

  BatchModelUploadResult({
    required this.successfulItems,
    required this.failedPhotos,
  });

  int get totalCount => successfulItems.length + failedPhotos.length;
  bool get hasFailures => failedPhotos.isNotEmpty;
}

/// Info about a failed model photo
class FailedModelInfo {
  final File imageFile;
  final String reason;

  FailedModelInfo({
    required this.imageFile,
    required this.reason,
  });
}

class BatchModelUploadProgressScreen extends StatefulWidget {
  final List<File> imageFiles;

  const BatchModelUploadProgressScreen({
    super.key,
    required this.imageFiles,
  });

  @override
  State<BatchModelUploadProgressScreen> createState() =>
      _BatchModelUploadProgressScreenState();
}

class _BatchModelUploadProgressScreenState
    extends State<BatchModelUploadProgressScreen>
    with SingleTickerProviderStateMixin {
  final ModelAnalysisService _analysisService = ModelAnalysisService();

  int _currentIndex = 0;
  bool _isProcessing = true;
  String _currentStatus = 'Hazırlanıyor...';

  final List<ModelItem> _successfulItems = [];
  final List<FailedModelInfo> _failedPhotos = [];

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
        _currentStatus = 'Model analiz ediliyor...';
      });

      // Step 1: AI Analysis
      final analysisResult = await _analysisService.analyzeModel(imageFile);

      // Check if valid model image
      final isValid = analysisResult['isValidModel']?.toLowerCase() == 'true';

      if (!isValid) {
        final reason = analysisResult['invalidReason'] ??
            'Bu fotoğraf kıyafet giydirilebilecek bir model değil';
        _failedPhotos.add(FailedModelInfo(
          imageFile: imageFile,
          reason: reason,
        ));
        return;
      }

      setState(() {
        _currentStatus = 'Yükleniyor...';
      });

      // Step 2: Upload image
      final closetUseCase = getIt<ClosetUseCase>();
      final imageUrl = await closetUseCase.uploadModelImage(imageFile);

      setState(() {
        _currentStatus = 'Kaydediliyor...';
      });

      // Step 3: Create model item with AI-extracted data
      final suggestedName = analysisResult['suggestedName'];
      final personCountStr = analysisResult['personCount'] ?? '1';
      final personCount = int.tryParse(personCountStr) ?? 1;

      final item = ModelItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: imageUrl,
        name: suggestedName,
        personCount: personCount,
        bodyPart: analysisResult['bodyPart'],
        gender: analysisResult['gender'],
        bodyType: analysisResult['bodyType'],
        pose: analysisResult['pose'],
        skinTone: analysisResult['skinTone'],
        aiPrompt: analysisResult['aiPrompt'],
        createdAt: DateTime.now(),
      );

      // Add to bloc
      getIt<ClosetBloc>().add(AddModelItemEvent(item));

      _successfulItems.add(item);
    } catch (e) {
      _failedPhotos.add(FailedModelInfo(
        imageFile: imageFile,
        reason: 'İşlem hatası: ${e.toString()}',
      ));
    }
  }

  void _navigateToResult() {
    final result = BatchModelUploadResult(
      successfulItems: _successfulItems,
      failedPhotos: _failedPhotos,
    );

    context.router.replace(
      BatchModelUploadResultScreenRoute(result: result),
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
        title: const Text('Modeller İşleniyor'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                SizedBox(height: 24.h),

                // Current Photo Preview with Counter
                if (_currentIndex < widget.imageFiles.length)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 450.h,
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
                        // Counter Overlay
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${widget.imageFiles.length}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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

                SizedBox(height: 40.h),

                // Remaining count
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(context.baseColor),
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
