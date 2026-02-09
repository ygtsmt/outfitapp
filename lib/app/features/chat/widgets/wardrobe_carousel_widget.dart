import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_route/auto_route.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';

class WardrobeCarouselWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const WardrobeCarouselWidget({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Row(
            children: [
              Icon(Icons.checkroom_rounded,
                  size: 16.sp, color: const Color(0xFF6B4EFF)),
              SizedBox(width: 6.w),
              Text(
                'From Your Wardrobe',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];
              final imageUrl = item['imageUrl'] as String? ?? '';
              final category = item['category'] as String? ?? 'Item';
              final subcategory = item['subcategory'] as String?;
              final brand = item['brand'] as String?;
              final color = item['color'] as String?;

              // Title construction
              String title = subcategory ?? category;
              if (color != null) {
                title = '$color $title';
              }
              // Capitalize
              title = title
                  .split(' ')
                  .map((word) => word.isNotEmpty
                      ? '${word[0].toUpperCase()}${word.substring(1)}'
                      : '')
                  .join(' ');

              return Container(
                width: 140.w,
                margin: EdgeInsets.only(right: 12.w, bottom: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF0F0F0)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      try {
                        // Convert map back to WardrobeItem for navigation
                        final wardrobeItem = WardrobeItem.fromJson(item);
                        context.router.push(ClosetItemDetailScreenRoute(
                            closetItem: wardrobeItem));
                      } catch (e) {
                        debugPrint('Error navigating to detail: $e');
                      }
                    },
                    borderRadius: BorderRadius.circular(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16.r)),
                          child: Container(
                            height: 120.h,
                            width: double.infinity,
                            color: Colors.grey[50],
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.image_not_supported_rounded,
                                            color: Colors.grey[400]),
                                  )
                                : Icon(Icons.image_not_supported_rounded,
                                    color: Colors.grey[400]),
                          ),
                        ),
                        // Info
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(10.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                                if (brand != null && brand.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    brand,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
