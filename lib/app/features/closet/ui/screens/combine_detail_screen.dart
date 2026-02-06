import 'package:auto_route/auto_route.dart';
import 'package:before_after/before_after.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/app/ui/widgets/fullscreen_image_viewer.dart';
import 'package:comby/core/asset_paths.dart';
import 'package:comby/core/constants/layout_constants.dart';
import 'package:comby/core/extensions.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:comby/generated/l10n.dart';
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
    final sourceId = widget.imageData['sourceId'] as int?;

    DateTime? createdAt;
    if (createdAtStr != null) {
      createdAt = DateTime.tryParse(createdAtStr);
    }

    // For AI Agent combines (sourceId 5), don't show before/after (no before image exists)
    final effectiveBeforeImageUrl = sourceId == 5 ? null : beforeImageUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 32.h, left: 16.w, right: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailsSection(context, prompt, createdAt, status,
                  widget.imageData['sourceId'] as int?),
              LayoutConstants.centralEmptyHeight,

              // Before/After Slider Container
              Container(
                height: 400.h,
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
                  child: Stack(
                    children: [
                      _buildBeforeAfterSlider(
                          effectiveBeforeImageUrl, imageUrl),
                      if (imageUrl != null)
                        Positioned(
                          top: 12.h,
                          right: 12.w,
                          child: GestureDetector(
                            onTap: () =>
                                _openFullscreenViewer(context, imageUrl),
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.fullscreen,
                                color: Colors.black87,
                                size: 24.sp,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (usedClosetItems != null && usedClosetItems.isNotEmpty)
                _buildUsedItemsSection(context, usedClosetItems),

              SizedBox(height: 50.h),
            ],
          ),
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
          thumbDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.baseColor,
            image: DecorationImage(
                image: AssetImage(
                  PngPaths.transactions,
                ),
                fit: BoxFit.fitWidth,
                invertColors: true),
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
            AppLocalizations.of(context).noImage,
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
      margin: EdgeInsets.only(top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).usedItems,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 90.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final item = items[index] as Map<String, dynamic>;
                final imageUrl = item['imageUrl'] as String?;
                final category = item['category'] as String? ?? 'Item';

                return Column(
                  spacing: 2.h,
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
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _onRegenerate,
              icon: Icon(
                Icons.refresh_rounded,
                size: 20.sp,
              ),
              label: Text(
                AppLocalizations.of(context).regenerate,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, String prompt,
      DateTime? createdAt, String status, int? sourceId) {
    final title = AppLocalizations.of(context).combineDetail;
    String subtitle = AppLocalizations.of(context).aiCombine;

    if (sourceId != null) {
      switch (sourceId) {
        case 1:
          subtitle = AppLocalizations.of(context).tryOnMode;
          break;
        case 2:
          subtitle = AppLocalizations.of(context).quickTryOn;
          break;
        case 3:
          subtitle = AppLocalizations.of(context).weatherSuggestion;
          break;
        case 4:
          subtitle = AppLocalizations.of(context).weatherRenewed;
          break;
        case 5:
          subtitle = 'Comby AI Agent';
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            GestureDetector(
              onTap: () => context.router.pop(),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                  size: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),

            // Title and Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (createdAt != null)
                        Text(
                          DateFormat('d MMM, HH:mm').format(createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 4.w,
                        height: 4.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.auto_awesome,
                        size: 14.sp,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocalizations.of(context).gemini3,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openFullscreenViewer(BuildContext context, String imageUrl) {
    FullscreenImageViewer.show(
      context,
      imageUrl: imageUrl,
      heroTag: 'fullscreen_combine_$imageUrl',
    );
  }

  void _onRegenerate() {
    final inputImages = widget.imageData['inputImages'] as List<dynamic>?;
    final output = widget.imageData['output'] as List<dynamic>?;
    final usedClosetItems =
        widget.imageData['usedClosetItems'] as List<dynamic>?;

    if (inputImages == null || inputImages.isEmpty) return;

    // Original photo (before image) for regeneration
    final modelUrl = inputImages[0] as String;

    // Combine photo (AI-generated result) as alternative
    final combineUrl =
        output != null && output.isNotEmpty ? output[0] as String? : null;

    final List<WardrobeItem> clothes = usedClosetItems != null
        ? usedClosetItems
            .map((e) => WardrobeItem.fromMap(e as Map<String, dynamic>))
            .toList()
        : [];

    context.router.navigate(
      HomeScreenRoute(
        children: [
          TryOnTabRouter(
            children: [
              TryOnScreenRoute(
                initialModel: ModelItem(
                  id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                  imageUrl: modelUrl,
                  createdAt: DateTime.now(),
                  // In a real scenario, we could fetch the full ModelItem
                  // to get the aiPrompt, but URL is often enough for a retry.
                ),
                initialClothes: clothes,
                alternativeModelUrl:
                    combineUrl, // Pass combine photo for toggle
              ),
            ],
          ),
        ],
      ),
    );
  }
}
