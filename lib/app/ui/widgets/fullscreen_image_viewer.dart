import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comby/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// A reusable fullscreen image viewer with share and download functionality.
/// Supports both network URLs and local files.
class FullscreenImageViewer extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;
  final String? heroTag;
  final bool showShareButton;
  final bool showDownloadButton;

  const FullscreenImageViewer({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.heroTag,
    this.showShareButton = true,
    this.showDownloadButton = true,
  }) : assert(imageUrl != null || imageFile != null,
            'Either imageUrl or imageFile must be provided');

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();

  /// Helper method to open the fullscreen viewer
  static void show(
    BuildContext context, {
    String? imageUrl,
    File? imageFile,
    String? heroTag,
    bool showShareButton = true,
    bool showDownloadButton = true,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: FullscreenImageViewer(
              imageUrl: imageUrl,
              imageFile: imageFile,
              heroTag: heroTag,
              showShareButton: showShareButton,
              showDownloadButton: showDownloadButton,
            ),
          );
        },
      ),
    );
  }
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  Future<String> _downloadFile(String url) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await Dio().download(url, path);
    return path;
  }

  Future<String> _getFilePath() async {
    if (widget.imageFile != null) {
      return widget.imageFile!.path;
    } else if (widget.imageUrl != null) {
      return await _downloadFile(widget.imageUrl!);
    }
    throw Exception('No image source available');
  }

  Future<void> _shareImage() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      final path = await _getFilePath();
      await Share.shareXFiles(
        [XFile(path)],
        text: AppLocalizations.of(context).shareCombineText,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Loading dialog'u kapat
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Loading dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).shareError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadImage() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      final path = await _getFilePath();
      await Gal.putImage(path);

      if (mounted) {
        Navigator.of(context).pop(); // Loading dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).photoSavedToGallery),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Loading dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).saveError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildImageWidget() {
    if (widget.imageFile != null) {
      return Image.file(
        widget.imageFile!,
        fit: BoxFit.contain,
      );
    } else if (widget.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl!,
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
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: widget.heroTag != null
                  ? Hero(
                      tag: widget.heroTag!,
                      child: _buildImageWidget(),
                    )
                  : _buildImageWidget(),
            ),
          ),
          // Top bar - Close button
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
          // Bottom bar - Share and Download buttons
          if (widget.showShareButton || widget.showDownloadButton)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Share button
                  if (widget.showShareButton)
                    GestureDetector(
                      onTap: _shareImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              AppLocalizations.of(context).share,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.showShareButton && widget.showDownloadButton)
                    SizedBox(width: 16.w),
                  // Download button
                  if (widget.showDownloadButton)
                    GestureDetector(
                      onTap: _downloadImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.download,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              AppLocalizations.of(context).download,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
