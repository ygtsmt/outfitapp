import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';

class CombineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> imageData;

  const CombineDetailScreen({
    super.key,
    required this.imageData,
  });

  @override
  State<CombineDetailScreen> createState() => _CombineDetailScreenState();
}

class _CombineDetailScreenState extends State<CombineDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  final double _maxScroll = 400;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset.clamp(-200, _maxScroll);
    });
  }

  // Progress: 0 = start, 1 = fully scrolled (image fullscreen)
  double get _progress => (_scrollOffset / _maxScroll).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final status = widget.imageData['status'] as String? ?? 'processing';
    final output = widget.imageData['output'] as List<dynamic>?;
    final imageUrl =
        output != null && output.isNotEmpty ? output[0] as String? : null;
    final prompt = widget.imageData['prompt'] as String? ?? '';
    final createdAtStr = widget.imageData['createdAt'] as String?;
    DateTime? createdAt;
    if (createdAtStr != null) {
      createdAt = DateTime.tryParse(createdAtStr);
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Image size logic
    final baseImageHeight = 500.h;
    final fullScreenImageHeight = screenHeight;
    final imageHeight = baseImageHeight +
        (_progress * (fullScreenImageHeight - baseImageHeight));

    // BorderRadius logic
    final borderRadius = 24.r * (1 - _progress);

    // Shadow opacity
    final shadowOpacity = 0.1 + (_progress * 0.2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background with gradient
          _buildBackground(),

          // Main scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Detaylar bölümü (üstte)
                _buildDetailsSection(context, prompt, createdAt, status),

                // Fotoğraf (altta, scroll ile büyür)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: screenWidth - (32.w * (1 - _progress)),
                  height: imageHeight,
                  margin: EdgeInsets.symmetric(
                    horizontal: 16.w * (1 - _progress),
                  ),
                  child: Hero(
                    tag: 'combine_${widget.imageData['id'] ?? imageUrl}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(shadowOpacity),
                            blurRadius: 30 + (_progress * 20),
                            offset: Offset(0, -10 - (_progress * 10)),
                            spreadRadius: _progress * 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[50],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).primaryColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey[50],
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey[400],
                                    size: 48.sp,
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: Text(
                                    'Görsel Hazırlanıyor...',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                // Extra space at bottom
                SizedBox(height: 100.h),
              ],
            ),
          ),

          // Fixed app bar
          SafeArea(
            child: _buildAppBar(context, imageUrl),
          ),

          // Scroll indicator
          if (_progress < 0.3)
            Positioned(
              bottom: 50.h,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1 - (_progress * 3),
                child: Column(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                      size: 28.sp,
                    ),
                    Text(
                      'Kaydırarak görseli büyüt',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color.lerp(Colors.white, Colors.grey[100], _progress)!,
          ],
        ),
      ),
      child: Opacity(
        opacity: 0.03 * (1 - _progress),
        child: Center(
          child: Image.asset(
            'assets/png/logo.png',
            width: 200.w,
            height: 200.w,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String? imageUrl) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Geri butonu
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.grey[800],
                size: 18.sp,
              ),
            ),
            onPressed: () => context.router.pop(),
          ),

          // Sağ taraftaki butonlar
          Row(
            children: [
              // Fullscreen butonu
              if (imageUrl != null)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _progress > 0.5 ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: _progress > 0.5 ? 1.0 : 0.8,
                    child: IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.fullscreen,
                          color: Theme.of(context).primaryColor,
                          size: 20.sp,
                        ),
                      ),
                      onPressed: _progress > 0.5
                          ? () => _openFullscreenViewer(context, imageUrl)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openFullscreenViewer(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Hero(
                        tag: 'fullscreen_combine_$imageUrl',
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 64.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16.h,
                    right: 16.w,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsSection(
      BuildContext context, String prompt, DateTime? createdAt, String status) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: 1.0 - (_progress * 0.8),
      child: Container(
        padding: EdgeInsets.fromLTRB(32.w, 100.h, 32.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Try-On Combine',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w300,
                color: Colors.grey[900],
                letterSpacing: 1.2,
              ),
            ),

            if (createdAt != null) ...[
              SizedBox(height: 8.h),
              Text(
                DateFormat('dd MMM yyyy, HH:mm').format(createdAt),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],

            SizedBox(height: 32.h),

            // Divider
            Container(
              width: 50.w,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.5),
                    Theme.of(context).primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            SizedBox(height: 32.h),

            // Prompt Detail
            if (prompt.isNotEmpty) ...[
              Text(
                'PROMPT',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                prompt,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[800],
                ),
              ),
            ],

            SizedBox(height: 32.h),

            _buildAIBadge(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAIBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[100]!,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 14.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 8.w),
          Text(
            'AI ile üretildi',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
