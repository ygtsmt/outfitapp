import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:comby/core/extensions.dart';
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
      body: SafeArea(
        child: Container(
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
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: dominantColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                          child: GestureDetector(
                        onTap: () => context.router.pop(),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20.r)),
                          height: 48.h,
                          width: 48.w,
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24.h,
                          ),
                        ),
                      )),
                      SizedBox(
                        width: 16.w,
                      ),
                      Expanded(
                        flex: 4,
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
                            backgroundColor: context.baseColor.withBlue(200),
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
                                  height: 48.h,
                                  width: 48.h,
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
      ),
    );
  }
}
