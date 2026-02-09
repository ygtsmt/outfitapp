import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import 'package:comby/core/constants/app_constants.dart';

/// Service to analyze user data with Gemini 3 Flash (1M token context)
@injectable
class GeminiWrapperService {
  static const String _modelName = 'gemini-3-flash-preview';

  late final GenerativeModel _model;

  GeminiWrapperService() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
      ),
    );
    print('✨ Gemini Wrapper Service initialized with $_modelName');
  }

  /// Generate Style Wrapped summary from user data
  /// Uses Gemini 3 Flash's 1M token context window
  Stream<String> generateWrapped(Map<String, dynamic> userData) async* {
    print('🤖 Starting Wrapped generation with Gemini 3 Flash');
    print('📊 Estimated input tokens: ${userData['estimatedTokens']}');

    final prompt = _buildPrompt(userData);

    try {
      final response = _model.generateContentStream([Content.text(prompt)]);

      await for (final chunk in response) {
        final text = chunk.text;
        if (text != null) {
          yield text;
        }
      }

      print('✅ Wrapped generation complete');
    } catch (e) {
      print('❌ Error generating wrapped: $e');
      yield 'Error: Failed to generate wrapped summary';
    }
  }

  String _buildPrompt(Map<String, dynamic> userData) {
    final wardrobe = userData['wardrobe'] as Map<String, dynamic>;
    final models = userData['models'] as Map<String, dynamic>;
    final activity = userData['activity'] as Map<String, dynamic>;
    final interactions = userData['interactions'] as Map<String, dynamic>;
    final currentYear = DateTime.now().year;
    final nextYear = currentYear + 1;

    return '''
You are a master fashion analyst and personal stylist creating a "Style Wrapped" summary for a user.
This is a comprehensive review of their entire fashion journey stored in their digital closet.

# 🏁 SYSTEM CONTEXT
- Model: Gemini 3 Flash
- Context Capacity: 1,000,000 Tokens (Enabling deep analysis of full history)
- Input Data Size: ${userData['estimatedTokens']} tokens

# 📂 USER DATASET

## 🏠 WARDROBE DATA
- Total Closet Items: ${wardrobe['totalItems']}
- Category Breakdown: ${wardrobe['analyzedStats']['categoryCount']}
- Color Palette: ${wardrobe['analyzedStats']['colorDistribution']}
- Capsule Score: ${wardrobe['analyzedStats']['capsuleScore']}/100
- Full Item Details:
${_formatWardrobeItems(wardrobe['items'] as List)}

## 👤 MODEL EXPERIMENTS
- Total Models Created: ${models['totalModels']}
- Model Details:
${_formatModelItems(models['models'] as List)}

## 📈 ACTIVITY & HABITS
- Current/Record Streak: ${activity['currentStreak']} days
- Overall Stats: ${activity['overallStats']}
- Activity Patterns (365 days):
${activity['activityHeatmap']}

## 💬 AI CONVERSATIONS
- Total Sessions: ${interactions['totalChatSessions']}
- Full Conversation History:
${_formatChatSessions(interactions['sessions'] as List)}

---

# 🎯 YOUR TASK

Analyze this massive dataset to create an incredibly personalized, engaging, and insightful Spotify Wrapped-style summary.
Since you have access to their ENTIRE history (1M tokens), find deep patterns, style evolutions, and specific details that a normal AI would miss.

Return a JSON object with this exact structure:

{
  "yearInNumbers": {
    "totalItems": number,
    "totalOutfits": number,
    "totalValue": number,
    "daysActive": number,
    "headline": "A punchy, viral-style headline about their fashion year"
  },
  "styleEvolution": {
    "title": "Your Style Evolution",
    "description": "A detailed 3-4 sentence analysis of how their style changed from their first item to their last, referencing specific dates or shifts in category/color.",
    "keyMoments": [
      "Significant moment 1 (e.g., 'In March, you shifted towards more Minimalist pieces')",
      "Significant moment 2",
      "Significant moment 3"
    ]
  },
  "topPowerPieces": [
    {
      "id": "The ID of the item from the dataset",
      "name": "Item Name",
      "reason": "Why this is a 'Power Piece' based on their data or style DNA",
      "icon": "A meaningful emoji for this item"
    }
  ],
  "colorStory": {
    "dominantColors": ["Color Name 1", "Color Name 2", "Color Name 3"],
    "colorPersonality": "A creative description of their personality based on their color choices (e.g., 'Neon Nomad' or 'Monochrome Master')",
    "hexCodes": ["#hex1", "#hex2", "#hex3"]
  },
  "aiInsights": {
    "title": "The AI Stylist's Discovery",
    "discoveries": [
      "Hidden pattern 1 (e.g., 'You always ask about weather before choosing blue items')",
      "Hidden pattern 2",
      "Hidden pattern 3"
    ]
  },
  "futurePredict": {
    "title": "Your $nextYear Vision",
    "predictions": [
      "Predict 1 based on their growth",
      "Predict 2",
      "Predict 3"
    ]
  },
  "geminiPowered": {
    "model": "Gemini 3 Flash",
    "tokensProcessed": ${userData['estimatedTokens']},
    "contextWindow": "1 Million Tokens"
  }
}

Guidelines:
- BE PERSONAL: Mention specific item names or categories they actually own.
- BE SMARTER: Use the 1M token context to link chats from months ago to current wardrobe choices.
- BE ENTHUSIASTIC: Use the tone of a high-end fashion magazine editor.
- NO HALLUCINATIONS: Only reference data actually provided.

Return ONLY the JSON string.
''';
  }

  String _formatWardrobeItems(List items) {
    if (items.isEmpty) return 'No items in closet.';
    return items
        .map((i) =>
            "- [ID: ${i['id']}] ${i['brand'] ?? 'Unknown'} ${i['subcategory'] ?? i['category']} in ${i['color']} (${i['material'] ?? 'Unknown Material'})")
        .join('\n');
  }

  String _formatModelItems(List models) {
    if (models.isEmpty) return 'No models created.';
    return models
        .map((m) => "- Model ${m['id']}: ${m['name'] ?? 'Unnamed'}")
        .join('\n');
  }

  String _formatChatSessions(List sessions) {
    if (sessions.isEmpty) return 'No conversation history.';
    return sessions.map((s) {
      final messages = (s['messages'] as List? ?? [])
          .map((m) => "  [${m['role']}]: ${m['content']}")
          .join('\n');
      return "Session ${s['id']} (${s['createdAt']}):\n$messages";
    }).join('\n\n');
  }
}
