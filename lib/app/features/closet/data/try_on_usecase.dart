import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ginly/app/features/closet/models/try_on_response_model.dart';
import 'package:ginly/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@injectable
class TryOnUseCase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  // 🔑 Cached API key from Firebase
  String? _cachedFalAiApiKey;
  DateTime? _keyLastFetched;

  TryOnUseCase({
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

  /// Upload image to Firebase Storage and return URL
  Future<String> uploadImage(File imageFile) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    try {
      final ref = storage.ref().child(
          "try_on_uploads/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");

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
      log('TryOn uploadImage error: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  /// Generate Try-On using Fal AI Gemini 25 Flash Image Edit
  /// imageUrls: [model_url, closet1_url, closet2_url]
  Future<TryOnResponseModel> generateTryOn(List<String> imageUrls) async {
    try {
      final apiKey = await getFalAiApiKey();

      final url = Uri.parse('https://queue.fal.run/fal-ai/gemini-25-flash-image/edit');

      final body = json.encode({
        'prompt': 'Kıyafetleri giydir',
        'image_urls': imageUrls,
      });

      log('📤 Try-On API Request: $body');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Key $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      log('📥 Try-On API Response Status: ${response.statusCode}');
      log('📥 Try-On API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        return TryOnResponseModel.fromJson(jsonResponse);
      } else {
        throw Exception('Try-On API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log('❌ Try-On generateTryOn error: $e');
      throw Exception('Error generating try-on: $e');
    }
  }
}

