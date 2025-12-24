import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for analyzing clothing images using Gemini AI
class ClothingAnalysisService {
  late final GenerativeModel _model;

  // Gemini API Key
  static const String _apiKey = 'AIzaSyDLlCDOs_bE4YmOxwjiGtZMyhOl6jD-vaA';

  ClothingAnalysisService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Analyze a clothing image and extract properties
  /// Returns a Map with: subcategory, color, pattern, season, material
  Future<Map<String, String?>> analyzeClothing(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Create prompt for structured output
      final prompt = '''
Analyze this clothing item image and return ONLY a valid JSON object with these exact fields:

{
  "subcategory": "one of: bag, belt, blazer, blouse, boots, cardigan, coat, flats, gloves, hat, heels, hoodie, jacket, jeans, jewelry, leggings, pants, sandals, scarf, shirt, shoes, shorts, skirt, slippers, sneakers, sunglasses, sweater, tank top, t-shirt, trousers, vest, watch",
  "color": "one of: black, white, beige, gray, red, blue, green, yellow, orange, pink, purple, brown, navy, khaki",
  "pattern": "one of: plain, striped, floral, logo, checkered, graphic, polka dot, geometric",
  "season": "one of: summer, winter, spring, autumn, all",
  "material": "one of: cotton, denim, leather, wool, polyester, silk, linen, cashmere, synthetic, or null if unknown"
}

Rules:
- Return ONLY the JSON object, no other text
- Use exact values from the lists above
- If unsure about material, use null
- Choose the most appropriate subcategory
- For multi-colored items, choose the dominant color
- For all-season items, use "all"

JSON:''';

      // Send request to Gemini
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      // Parse JSON response
      return _parseResponse(responseText);
    } catch (e) {
      throw ClothingAnalysisException(
        'Failed to analyze clothing: ${e.toString()}',
      );
    }
  }

  /// Parse and validate the Gemini response
  Map<String, String?> _parseResponse(String responseText) {
    try {
      // Remove markdown code blocks if present
      String jsonText = responseText;
      if (jsonText.contains('```json')) {
        jsonText =
            jsonText.replaceAll('```json', '').replaceAll('```', '').trim();
      } else if (jsonText.contains('```')) {
        jsonText = jsonText.replaceAll('```', '').trim();
      }

      // Try to find JSON object in response
      final jsonStart = jsonText.indexOf('{');
      final jsonEnd = jsonText.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) {
        throw FormatException('No JSON object found in response');
      }

      jsonText = jsonText.substring(jsonStart, jsonEnd + 1);

      // Parse JSON
      final Map<String, dynamic> json = {};

      // Simple JSON parsing (since we control the format)
      final lines = jsonText.replaceAll('{', '').replaceAll('}', '').split(',');

      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim().replaceAll('"', '');
          var value = parts[1].trim().replaceAll('"', '');

          // Handle null values
          if (value == 'null') {
            value = '';
          }

          json[key] = value;
        }
      }

      // Validate required fields
      final result = {
        'subcategory': json['subcategory'] as String?,
        'color': json['color'] as String?,
        'pattern': json['pattern'] as String?,
        'season': json['season'] as String?,
        'material': json['material'] as String?,
      };

      if (result['subcategory'] == null || result['subcategory']!.isEmpty) {
        throw FormatException('Missing required field: subcategory');
      }

      return result;
    } catch (e) {
      throw ClothingAnalysisException(
        'Failed to parse response: ${e.toString()}\nResponse: $responseText',
      );
    }
  }
}

/// Custom exception for clothing analysis errors
class ClothingAnalysisException implements Exception {
  final String message;

  ClothingAnalysisException(this.message);

  @override
  String toString() => message;
}
