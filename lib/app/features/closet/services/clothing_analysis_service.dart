import 'dart:io';
import 'package:comby/core/core.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for analyzing clothing images using Gemini AI
class ClothingAnalysisService {
  late final GenerativeModel _model;

  // Gemini API Key

  ClothingAnalysisService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: geminiApiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
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

  /// Analyze an outfit photo and provide a critique
  /// Returns a Map with: score (1-10), style, feedback (List<String>), colorHarmony
  Future<Map<String, dynamic>> analyzeOutfit(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      final prompt = '''
Analyze this outfit photo and provide a fashion critique.

Return ONLY a valid JSON object with these exact fields:

{
  "score": "A number from 1 to 100 rating the outfit (integer)",
  "style": "The style category (e.g. Casual, Business, Streetwear, Formal, Bohemian, Chic, Vintage, etc.)",
  "feedback": ["A list of 3 short, constructive, and friendly tips or comments about the outfit."],
  "missingPointsReasons": ["A list of 1-3 specific reasons why points were deducted. E.g. 'colors clash', 'fit is loose', 'accessories missing'. If score is 100, return empty list."],
  "colorHarmony": "One of: Excellent, Good, Average, Needs Improvement"
}

Rules:
- Be constructive and friendly in the feedback
- Focus on color matching, fit, and overall aesthetic
- Return ONLY the JSON object
- Turkish language for values
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      return _parseOutfitResponse(responseText);
    } catch (e) {
      throw ClothingAnalysisException(
        'Failed to analyze outfit: ${e.toString()}',
      );
    }
  }

  Map<String, dynamic> _parseOutfitResponse(String responseText) {
    try {
      String jsonText = responseText;
      if (jsonText.contains('```json')) {
        jsonText =
            jsonText.replaceAll('```json', '').replaceAll('```', '').trim();
      } else if (jsonText.contains('```')) {
        jsonText = jsonText.replaceAll('```', '').trim();
      }

      final jsonStart = jsonText.indexOf('{');
      final jsonEnd = jsonText.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) {
        throw FormatException('No JSON object found in response');
      }

      jsonText = jsonText.substring(jsonStart, jsonEnd + 1);

      // Extract score
      final scoreMatch = RegExp(r'"score":\s*"?(\d+)"?').firstMatch(jsonText);
      final score = int.tryParse(scoreMatch?.group(1) ?? '75') ?? 75;

      // Extract style
      final styleMatch = RegExp(r'"style":\s*"([^"]+)"').firstMatch(jsonText);
      final style = styleMatch?.group(1) ?? 'Günlük';

      // Extract colorHarmony
      final harmonyMatch =
          RegExp(r'"colorHarmony":\s*"([^"]+)"').firstMatch(jsonText);
      final harmony = harmonyMatch?.group(1) ?? 'İyi';

      // Extract feedback list
      final List<String> feedback = [];
      final feedbackMatch =
          RegExp(r'"feedback":\s*\[(.*?)\]', dotAll: true).firstMatch(jsonText);
      if (feedbackMatch != null) {
        final feedbackContent = feedbackMatch.group(1)!;
        final tips = RegExp(r'"([^"]+)"').allMatches(feedbackContent);
        for (final tip in tips) {
          feedback.add(tip.group(1)!);
        }
      }

      if (feedback.isEmpty) {
        feedback.add('Kombinin harika görünüyor!');
      }

      // Extract missingPointsReasons list
      final List<String> missingPointsReasons = [];
      final reasonsMatch =
          RegExp(r'"missingPointsReasons":\s*\[(.*?)\]', dotAll: true)
              .firstMatch(jsonText);
      if (reasonsMatch != null) {
        final reasonsContent = reasonsMatch.group(1)!;
        final reasons = RegExp(r'"([^"]+)"').allMatches(reasonsContent);
        for (final reason in reasons) {
          missingPointsReasons.add(reason.group(1)!);
        }
      }

      return {
        'score': score,
        'style': style,
        'feedback': feedback,
        'missingPointsReasons': missingPointsReasons,
        'colorHarmony': harmony,
      };
    } catch (e) {
      // Fallback
      return {
        'score': 80,
        'style': 'Günlük',
        'feedback': [
          'Harika görünüyorsun!',
          'Renkler çok uyumlu.',
          'Tarzın çok hoş.'
        ],
        'missingPointsReasons': [],
        'colorHarmony': 'İyi',
      };
    }
  }

  /// Uploads the critique image to Firebase Storage
  /// Returns the download URL
  Future<String> uploadCritiqueImage(File imageFile, String userId) async {
    try {
      final fileName = 'critique_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('users/$userId/critiques/$fileName');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw ClothingAnalysisException('Failed to upload image: $e');
    }
  }

  /// Saves the critique result to Firestore
  Future<void> saveCritique(
      String userId, Map<String, dynamic> critiqueData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('critiques')
          .add({
        ...critiqueData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ClothingAnalysisException('Failed to save critique: $e');
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
