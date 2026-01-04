import 'dart:io';
import 'package:ginfit/core/core.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service for analyzing model/human images using Gemini AI
/// Used to validate if an image is suitable for outfit try-on
class ModelAnalysisService {
  late final GenerativeModel _model;

  // Gemini API Key

  ModelAnalysisService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: geminiApiKey,
    );
  }

  /// Analyze an image and determine if it's a valid model/human for outfit try-on
  /// Returns a Map with: isValidModel, invalidReason, personCount, bodyPart, gender, bodyType, pose, skinTone, suggestedName
  Future<Map<String, String?>> analyzeModel(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Create prompt for structured output
      const prompt = '''
Analyze this image and determine if it contains a person/model suitable for virtual outfit try-on.

Return ONLY a valid JSON object with these exact fields:

{
  "isValidModel": "true if this image shows any part of a human body (face, upper body, lower body, hands, feet, etc.) that can be used for virtual outfit or accessory try-on. false ONLY if this is NOT a human at all (e.g. animals, objects, landscapes, food, buildings, etc.)",
  "invalidReason": "if isValidModel is false, describe why (e.g. 'This is a cat', 'This is a landscape photo', 'No human visible'). null if isValidModel is true",
  "personCount": "number of people in the image as a string (e.g. '1', '2', '3'). '0' if no human visible",
  "bodyPart": "what part of body is visible. one of: full_body, upper_body, lower_body, face_only, hands_only, feet_only, back_view. Describe the main visible part. null if isValidModel is false",
  "gender": "one of: male, female, unisex, mixed (if multiple people with different genders). Based on visible appearance. null if isValidModel is false",
  "bodyType": "one of: slim, average, athletic, curvy, plus-size, mixed. Based on visible body shape. null if isValidModel is false or only face visible",
  "pose": "one of: standing, sitting, walking, lying, casual, formal, action. Describe the person's pose. null if isValidModel is false",
  "skinTone": "one of: fair, light, medium, tan, dark, mixed. Based on visible skin. null if isValidModel is false",
  "suggestedName": "a descriptive name for this model based on appearance and visible body parts (e.g. 'Casual Summer Look', 'Feet Model', 'Group Photo - 3 People', 'Face Portrait'). null if isValidModel is false",
  "aiPrompt": "a detailed English description of the PERSON/MODEL in this image that can be used to identify them for outfit try-on. Be VERY specific about their physical appearance: hair color and style, face features, skin tone, body type, pose, background, lighting, etc. Example: 'A young woman with long brown hair, fair skin, slim body type, standing in a neutral pose against a white background, wearing minimal makeup with natural lighting'. This description should be detailed enough to distinguish this specific person from any clothing items in other photos. null if isValidModel is false"
}

IMPORTANT RULES:
- ANY human body part is valid (face only = OK for glasses/earrings, feet only = OK for shoes, etc.)
- Multiple people in one photo = VALID, just set personCount correctly
- The ONLY invalid case is when there is NO human at all
- Return ONLY the JSON object, no other text
- Use exact values from the lists above
- The aiPrompt field is CRITICAL - it should be a detailed, unique description of the person that can be used in prompt engineering

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
      throw ModelAnalysisException(
        'Failed to analyze model: ${e.toString()}',
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
        throw const FormatException('No JSON object found in response');
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
          // Join remaining parts in case value contains colons
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
        'isValidModel': json['isValidModel'] as String?,
        'invalidReason': json['invalidReason'] as String?,
        'personCount': json['personCount'] as String?,
        'bodyPart': json['bodyPart'] as String?,
        'gender': json['gender'] as String?,
        'bodyType': json['bodyType'] as String?,
        'pose': json['pose'] as String?,
        'skinTone': json['skinTone'] as String?,
        'suggestedName': json['suggestedName'] as String?,
        'aiPrompt': json['aiPrompt'] as String?,
      };

      return result;
    } catch (e) {
      throw ModelAnalysisException(
        'Failed to parse response: ${e.toString()}\nResponse: $responseText',
      );
    }
  }
}

/// Custom exception for model analysis errors
class ModelAnalysisException implements Exception {
  final String message;

  ModelAnalysisException(this.message);

  @override
  String toString() => message;
}
