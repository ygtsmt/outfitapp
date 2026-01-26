import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget to preview selected media before sending
class MediaPreviewWidget extends StatelessWidget {
  final List<String> mediaPaths;
  final VoidCallback onClear;

  const MediaPreviewWidget({
    super.key,
    required this.mediaPaths,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (mediaPaths.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seçili Medya (${mediaPaths.length})',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20.sp),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mediaPaths.length,
              itemBuilder: (context, index) {
                final path = mediaPaths[index];
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _MediaThumbnail(path: path),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaThumbnail extends StatelessWidget {
  final String path;

  const _MediaThumbnail({required this.path});

  bool get _isVideo {
    final ext = path.split('.').last.toLowerCase();
    return ext == 'mp4' || ext == 'mov' || ext == 'avi';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 80.w,
        height: 80.h,
        color: Colors.grey[300],
        child: _isVideo
            ? Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.videocam,
                      size: 32.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  Positioned(
                    bottom: 4.h,
                    left: 4.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'VİDEO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey[600],
                      size: 32.sp,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
