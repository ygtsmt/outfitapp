import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palette_generator/palette_generator.dart';

class AIFashionCritiquePreviewScreen extends StatefulWidget {
  final File imageFile;

  const AIFashionCritiquePreviewScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<AIFashionCritiquePreviewScreen> createState() =>
      _AIFashionCritiquePreviewScreenState();
}

class _AIFashionCritiquePreviewScreenState
    extends State<AIFashionCritiquePreviewScreen> {
  PaletteGenerator? _paletteGenerator;

  @override
  void initState() {
    super.initState();
    _generatePalette();
  }

  Future<void> _generatePalette() async {
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      FileImage(widget.imageFile),
      size: const Size(200, 200),
      maximumColorCount: 20,
    );
    if (mounted) {
      setState(() {
        _paletteGenerator = paletteGenerator;
      });
    }
  }

  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    // Determine dynamic colors
    final dominantColor =
        _paletteGenerator?.dominantColor?.color ?? Colors.grey.shade200;
    final lightColor =
        _paletteGenerator?.lightVibrantColor?.color?.withOpacity(0.3) ??
            Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.8),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => context.router.pop(),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              lightColor,
              dominantColor.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text(
                'Fotoğrafı Onayla',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32.r),
                    boxShadow: [
                      BoxShadow(
                        color: dominantColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32.r),
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Container(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(32.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            _isAnalyzing ? null : () => context.router.pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          'Tekrar Çek',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isAnalyzing
                            ? null
                            : () async {
                                setState(() {
                                  _isAnalyzing = true;
                                });

                                if (mounted) {
                                  context.router.replace(
                                    AIFashionCritiqueResultScreenRoute(
                                        imageFile: widget.imageFile),
                                  );
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.black54,
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          elevation: 0,
                        ),
                        child: _isAnalyzing
                            ? SizedBox(
                                height: 24.h,
                                width: 24.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Analiz Et',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.auto_awesome, size: 20.sp),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
