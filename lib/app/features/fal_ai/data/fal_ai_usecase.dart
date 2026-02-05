import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/utils/api_retry_helper.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';

@injectable
class FalAiUsecase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  // 🔑 Cached API key from Firebase
  String? _cachedFalAiApiKey;
  DateTime? _keyLastFetched;

  FalAiUsecase({
    required this.firestore,
    required this.auth,
    required this.storage,
  });

  /// 🔑 Get Fal AI API Key from Firebase (with 5-minute cache)
  /// Firebase path: keys/fal_ai/falAiApiKey
  Future<String> getFalAiApiKey() async {
    try {
      // Cache check - valid for 5 minutes
      final now = DateTime.now();
      if (_cachedFalAiApiKey != null &&
          _keyLastFetched != null &&
          now.difference(_keyLastFetched!).inMinutes < 5) {
        log('🔑 Using cached Fal AI API key');
        return _cachedFalAiApiKey!;
      }

      log('🔥 Fetching Fal AI API key from Firebase...');
      final docSnapshot =
          await firestore.collection('keys').doc('fal_ai').get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final apiKey = data?['falAiApiKey'] as String?;

        if (apiKey != null && apiKey.isNotEmpty) {
          _cachedFalAiApiKey = apiKey;
          _keyLastFetched = now;
          log('✅ Fal AI API key loaded from Firebase: ${apiKey.substring(0, 10)}...');
          return apiKey;
        }
      }

      // Fallback: if not in Firebase, use hardcoded key
      log('⚠️ Firebase key not found, using fallback hardcoded key');
      return falAiApiKey;
    } catch (e) {
      log('❌ Error fetching Fal AI API key from Firebase: $e');
      // In case of error, use fallback key
      return falAiApiKey;
    }
  }

  Future<String> uploadImageToStorage(File imageFile, String folder) async {
    final userId = auth.currentUser!.uid;

    try {
      final ref = storage.ref().child(
          "$folder/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");

      final bytes = await imageFile.readAsBytes();
      final uploadTask = await ref.putData(bytes);

      // Make file public for Fal AI access
      await ref.updateMetadata(SettableMetadata(
        cacheControl: 'public, max-age=3600',
        contentType: 'image/jpeg',
      ));

      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      log('Fal AI uploadImageToStorage error: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  Future<String> uploadUserImage(File imageFile) async {
    return uploadImageToStorage(imageFile, "fal_ai_uploads");
  }

  /// Gemini 2.5 Flash Image Edit
  /// Generates edited images based on prompt and input images
  Future<Map<String, dynamic>?> generateGeminiImageEdit({
    required List<String> imageUrls, // Clothes images
    required String prompt,
    required int sourceId,
    String?
        modelAiPrompt, // Description of the model (e.g., "A young adult male...")
    String? modelImageUrl, // URL of the user's model image
    List<WardrobeItem>? usedClosetItems,
  }) async {
    try {
      final userId = auth.currentUser!.uid;
      final webhookUrl =
          "https://us-central1-ginowl-ginfit.cloudfunctions.net/falWebhook?userId=$userId";
      final uri = Uri.parse(
              'https://queue.fal.run/fal-ai/gemini-3-pro-image-preview/edit')
          .replace(queryParameters: {'fal_webhook': webhookUrl});

      var apiKey = await getFalAiApiKey();

      // Validate API Key format
      if (!apiKey.contains(':')) {
        if (falAiApiKey.contains(':')) {
          apiKey = falAiApiKey;
        } else {
          log('❌ Hardcoded key also appears invalid.');
        }
      }

      // --- PROMPT ENGINEERING ---
      // If we have a model image, we prepend it to image_urls
      // and update the prompt to refer to it.

      final finalImageUrls = List<String>.from(imageUrls);
      String finalPrompt = prompt;

      if (modelImageUrl != null && modelImageUrl.isNotEmpty) {
        // Add model image as the FIRST image (reference)
        finalImageUrls.insert(0, modelImageUrl);

        // Enhance prompt to use the model
        // "A photo of [model_desc] wearing [clothes]..."
        final modelDesc = modelAiPrompt ?? "the person in the first image";
        finalPrompt =
            "Using the first image as the model ($modelDesc), generate a realistic photo of them wearing the following items: $prompt. Ensure the clothes fit naturally.";
      } else {
        // No model image, use description if available
        if (modelAiPrompt != null) {
          finalPrompt =
              "A realistic full-body photo of $modelAiPrompt wearing: $prompt";
        }
      }

      // Added retry mechanism for reliability
      final response = await ApiRetryHelper.withRetry(
        () => http.post(
          uri,
          headers: {
            "Authorization": "Key $apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "prompt": finalPrompt,
            "image_urls": finalImageUrls,
            "num_images": 1,
            "aspect_ratio": "auto",
            "output_format": "png",
          }),
        ),
        maxRetries: 2,
      );

      log('Gemini Image Edit Response Status: ${response.statusCode}');
      log('Gemini Image Edit Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final requestId = responseData['request_id'];

        if (requestId != null) {
          // Serialize closet items if provided
          List<Map<String, dynamic>>? serializedClosetItems;
          if (usedClosetItems != null) {
            serializedClosetItems =
                usedClosetItems.map((item) => item.toJson()).toList();
          }

          // Create image data for Firestore
          final imageData = {
            'id': requestId,
            'prompt': prompt,
            'inputImages': imageUrls,
            'output': null, // Will be filled by webhook
            'status': 'processing',
            'createdAt': DateTime.now().toIso8601String(),
            'completedAt': null,
            'model': 'gemini-2.5-flash-image-edit',
            'usedClosetItems': serializedClosetItems,
            'sourceId': sourceId,
          };

          // Add to user's Firestore subcollection
          final userId = auth.currentUser!.uid;
          await firestore
              .collection('users')
              .doc(userId)
              .collection('combines')
              .doc(requestId)
              .set(imageData);

          log('✅ Gemini Image Edit request created: $requestId');
          return imageData;
        }
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Bad Request';
        log('Gemini Image Edit 400 Error: $errorMessage');
        throw Exception('Gemini Image Edit Error (400): $errorMessage');
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Validation Error';
        final errorDetails = errorBody['detail'] ?? 'No details provided';
        log('Gemini Image Edit 422 Error: $errorMessage');
        log('Gemini Image Edit 422 Details: $errorDetails');
        throw Exception(
            'Gemini Image Edit Validation Error (422): $errorMessage - $errorDetails');
      } else {
        log('Gemini Image Edit Unexpected Error (${response.statusCode}): ${response.body}');
        throw Exception(
            'Gemini Image Edit Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      log('Error occurred while generating Gemini Image Edit: $e');
      throw Exception('Error occurred while generating Gemini Image Edit: $e');
    }
    return null;
  }
}
