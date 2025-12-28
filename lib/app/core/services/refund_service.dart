import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginfit/app/features/text_to_image/model/text_to_image_generation_response_model_for_black_forest_label.dart';
import 'package:ginfit/app/data/models/credit_model.dart';
import 'package:ginfit/core/enums.dart';

class RefundService {
  final FirebaseFirestore _firestore;
  final GenerateCreditRequirements _creditRequirements;

  RefundService({
    FirebaseFirestore? firestore,
    required GenerateCreditRequirements creditRequirements,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _creditRequirements = creditRequirements;

  static const int maxRefundCount = 10;

  Future<bool> canRequestRefund(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final refundCount = userData?['profile_info']?['refundCount'] ?? 0;
        return refundCount < maxRefundCount;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<int> getRefundCount(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['profile_info']?['refundCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> processRefund(
      String userId, dynamic content, GenerateType contentType) async {
    try {
      if (!await canRequestRefund(userId)) {
        return {
          'success': false,
          'reason': 'Refund limit reached (max 10 refunds)',
        };
      }

      final contentId = _getContentId(content, contentType);
      if (contentId != null &&
          await _isContentAlreadyRefunded(userId, contentId)) {
        return {
          'success': false,
          'reason': 'This content has already been refunded',
        };
      }

      final currentRefundCount = await getRefundCount(userId);
      final contentCost = _calculateContentCost(content, contentType);

      // Update user credits
      await _firestore.collection('users').doc(userId).update({
        'profile_info.totalCredit': FieldValue.increment(contentCost),
        'profile_info.refundCount': currentRefundCount + 1,
      });

      // Update video status if it's a video refund
      if (contentType == GenerateType.video && contentId != null) {
        await _updateVideoRefundStatus(userId, contentId);
      }

      // Log refund transaction
      final refundDocRef = _firestore.collection('refunds').doc(userId);
      final refundDoc = await refundDocRef.get();

      if (refundDoc.exists) {
        await refundDocRef.update({
          'refundedContent': FieldValue.arrayUnion([
            {
              'id': contentId,
              'type': contentType.name,
              'timestamp': DateTime.now().toIso8601String(),
            }
          ]),
          'totalRefundAmount': FieldValue.increment(contentCost),
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      } else {
        await refundDocRef.set({
          'userId': userId,
          'refundedContent': [
            {
              'id': contentId,
              'type': contentType.name,
              'timestamp': DateTime.now().toIso8601String(),
            }
          ],
          'totalRefundAmount': contentCost,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      }

      return {
        'success': true,
        'refundAmount': contentCost,
        'message': 'Refund processed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'reason': 'System error occurred while processing refund',
      };
    }
  }

  Future<void> _updateVideoRefundStatus(String userId, String videoId) async {
    try {
      // Get user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data();
      if (userData == null) return;

      // Get userGeneratedVideos array
      final videos = userData['userGeneratedVideos'] as List<dynamic>? ?? [];

      // Find and update the specific video
      for (int i = 0; i < videos.length; i++) {
        final video = videos[i];
        if (video is Map<String, dynamic> && video['id'] == videoId) {
          video['is_was_refund'] = true;
          video['isDeleted'] = true;
          break;
        }
      }

      // Update the user document with modified videos array
      await _firestore.collection('users').doc(userId).update({
        'userGeneratedVideos': videos,
      });
    } catch (e) {
      // Error updating video status, but refund still succeeded
    }
  }

  String? _getContentId(dynamic content, GenerateType contentType) {
    try {
      switch (contentType) {
        case GenerateType.video:
        case GenerateType.videoTemplate:
          if (content is VideoGenerateResponseModel) {
            return content.id;
          }
          break;
        case GenerateType.image:
        case GenerateType.realtimeImage:
          if (content
              is TextToImageImageGenerationResponseModelForBlackForestLabel) {
            return content.id;
          }
          break;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _isContentAlreadyRefunded(
      String userId, String contentId) async {
    try {
      final refundDoc =
          await _firestore.collection('refunds').doc(userId).get();
      if (refundDoc.exists) {
        final data = refundDoc.data();
        if (data == null) return false;

        final refundedContent = data['refundedContent'] ?? [];
        return refundedContent.any(
            (item) => item is Map<String, dynamic> && item['id'] == contentId);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Convenience methods
  Future<Map<String, dynamic>> processVideoRefund(
      String userId, VideoGenerateResponseModel video) async {
    return processRefund(userId, video, GenerateType.video);
  }

  Future<Map<String, dynamic>> processImageRefund(String userId,
      TextToImageImageGenerationResponseModelForBlackForestLabel image) async {
    return processRefund(userId, image, GenerateType.image);
  }

  Future<Map<String, dynamic>> processRealtimeImageRefund(String userId,
      TextToImageImageGenerationResponseModelForBlackForestLabel image) async {
    return processRefund(userId, image, GenerateType.realtimeImage);
  }

  int _calculateContentCost(dynamic content, GenerateType contentType) {
    switch (contentType) {
      case GenerateType.video:
      case GenerateType.videoTemplate:
        return _creditRequirements.videoRequiredCredits;
      case GenerateType.image:
        return _creditRequirements.imageRequiredCredits;
      case GenerateType.realtimeImage:
        return _creditRequirements.realtimeImageRequiredCredits;
    }
  }
}
