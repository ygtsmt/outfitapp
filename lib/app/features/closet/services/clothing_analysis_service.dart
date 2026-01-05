import 'dart:io';
import 'package:comby/core/core.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for analyzing clothing images using Gemini AI
class ClothingAnalysisService {
  late final GenerativeModel _model;

  // Gemini API Key

  ClothingAnalysisService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: geminiApiKey,
    );
  }

  /// Analyze a clothing image and extract properties
  /// Returns a Map with: isValidFashionItem, subcategory, color, pattern, season, material, brand
  /// If isValidFashionItem is "false", the image is not a fashion item (e.g. cat, car, food)
  Future<Map<String, String?>> analyzeClothing(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Create prompt for structured output
      final prompt = '''
Analyze this image and determine if it contains a clothing item, accessory, or fashion-related item.

Return ONLY a valid JSON object with these exact fields:

{
  "isValidFashionItem": "true if this is clothing, shoes, bags, jewelry, watches, accessories, or any fashion/wearable item. false if this is NOT a fashion item (e.g. animals, cars, food, landscapes, people without focus on clothing, electronics, furniture, etc.)",
  "invalidReason": "if isValidFashionItem is false, describe what the image shows (e.g. 'This appears to be a cat', 'This is a car', 'This is food'). null if isValidFashionItem is true",
  "subcategory": "one of: bag, belt, blazer, blouse, boots, bracelet, cardigan, chain, coat, earrings, flats, gloves, hat, heels, hoodie, jacket, jeans, jewelry, leggings, necklace, pants, pendant, ring, sandals, scarf, shirt, shoes, shorts, skirt, slippers, sneakers, sunglasses, sweater, tank top, t-shirt, trousers, vest, watch. null if isValidFashionItem is false",
  "color": "one of: black, white, beige, gray, red, blue, green, yellow, orange, pink, purple, brown, navy, khaki, silver, gold. null if isValidFashionItem is false",
  "pattern": "one of: plain, striped, floral, logo, checkered, graphic, polka dot, geometric. null if isValidFashionItem is false",
  "season": "one of: summer, winter, spring, autumn, all. null if isValidFashionItem is false",
  "material": "one of: cotton, denim, leather, wool, polyester, silk, linen, cashmere, synthetic, gold, silver, metal, plastic, or null if unknown",
  "brand": "the brand name if visible on logo, label, or tag (e.g. Nike, Adidas, Zara, H&M, Gucci, Louis Vuitton, Cartier, Rolex, etc.), or null if no brand is visible"
}

Rules:
- Return ONLY the JSON object, no other text
- FIRST determine if this is a valid fashion item
- If NOT a valid fashion item, set isValidFashionItem to "false" and provide invalidReason
- Use exact values from the lists above for subcategory, color, pattern, season, material
- For jewelry items (ring, necklace, bracelet, earrings, chain, pendant), use appropriate color (gold, silver, etc.)
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
        if (parts.length >= 2) {
          final key = parts[0].trim().replaceAll('"', '');
          // Join remaining parts in case value contains colons (e.g. brand names)
          var value = parts.sublist(1).join(':').trim().replaceAll('"', '');

          // Handle null values
          if (value == 'null') {
            value = '';
          }

          json[key] = value;
        }
      }

      // Build result with validation fields
      final result = {
        'isValidFashionItem': json['isValidFashionItem'] as String?,
        'invalidReason': json['invalidReason'] as String?,
        'subcategory': json['subcategory'] as String?,
        'color': json['color'] as String?,
        'pattern': json['pattern'] as String?,
        'season': json['season'] as String?,
        'material': json['material'] as String?,
        'brand': json['brand'] as String?,
      };

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
