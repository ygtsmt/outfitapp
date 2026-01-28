import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:comby/core/constants/app_constants.dart';
import 'package:comby/core/services/gemini_models.dart';

@injectable
class GeminiRestService {
  final String _baseUrl =
      'https://generativelanguage.googleapis.com/v1alpha/models';

  // Default headers
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-goog-api-key': geminiApiKey,
      };

  /// Send message to Gemini API
  Future<GeminiResponse> generateContent({
    required String model,
    required GeminiRequest request,
  }) async {
    final url = Uri.parse('$_baseUrl/$model:generateContent');

    try {
      final body = jsonEncode(request.toJson());
      log('📡 Gemini Request ($model): ${body.substring(0, body.length > 500 ? 500 : body.length)}...');

      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );

      log('📥 Gemini Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return GeminiResponse.fromJson(json);
      } else {
        log('❌ Gemini Error: ${response.body}');
        throw Exception(
            'Gemini API Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      log('❌ Gemini Exception: $e');
      rethrow;
    }
  }
}
