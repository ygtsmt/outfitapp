import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FalImageWidget extends StatelessWidget {
  final String requestId;

  const FalImageWidget({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('combines')
          .doc(requestId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: EdgeInsets.all(8.w),
            color: Colors.red.withOpacity(0.1),
            child: Text('Error loading image',
                style: TextStyle(fontSize: 12.sp, color: Colors.red)),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildLoading(context, 'Creating request...');
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = data['status'] as String?;
        final output = data['output'];

        // Status kontrolü (Case-insensitive)
        final isCompleted = status?.toLowerCase() == 'completed' ||
            status?.toLowerCase() == 'succeeded';
        final isFailed = status?.toLowerCase() == 'failed' ||
            status?.toLowerCase() == 'error';

        if (isCompleted && output != null) {
          String? imageUrl;

          try {
            // Output parsing logic
            if (output is Map) {
              if (output.containsKey('image') && output['image'] is Map) {
                imageUrl = output['image']['url'];
              } else if (output.containsKey('images') &&
                  output['images'] is List &&
                  (output['images'] as List).isNotEmpty) {
                imageUrl = output['images'][0]['url'];
              }
            } else if (output is List && output.isNotEmpty) {
              // Bazen direkt liste dönebilir: [{"url": "..."}] VEYA ["https://..."]
              final firstItem = output.first;
              if (firstItem is Map) {
                if (firstItem.containsKey('url')) {
                  imageUrl = firstItem['url'];
                } else if (firstItem.containsKey('image') &&
                    firstItem['image'] is Map) {
                  imageUrl = firstItem['image']['url'];
                }
              } else if (firstItem is String) {
                // Direkt URL string listesi
                imageUrl = firstItem;
              }
            }
          } catch (e) {
            debugPrint('FalImageWidget parsing error: $e');
          }

          if (imageUrl != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildLoading(context, 'Downloading image...');
                },
              ),
            );
          } else {
            // Completed ama URL bulunamadı hatası göster
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.broken_image_outlined,
                      color: Colors.orange, size: 24.sp),
                  SizedBox(width: 8.w),
                  const Expanded(child: Text('Image format not recognized.')),
                ],
              ),
            );
          }
        }

        if (isFailed) {
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 24.sp),
                SizedBox(width: 8.w),
                const Expanded(child: Text('Failed to generate image.')),
              ],
            ),
          );
        }

        return _buildLoading(context, 'Generating image... (Status: $status)');
      },
    );
  }

  Widget _buildLoading(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(height: 12.h),
          Text(message,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
