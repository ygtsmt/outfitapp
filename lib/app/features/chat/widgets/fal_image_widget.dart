import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class FalImageWidget extends StatelessWidget {
  final String requestId;
  final bool isLive; // 🔥 EKLENDİ

  const FalImageWidget({
    super.key,
    required this.requestId,
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const SizedBox.shrink();

    if (!isLive) {
      // 🧊 HISTORY MODE → STREAM YOK
      return _buildStaticPlaceholder(context);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('combines')
          .doc(requestId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorBox(context, 'Error loading image');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildLoading(context, 'Generating image...');
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = (data['status'] as String?)?.toLowerCase();
        final output = data['output'];

        final isCompleted = status == 'completed' || status == 'succeeded';
        final isFailed = status == 'failed' || status == 'error';

        if (isCompleted) {
          final imageUrl = _extractImageUrl(output);
          if (imageUrl != null) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            );
          }
          return _errorBox(context, 'Image format not recognized.');
        }

        if (isFailed) {
          return _errorBox(context, 'Failed to generate image.');
        }

        return _buildLoading(context, 'Generating image...');
      },
    );
  }

  // ---------------- HELPERS ----------------

  String? _extractImageUrl(dynamic output) {
    try {
      if (output is Map) {
        if (output['image'] is Map) {
          return output['image']['url'];
        }
        if (output['images'] is List && output['images'].isNotEmpty) {
          return output['images'][0]['url'];
        }
      }
      if (output is List && output.isNotEmpty) {
        final first = output.first;
        if (first is String) return first;
        if (first is Map && first['url'] != null) return first['url'];
      }
    } catch (_) {}
    return null;
  }

  Widget _buildStaticPlaceholder(BuildContext context) {
    return Container(
      height: 200.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        'Generated image',
        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
      ),
    );
  }

  Widget _errorBox(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(text, style: TextStyle(fontSize: 12.sp)),
    );
  }

  Widget _buildLoading(BuildContext context, String text) {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: 12.h),
            Text(text, style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}
