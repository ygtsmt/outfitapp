import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ginfit/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

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
      // Cache kontrolü - 5 dakika geçerli
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

      // Fallback: Firebase'de yoksa hardcoded key kullan
      log('⚠️ Firebase key not found, using fallback hardcoded key');
      return falAiApiKey;
    } catch (e) {
      log('❌ Error fetching Fal AI API key from Firebase: $e');
      // Error durumunda fallback key kullan
      return falAiApiKey;
    }
  }

  Future<String> uploadUserImage(File imageFile) async {
    final userId = auth.currentUser!.uid;

    try {
      final ref = storage.ref().child(
          "fal_ai_uploads/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");

      final bytes = await imageFile.readAsBytes();
      final uploadTask = await ref.putData(bytes);

      // Dosyayı public yap (Fal AI erişimi için)
      await ref.updateMetadata(SettableMetadata(
        cacheControl: 'public, max-age=3600',
        contentType: 'image/jpeg',
      ));

      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      log('Fal AI uploadUserImage error: $e');
      throw Exception('Error uploading user image: $e');
    }
  }

  /// Gemini 2.5 Flash Image Edit
  /// Generates edited images based on prompt and input images
  Future<Map<String, dynamic>?> generateGeminiImageEdit({
    required List<String> imageUrls,
    required String prompt,
    String? modelAiPrompt, // AI-generated description of the model
  }) async {
    try {
      // Webhook URL'i query parameter olarak ekle
      final webhookUrl =
          "https://us-central1-ginowl-ginfit.cloudfunctions.net/falWebhook";
      final uri =
          Uri.parse('https://queue.fal.run/fal-ai/gemini-25-flash-image/edit')
              .replace(queryParameters: {'fal_webhook': webhookUrl});

      // Create a detailed prompt using the model's AI description
      String finalPrompt;
      if (modelAiPrompt != null && modelAiPrompt.isNotEmpty) {
        // Use the model's AI description to create a specific prompt
        finalPrompt =
            'The first image shows $modelAiPrompt. Put the clothing items from the other images onto this person. Make sure to only transfer the clothing items, not any people wearing them in the source images.';
      } else {
        // Fallback to simple prompt
        finalPrompt =
            'Put the clothing items from the other images onto the person in the first image. Transfer only the clothes, not any people wearing them.';
      }

      var apiKey = await getFalAiApiKey();

      // Validate API Key format (simple check for colon)
      if (!apiKey.contains(':')) {
        log('❌ WARNING: Fal AI API Key format appears invalid (missing colon). Checking fallback...');
        // Force fallback to hardcoded key from app_constants if simple check fails
        if (falAiApiKey.contains(':')) {
          apiKey = falAiApiKey;
          log('✅ Switched to hardcoded fallback key which appears valid.');
        } else {
          log('❌ Hardcoded key also appears invalid.');
        }
      } else {
        final keyId = apiKey.split(':')[0];
        log('🔑 Using Fal AI API Key with ID: ${keyId.substring(0, keyId.length < 8 ? keyId.length : 8)}...');
      }
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Key $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "prompt": finalPrompt,
          "image_urls": imageUrls,
        }),
      );

      log('Gemini Image Edit Response Status: ${response.statusCode}');
      log('Gemini Image Edit Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final requestId = responseData['request_id'];

        if (requestId != null) {
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
          };

          // Add to user's Firestore document
          final userId = auth.currentUser!.uid;
          await firestore.collection('users').doc(userId).update({
            'userGeneratedImages': FieldValue.arrayUnion([imageData]),
          });

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
