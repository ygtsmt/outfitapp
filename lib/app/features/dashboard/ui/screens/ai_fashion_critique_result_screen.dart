import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:comby/app/features/closet/services/clothing_analysis_service.dart';
import 'package:comby/app/features/closet/ui/closet_screen.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIFashionCritiqueResultScreen extends StatefulWidget {
  final File imageFile;

  const AIFashionCritiqueResultScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<AIFashionCritiqueResultScreen> createState() =>
      _AIFashionCritiqueResultScreenState();
}

class _AIFashionCritiqueResultScreenState
    extends State<AIFashionCritiqueResultScreen> with TickerProviderStateMixin {
  final ClothingAnalysisService _analysisService = ClothingAnalysisService();
  bool _isLoading = true;
  String? _error;

  // Results
  int _score = 0;
  String _style = '';
  String _colorHarmony = '';
  List<String> _feedback = [];

  // Animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _startAnalysis();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    try {
      final result = await _analysisService.analyzeOutfit(widget.imageFile);

      if (mounted) {
        setState(() {
          _score = result['score'] as int;
          _style = result['style'] as String;
          _colorHarmony = result['colorHarmony'] as String;
          _feedback = result['feedback'] as List<String>;
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.only(left: 8.w),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: const BackButton(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image & Score Area
            SizedBox(
              height: 480.h,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(48.r)),
                    child: SizedBox(
                      height: 480.h,
                      width: double.infinity,
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Premium Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(48.r)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: const [0.4, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Floating Score Card
                  Positioned(
                    bottom: -60.h,
                    child: _buildAnimatedScoreCircle(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Staggered Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Modern Stats Cards
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.2), end: Offset.zero)
                          .animate(_fadeAnimation),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModernInfoCard(
                              icon: Icons.checkroom_rounded,
                              label: 'Tespit Edilen Tarz',
                              value: _style,
                              color: const Color(0xFF7E57C2), // Premium Purple
                              delay: 0,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildModernInfoCard(
                              icon: Icons.palette_rounded,
                              label: 'Renk Uyumu',
                              value: _colorHarmony,
                              color: const Color(0xFFFF7043), // Premium Orange
                              delay: 200,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // 2. Feedback Section Header
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.auto_awesome,
                              color: Colors.white, size: 20.sp),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          'Stilist Görüşleri',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // 3. Feedback List
                  ..._feedback.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tip = entry.value;
                    return _buildModernFeedbackCard(tip, index);
                  }).toList(),

                  SizedBox(height: 40.h),

                  // 4. Bottom Buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      children: [
                        // Save Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving ? null : _saveCritique,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(
                                  color: Colors.black, width: 2),
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    height: 24.h,
                                    width: 24.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    'Kaydet',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Done Button
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: () => context.router.navigate(
                              const HomeScreenRoute(
                                children: [
                                  DashbordTabRouter(),
                                ],
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Harika!',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSaving = false;

  Future<void> _saveCritique() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Upload Image
      final imageUrl = await _analysisService.uploadCritiqueImage(
        widget.imageFile,
        user.uid,
      );

      // 2. Save Data
      await _analysisService.saveCritique(user.uid, {
        'imageUrl': imageUrl,
        'score': _score,
        'style': _style,
        'colorHarmony': _colorHarmony,
        'feedback': _feedback,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kombin değerlendirmesi kaydedildi!')),
        );

        // Force open Critiques tab
        ClosetScreen.tabNotifier.value = 3;

        // Navigate to Closet > Critiques
        context.router.navigate(
          const HomeScreenRoute(
            children: [
              ClosetTabRouter(),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildAnimatedScoreCircle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _score.toDouble()),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        final percentage = value / 10;
        final color = _getScoreColor(value.toInt());

        return Container(
          width: 140.w,
          height: 140.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress Ring
              SizedBox(
                width: 110.w,
                height: 110.w,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 10,
                  color: color,
                  backgroundColor: Colors.grey.shade100,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Score Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    // Format to remove trailing .0
                    value.toStringAsFixed(1).replaceAll('.0', ''),
                    style: TextStyle(
                      fontSize: 42.sp,
                      fontWeight: FontWeight.w900,
                      color: color,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  ),
                  Text(
                    'PUAN',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required int delay,
  }) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: color.withOpacity(0.1), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 26.sp),
                ),
                SizedBox(height: 16.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernFeedbackCard(String tip, int index) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: 400 + (index * 150))),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, opacity, child) {
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - opacity)),
                child: child,
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 20.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred bg image
          Image.file(
            widget.imageFile,
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.4),
          ),
          Container(
            color: Colors.white.withOpacity(0.9),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80.w,
                      height: 80.w,
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 6,
                      ),
                    ),
                    Icon(Icons.auto_awesome, size: 32.sp, color: Colors.black),
                  ],
                ),
                SizedBox(height: 32.h),
                Text(
                  'Kombinin İnceleniyor...',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Stil danışmanın detaylı analiz yapıyor',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 9) return const Color(0xFF4CAF50); // Green
    if (score >= 7) return const Color(0xFF2196F3); // Blue
    if (score >= 5) return const Color(0xFFFFC107); // Amber
    return const Color(0xFFFF5252); // Red
  }
}
