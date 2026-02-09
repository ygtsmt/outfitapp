import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ShoppingItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ShoppingItemDetailScreen({super.key, required this.product});

  @override
  State<ShoppingItemDetailScreen> createState() =>
      _ShoppingItemDetailScreenState();
}

class _ShoppingItemDetailScreenState extends State<ShoppingItemDetailScreen> {
  bool isDownloading = false;

  Future<void> _addToCloset() async {
    final thumbnail = widget.product['thumbnail'] as String?;
    if (thumbnail == null) return;

    setState(() => isDownloading = true);

    try {
      final response = await http.get(Uri.parse(thumbnail));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File(
          path.join(
            tempDir.path,
            '${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          context.router
              .push(BatchUploadProgressScreenRoute(imageFiles: [file]));
        }
      } else {
        _showError("Failed to download image");
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => isDownloading = false);
      }
    }
  }

  Future<void> _buyNow() async {
    final link = widget.product['link'] ??
        widget.product['product_link'] ??
        widget.product['serpapi_product_api'];

    if (link != null) {
      await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.product['title'] as String? ?? 'Unknown Product';
    final price = widget.product['price'] as String? ?? '';
    final source = widget.product['source'] as String? ?? '';
    final thumbnail = widget.product['thumbnail'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          /// HERO IMAGE
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Positioned.fill(
                  child: thumbnail != null
                      ? CachedNetworkImage(
                          imageUrl: thumbnail,
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey[200]),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// DETAILS
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SOURCE + PRICE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SourceBadge(source: source),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  /// TITLE
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),

                  const Spacer(),

                  /// CTA BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56.h,
                          child: ElevatedButton(
                            onPressed: isDownloading ? null : _addToCloset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.baseColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              elevation: 0,
                            ),
                            child: isDownloading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "Add to Closet",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 56.h,
                          child: OutlinedButton(
                            onPressed: _buyNow,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                            ),
                            child: const Text(
                              "Buy Now",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.only(left: 12.w),
        child: _CircleIcon(
          icon: Icons.arrow_back,
          onTap: () => context.popRoute(),
        ),
      ),
      actions: [
        _CircleIcon(
          icon: Icons.open_in_new,
          onTap: _buyNow,
        ),
        SizedBox(width: 12.w),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white.withOpacity(0.85),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onTap,
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final String source;

  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        source,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
