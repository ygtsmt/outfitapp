import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/app/features/fit_check/services/fit_check_service.dart';
import 'package:comby/core/constants/layout_constants.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FitCheckResultScreen extends StatefulWidget {
  final File? imageFile;
  final FitCheckLog? log;

  const FitCheckResultScreen({
    super.key,
    this.imageFile,
    this.log,
  });

  @override
  State<FitCheckResultScreen> createState() => _FitCheckResultScreenState();
}

class _FitCheckResultScreenState extends State<FitCheckResultScreen> {
  bool _isAnalyzing = true;
  FitCheckLog? _currentLog;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.log != null) {
      _currentLog = widget.log;
      _isAnalyzing = false;
    } else if (widget.imageFile != null) {
      _startAnalysis();
    } else {
      _error = 'Görüntülenemedi.';
      _isAnalyzing = false;
    }
  }

  Future<void> _shareFitCheck() async {
    if (_currentLog?.imageUrl == null && widget.imageFile == null) return;
    try {
      String path;
      if (widget.imageFile != null) {
        path = widget.imageFile!.path;
      } else {
        path = await _downloadFile(_currentLog!.imageUrl);
      }
      await Share.shareXFiles([XFile(path)],
          text: 'Comby ile kombinimi inceledim! 🌟');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paylaşım hatası: $e')),
        );
      }
    }
  }

  Future<void> _downloadFitCheck() async {
    if (_currentLog?.imageUrl == null && widget.imageFile == null) return;
    try {
      String path;
      if (widget.imageFile != null) {
        path = widget.imageFile!.path;
      } else {
        path = await _downloadFile(_currentLog!.imageUrl);
      }
      await Gal.putImage(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf galeriye kaydedildi! ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydetme hatası: $e')),
        );
      }
    }
  }

  Future<String> _downloadFile(String url) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await Dio().download(url, path);
    return path;
  }

  Future<void> _startAnalysis() async {
    try {
      final service = GetIt.I<FitCheckService>();

      // Upload
      final imageUrl = await service.uploadFitCheckImage(widget.imageFile!);

      // Analyze
      final metadata = await service.analyzeFitCheckImage(widget.imageFile!);

      // Create Log
      final newLog = FitCheckLog(
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
        suggestions: metadata['suggestions'] != null
            ? List<String>.from(metadata['suggestions'])
            : null,
        isPublic: false,
      );

      // Save
      await service.saveFitCheck(newLog);

      if (mounted) {
        setState(() {
          _currentLog = newLog;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Analiz sırasında bir hata oluştu: $e';
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          if (widget.imageFile != null)
            Image.file(
              widget.imageFile!,
              fit: BoxFit.cover,
            )
          else if (_currentLog != null)
            CachedNetworkImage(
              imageUrl: _currentLog!.imageUrl,
              fit: BoxFit.cover,
            ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Header
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const BackButton(color: Colors.white),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _shareFitCheck,
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    LayoutConstants.lowEmptyWidth,
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _downloadFitCheck,
                        icon: const Icon(
                          Icons.download,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Analysis Content or Loading
          if (_isAnalyzing)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildAnalyzingState(),
            )
          else if (_currentLog != null)
            DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.25,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32.r)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(24.w, 32.w, 24.w, 24.w),
                    child: _buildResultContentBody(_currentLog!),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: const Color(0xFFFF416C),
            size: 48.w,
          ),
          SizedBox(height: 24.h),
          Text(
            'Kombinin Analiz Ediliyor...',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Gemini AI, tarzını, renklerini ve uyumunu inceliyor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildResultContentBody(FitCheckLog log) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // AI Description (Motive Message)
        if (log.aiDescription != null) ...[
          Center(
            child: Text(
              '✨ ${log.aiDescription} ✨',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF8E2DE2),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],

        // Overall Style Tag
        if (log.overallStyle != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.style, size: 16.sp, color: Colors.grey[700]),
                SizedBox(width: 6.w),
                Text(
                  log.overallStyle!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

        SizedBox(height: 16.h),

        // Detected Items
        if (log.detectedItems != null && log.detectedItems!.isNotEmpty) ...[
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: log.detectedItems!.map((item) {
              return Chip(
                label: Text(
                  item,
                  style: TextStyle(fontSize: 12.sp),
                ),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[200]!),
                padding: EdgeInsets.all(4.w),
              );
            }).toList(),
          ),
          SizedBox(height: 24.h),
        ],

        // Suggestions Section (New)
        if (log.suggestions != null && log.suggestions!.isNotEmpty) ...[
          Text(
            "Stil Önerileri",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          ...log.suggestions!.map((suggestion) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Icon(
                        Icons.insights, // or auto_awesome
                        size: 16.sp,
                        color: const Color(0xFFFF416C),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: 24.h),
        ],

        // Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.router.pushAndPopUntil(
                const HomeScreenRoute(),
                predicate: (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 0,
            ),
            child: Text(
              "Ana Sayfa",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
