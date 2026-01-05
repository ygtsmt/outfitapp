import 'package:auto_route/auto_route.dart';
import 'package:before_after/before_after.dart';
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
  double _sliderValue = 0.5; // ✅ state'te tut

  @override
  Widget build(BuildContext context) {
    final status = widget.imageData['status'] as String? ?? 'processing';
    final output = widget.imageData['output'] as List<dynamic>?;
    final imageUrl =
        output != null && output.isNotEmpty ? output[0] as String? : null;
    final inputImages = widget.imageData['inputImages'] as List<dynamic>?;
    final beforeImageUrl = inputImages != null && inputImages.isNotEmpty
        ? inputImages[0] as String?
        : null;

    final prompt = widget.imageData['prompt'] as String? ?? '';
    final createdAtStr = widget.imageData['createdAt'] as String?;
    final usedClosetItems =
        widget.imageData['usedClosetItems'] as List<dynamic>?;

    DateTime? createdAt;
    if (createdAtStr != null) {
      createdAt = DateTime.tryParse(createdAtStr);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
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
        actions: [
          if (imageUrl != null)
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
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
              onPressed: () => _openFullscreenViewer(context, imageUrl),
            ),
          SizedBox(width: 16.w),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailsSection(context, prompt, createdAt, status),
            SizedBox(height: 24.h),

            // Before/After Slider Container
            Container(
              height: 500.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: _buildBeforeAfterSlider(beforeImageUrl, imageUrl),
              ),
            ),

            if (usedClosetItems != null && usedClosetItems.isNotEmpty)
              _buildUsedItemsSection(context, usedClosetItems),

            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforeAfterSlider(String? beforeUrl, String? afterUrl) {
    if (beforeUrl == null || afterUrl == null) {
      return _buildSingleImageView(afterUrl ?? beforeUrl);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return BeforeAfter(
          value: _sliderValue,
          before: SizedBox.expand(
            child: CachedNetworkImage(
              imageUrl: beforeUrl,
              fit: BoxFit.cover, // ✅ ikisi de cover
              placeholder: (_, __) => Container(color: Colors.grey[200]),
              errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
            ),
          ),
          after: SizedBox.expand(
            child: CachedNetworkImage(
              imageUrl: afterUrl,
              fit: BoxFit.cover, // ✅ ikisi de cover
              placeholder: (_, __) => Container(color: Colors.grey[200]),
              errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
            ),
          ),
          onValueChanged: (v) => setState(() => _sliderValue = v),
          thumbColor: Colors.white,
          direction: SliderDirection.horizontal,
        );
      },
    );
  }

  Widget _buildSingleImageView(String? imageUrl) {
    if (imageUrl == null) {
      return Container(
        color: Colors.grey[100],
        child: Center(
          child: Text(
            'Görsel yok',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
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
    );
  }

  Widget _buildUsedItemsSection(BuildContext context, List<dynamic> items) {
    return Container(
      margin: EdgeInsets.only(top: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kullanılan Parçalar',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 110.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final item = items[index] as Map<String, dynamic>;
                final imageUrl = item['imageUrl'] as String?;
                final category = item['category'] as String? ?? 'Item';

                return Column(
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl, fit: BoxFit.cover)
                            : Icon(Icons.checkroom, color: Colors.grey[400]),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
      BuildContext context, String prompt, DateTime? createdAt, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
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
        SizedBox(height: 24.h),
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
        SizedBox(height: 24.h),
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
        SizedBox(height: 24.h),
        _buildAIBadge(context),
      ],
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
}
