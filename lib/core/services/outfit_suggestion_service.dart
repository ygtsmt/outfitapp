import 'dart:convert';
import 'package:comby/core/core.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/app/features/dashboard/data/models/weather_model.dart';

/// Service for AI-powered outfit suggestion based on weather
class OutfitSuggestionService {
  late final GenerativeModel _model;

  // Gemini API Key (same as ClothingAnalysisService)

  OutfitSuggestionService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: geminiApiKey,
    );
  }

  /// Suggests an outfit based on weather conditions
  /// Returns a map with selected model and closet item IDs
  Future<OutfitSuggestion?> suggestOutfit({
    required WeatherModel weather,
    required List<ModelItem> models,
    required List<WardrobeItem> closetItems,
  }) async {
    if (models.isEmpty || closetItems.isEmpty) {
      return null;
    }

    try {
      // Prepare full wardrobe data for AI (no filtering!)
      final closetDescriptions = closetItems
          .map((c) => {
                'id': c.id,
                'category': c.category,
                'subcategory': c.subcategory,
                'color': c.color,
                'season': c.season,
                'material': c.material,
                'brand': c.brand,
              })
          .toList();

      // Prepare model data
      final modelDescriptions = models
          .map((m) => {
                'id': m.id,
                'description': m.aiPrompt ?? 'No description',
                'gender': m.gender,
                'bodyPart': m.bodyPart,
              })
          .toList();

      // Fully agentic prompt - AI makes ALL decisions
      final prompt = '''
You are an expert fashion stylist. Create a complete, weather-appropriate outfit.

WEATHER CONTEXT:
- Temperature: ${weather.temperature.round()}°C
- Condition: ${weather.description}

AVAILABLE MODELS:
${jsonEncode(modelDescriptions)}

AVAILABLE WARDROBE ITEMS:
${jsonEncode(closetDescriptions)}

YOUR TASK:
1. Analyze the weather and determine what type of outfit is needed
2. Select 1 model that best fits the outfit type
3. Choose clothing items that create a complete, stylish outfit
4. Consider: weather appropriateness, color harmony, style coherence, layering if needed
5. You decide how many items and which categories - no strict rules!

RETURN THIS EXACT JSON FORMAT:
{
  "modelId": "selected_model_id",
  "selectedItemIds": ["item_id_1", "item_id_2", "item_id_3"],
  "reasoning": "Brief explanation of your choices"
}

JSON:''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      return _parseResponse(responseText, models, closetItems);
    } catch (e) {
      print('OutfitSuggestionService Error: $e');
      throw OutfitSuggestionException(
          'A problem occurred while creating the outfit suggestion. Please try again later.');
    }
  }

  OutfitSuggestion? _parseResponse(
    String responseText,
    List<ModelItem> models,
    List<WardrobeItem> closetItems,
  ) {
    try {
      // Remove markdown code blocks if present
      String jsonText = responseText;
      if (jsonText.contains('```json')) {
        jsonText =
            jsonText.replaceAll('```json', '').replaceAll('```', '').trim();
      } else if (jsonText.contains('```')) {
        jsonText = jsonText.replaceAll('```', '').trim();
      }

      // Find JSON object
      final jsonStart = jsonText.indexOf('{');
      final jsonEnd = jsonText.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) {
        throw FormatException('No JSON object found');
      }

      jsonText = jsonText.substring(jsonStart, jsonEnd + 1);
      final json = jsonDecode(jsonText) as Map<String, dynamic>;

      // Parse AI's selections
      final modelId = json['modelId'] as String?;
      final selectedItemIds =
          (json['selectedItemIds'] as List?)?.cast<String>() ?? [];
      final reasoning = json['reasoning'] as String? ?? '';

      // Find selected model
      final selectedModel = models.firstWhere(
        (m) => m.id == modelId,
        orElse: () => models.first,
      );

      // Find selected items by IDs
      final selectedItems = closetItems
          .where((item) => selectedItemIds.contains(item.id))
          .toList();

      // Fallback: if AI didn't select any items, pick some automatically
      if (selectedItems.isEmpty) {
        print('⚠️ AI returned no items, using fallback selection');
        final categories = ['top', 'bottom', 'shoes'];
        for (final category in categories) {
          final item = closetItems.firstWhere(
            (c) => c.category?.toLowerCase() == category,
            orElse: () => closetItems.first,
          );
          if (!selectedItems.contains(item)) {
            selectedItems.add(item);
          }
        }
      }

      return OutfitSuggestion(
        model: selectedModel,
        closetItems: selectedItems,
        reasoning: reasoning,
      );
    } catch (e) {
      print('OutfitSuggestionService Parse Error: $e');
      throw OutfitSuggestionException(
          'A problem occurred while processing the response. Please try again.');
    }
  }
}

/// Result of outfit suggestion
class OutfitSuggestion {
  final ModelItem model;
  final List<WardrobeItem> closetItems;
  final String reasoning;
  final String? generatedImageUrl;

  OutfitSuggestion({
    required this.model,
    required this.closetItems,
    required this.reasoning,
    this.generatedImageUrl,
  });

  OutfitSuggestion copyWith({
    ModelItem? model,
    List<WardrobeItem>? closetItems,
    String? reasoning,
    String? generatedImageUrl,
  }) {
    return OutfitSuggestion(
      model: model ?? this.model,
      closetItems: closetItems ?? this.closetItems,
      reasoning: reasoning ?? this.reasoning,
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
    );
  }

  /// Get all image URLs for outfit generation
  /// First URL is model, rest are clothing items
  List<String> get imageUrls => [
        model.imageUrl,
        ...closetItems.map((c) => c.imageUrl),
      ];

  Map<String, dynamic> toJson() {
    return {
      'model': model.toJson(), // Assuming ModelItem has toJson, need to verify
      'closetItems': closetItems
          .map((c) => c.toJson())
          .toList(), // WardrobeItem toJson needed
      'reasoning': reasoning,
      'generatedImageUrl': generatedImageUrl,
    };
  }

  factory OutfitSuggestion.fromJson(Map<String, dynamic> json) {
    return OutfitSuggestion(
      model: ModelItem.fromJson(json['model']), // Assuming ModelItem.fromJson
      closetItems: (json['closetItems'] as List)
          .map((c) => WardrobeItem.fromJson(c)) // WardrobeItem.fromJson needed
          .toList(),
      reasoning: json['reasoning'],
      generatedImageUrl: json['generatedImageUrl'],
    );
  }
}

/// Custom exception for outfit suggestion errors
class OutfitSuggestionException implements Exception {
  final String message;

  OutfitSuggestionException(this.message);

  @override
  String toString() => message;
}
