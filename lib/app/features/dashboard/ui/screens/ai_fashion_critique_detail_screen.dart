import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIFashionCritiqueDetailScreen extends StatefulWidget {
  final Map<String, dynamic> critiqueData;

  const AIFashionCritiqueDetailScreen({
    super.key,
    required this.critiqueData,
  });

  @override
  State<AIFashionCritiqueDetailScreen> createState() =>
      _AIFashionCritiqueDetailScreenState();
}

class _AIFashionCritiqueDetailScreenState
    extends State<AIFashionCritiqueDetailScreen> with TickerProviderStateMixin {
  // Data
  late int _score;
  late String _style;
  late String _colorHarmony;
  late List<String> _feedback;
  late String _imageUrl;

  // Animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _parseData();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    // Start animation immediately
    _fadeController.forward();
  }

  void _parseData() {
    _score = (widget.critiqueData['score'] ?? 0) as int;
    _style = (widget.critiqueData['style'] ?? 'Bilinmiyor') as String;
    _colorHarmony =
        (widget.critiqueData['colorHarmony'] ?? 'Bilinmiyor') as String;

    final feedbackData = widget.critiqueData['feedback'];
    if (feedbackData is List) {
      _feedback = List<String>.from(feedbackData);
    } else {
      _feedback = [];
    }

    _imageUrl = (widget.critiqueData['imageUrl'] ?? '') as String;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light premium bg
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
                      child: _imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: _imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                            )
                          : Container(color: Colors.grey),
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

                  // 4. Close Button (Takes consistent place of controls)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.router.pop(),
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
                          'Kapat',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
    // Reuse simpler animation logic for stateless feel or keep FutureBuilder delayed entrance
    // For detail screen, immediate appearance might be better but let's keep consistent heavy animation for "premium" feel.
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

  Color _getScoreColor(int score) {
    if (score >= 9) return const Color(0xFF4CAF50); // Green
    if (score >= 7) return const Color(0xFF2196F3); // Blue
    if (score >= 5) return const Color(0xFFFFC107); // Amber
    return const Color(0xFFFF5252); // Red
  }
}
