import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ShoppingCarouselWidget extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const ShoppingCarouselWidget({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Text(
            '🛒 Purchasing Options',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final product = products[index];
              final title = product['title'] as String? ?? 'Unknown Product';
              final price = product['price'] as String? ?? '';
              final source = product['source'] as String? ?? '';
              final thumbnail = product['thumbnail'] as String?;
              final link = product['link'] ??
                  product['product_link'] ??
                  product['serpapi_product_api'];

              return Container(
                width: 160.w,
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
                child: InkWell(
                  onTap: () async {
                    if (link != null) {
                      launch(link);
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
                          height: 100.h,
                          width: double.infinity,
                          color: Colors.grey[50],
                          child: thumbnail != null
                              ? Image.network(
                                  thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.shopping_bag_outlined,
                                          color: Colors.grey[400]),
                                )
                              : Icon(Icons.shopping_bag_outlined,
                                  color: Colors.grey[400]),
                        ),
                      ),
                      // Info
                      Padding(
                        padding: EdgeInsets.all(10.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            SizedBox(height: 6.h),
                            Text(
                              price,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Icon(Icons.store,
                                    size: 12.sp, color: Colors.grey[600]),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    source,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
