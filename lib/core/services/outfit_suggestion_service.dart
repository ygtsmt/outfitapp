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
      // 1. Determine season and temperature context
      final temp = weather.temperature;
      final Set<String> validSeasons = {
        'all'
      }; // Always include 'all' season items

      String seasonDescription;
      if (temp < 10) {
        seasonDescription = 'winter';
        validSeasons.add('winter');
        validSeasons.add('spring/autumn'); // Layering
      } else if (temp < 25) {
        seasonDescription = 'spring/autumn';
        validSeasons.add('spring/autumn');
        if (temp < 18) validSeasons.add('winter');
        if (temp > 18) validSeasons.add('summer');
      } else {
        seasonDescription = 'summer';
        validSeasons.add('summer');
        validSeasons.add('spring/autumn'); // Light items
      }

      // 2. Filter items by Category & Season
      final allowedCategories = {
        'top',
        'bottom',
        'shoes',
        'outerwear',
        'dress'
      };

      var filteredItems = closetItems.where((item) {
        final category = item.category?.toLowerCase();
        if (category == null || !allowedCategories.contains(category))
          return false;

        final itemSeason = item.season?.toLowerCase() ?? 'all';
        bool isSeasonValid = validSeasons.contains(itemSeason) ||
            validSeasons.any((s) => itemSeason.contains(s));
        return isSeasonValid;
      }).toList();

      // 3. Cap items per category
      filteredItems.shuffle();
      final Map<String, List<WardrobeItem>> itemsByCategory = {};
      for (var item in filteredItems) {
        if (item.category != null) {
          itemsByCategory.putIfAbsent(item.category!, () => []).add(item);
        }
      }

      final truncatedItems = <WardrobeItem>[];
      const maxItemsPerCategory = 15;

      itemsByCategory.forEach((category, items) {
        truncatedItems.addAll(items.take(maxItemsPerCategory));
      });

      // 4. Optimize Payload
      final closetDescriptions = truncatedItems
          .map((c) => {
                'id': c.id,
                'cat': c.category,
                'sub': c.subcategory,
                'col': c.color,
                'sea': c.season,
                'mat': c.material,
              })
          .toList();

      // Limit models
      final limitedModels = models.take(3).toList();
      final modelDescriptions = limitedModels
          .map((m) => {
                'id': m.id,
                'desc': m.aiPrompt ?? 'No description',
                'gender': m.gender,
              })
          .toList();

      final prompt = '''
You are a fashion stylist. Select the best outfit for:
Weather: ${weather.temperature.round()}°C, ${weather.description}, Season: $seasonDescription

MODELS (select 1):
${jsonEncode(modelDescriptions)}

WARDROBE (select from these):
${jsonEncode(closetDescriptions)}

RULES:
1. Select 1 model.
2. Select 1 "top" & 1 "bottom" OR 1 "dress".
3. Select 1 "shoes".
4. If temperature < 15°C, select 1 "outerwear".
5. Match colors.

Return JSON:
{
  "modelId": "id",
  "topId": "id or null",
  "bottomId": "id or null",
  "shoesId": "id or null",
  "outerwearId": "id or null",
  "reasoning": "short reason"
}
JSON:''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      // Pass full lists for parsing to find objects by ID
      return _parseResponse(responseText, models, closetItems);
    } catch (e) {
      // Log the full error for debugging
      print('OutfitSuggestionService Error: $e');
      // Throw a user-friendly message
      throw OutfitSuggestionException(
          'Kombin önerisi oluşturulurken bir sorun oluştu. Lütfen daha sonra tekrar deneyin.');
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

      // Find selected items
      final modelId = json['modelId'] as String?;
      final topId = json['topId'] as String?;
      final bottomId = json['bottomId'] as String?;
      final shoesId = json['shoesId'] as String?;
      final outerwearId = json['outerwearId'] as String?;
      final reasoning = json['reasoning'] as String? ?? '';

      // Map IDs to actual items
      final selectedModel = models.firstWhere(
        (m) => m.id == modelId,
        orElse: () => models.first,
      );

      final selectedItems = <WardrobeItem>[];

      if (topId != null) {
        final top = closetItems.where((c) => c.id == topId).firstOrNull;
        if (top != null) selectedItems.add(top);
      }

      if (bottomId != null) {
        final bottom = closetItems.where((c) => c.id == bottomId).firstOrNull;
        if (bottom != null) selectedItems.add(bottom);
      }

      if (shoesId != null) {
        final shoes = closetItems.where((c) => c.id == shoesId).firstOrNull;
        if (shoes != null) selectedItems.add(shoes);
      }

      if (outerwearId != null) {
        final outerwear =
            closetItems.where((c) => c.id == outerwearId).firstOrNull;
        if (outerwear != null) selectedItems.add(outerwear);
      }

      // If AI didn't find items, try to select manually
      if (selectedItems.isEmpty) {
        // Fallback: select one item from each category if available
        final categories = ['top', 'bottom', 'shoes'];
        for (final category in categories) {
          final item = closetItems.firstWhere(
            (c) => c.category == category,
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
          'Gelen yanıt işlenirken bir sorun oluştu. Lütfen tekrar deneyin.');
    }
  }
}

/// Result of outfit suggestion
class OutfitSuggestion {
  final ModelItem model;
  final List<WardrobeItem> closetItems;
  final String reasoning;

  OutfitSuggestion({
    required this.model,
    required this.closetItems,
    required this.reasoning,
  });

  /// Get all image URLs for outfit generation
  /// First URL is model, rest are clothing items
  List<String> get imageUrls => [
        model.imageUrl,
        ...closetItems.map((c) => c.imageUrl),
      ];
}

/// Custom exception for outfit suggestion errors
class OutfitSuggestionException implements Exception {
  final String message;

  OutfitSuggestionException(this.message);

  @override
  String toString() => message;
}
