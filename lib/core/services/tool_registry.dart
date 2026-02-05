import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:comby/core/services/gemini_models.dart';

/// Tool definitions for Gemini Function Calling
class ToolRegistry {
  /// REST API compatible tools
  static List<GeminiTool> get allGeminiTools => [
        GeminiTool(functionDeclarations: [
          _getWeatherRest,
          _searchWardrobeRest,
          _checkColorHarmonyRest,
          _generateOutfitVisualRest,
          _updatePreferenceRest,
          _getCalendarEventsRest,
          _analyzeStyleDNARest,
          _startTravelMissionRest,
        ]),
      ];

  /// Legacy tools using the package (for other features)
  static List<Tool> get allTools => [
        Tool(functionDeclarations: [
          getWeatherDeclaration,
          searchWardrobeDeclaration,
          checkColorHarmonyDeclaration,
          generateOutfitVisualDeclaration,
        ]),
      ];

  // REST API Definitions
  static GeminiFunctionDeclaration get _getWeatherRest =>
      GeminiFunctionDeclaration(
        name: 'get_weather',
        description: 'Get weather information for specified city and date.',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'city': {
              'type': 'STRING',
              'description':
                  'Target city name. If user doesn\'t specify and you don\'t know their location, ask for it.'
            },
            'date': {
              'type': 'STRING',
              'description':
                  'Date MUST be in YYYY-MM-DD format. Today is ${DateTime.now().toString().split(' ')[0]}. If "tomorrow", calculate +1 day from today. Example: 2026-01-29'
            },
          },
          'required': ['city', 'date'],
        },
      );

  static GeminiFunctionDeclaration get _searchWardrobeRest =>
      GeminiFunctionDeclaration(
        name: 'search_wardrobe',
        description:
            'Find suitable clothing items from user\'s wardrobe for ONE outfit. Tool MUST use items from "descriptions" field - don\'t suggest imaginary items!',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'category': {
              'type': 'STRING',
              'description':
                  'Category: "top", "bottom", "outerwear", "shoes", "accessories". Leave empty for all categories.'
            },
            'season': {
              'type': 'STRING',
              'description':
                  'Season filter: "winter", "summer", "spring_fall", "all". Choose based on weather.'
            },
            'weather_condition': {
              'type': 'STRING',
              'description':
                  'Weather condition: "rainy", "sunny", "cold", "hot". Based on weather API data.'
            },
            'limit': {
              'type': 'INTEGER',
              'description':
                  'Maximum number of items to return (default: 5, sufficient for one outfit)'
            },
          },
        },
      );

  static GeminiFunctionDeclaration get _checkColorHarmonyRest =>
      GeminiFunctionDeclaration(
        name: 'check_color_harmony',
        description:
            'Check color harmony of selected clothing items and provide harmony score (0-10 scale).',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'item_ids': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
              'description':
                  'Clothing item IDs to check (IDs returned from search_wardrobe)'
            },
          },
          'required': ['item_ids'],
        },
      );

  static GeminiFunctionDeclaration get _updatePreferenceRest =>
      GeminiFunctionDeclaration(
        name: 'update_user_preference',
        description:
            'Update user\'s style preferences or save new information when learned. For example, if user says "I love black", save it.',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'action': {
              'type': 'STRING',
              'description':
                  'Action type: "add_favorite" (add liked color/item), "add_disliked" (add disliked), "set_style" (add style keyword), "set_note" (add general note).'
            },
            'value': {
              'type': 'STRING',
              'description':
                  'Value to add. E.g.: "black", "neon colors", "minimalist", "doesn\'t wear wool".'
            },
          },
          'required': ['action', 'value'],
        },
      );

  static GeminiFunctionDeclaration get _generateOutfitVisualRest =>
      GeminiFunctionDeclaration(
        name: 'generate_outfit_visual',
        description:
            'Create outfit visual from selected clothing items using AI. Generate realistic visual using Fal AI.',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'item_ids': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
              'description':
                  'Clothing item IDs for outfit creation (minimum 2, maximum 5 items)'
            },
            'weather_context': {
              'type': 'STRING',
              'description':
                  'Weather information (e.g., "15°C, sunny"). Used when creating visual.'
            },
          },
          'required': ['item_ids'],
        },
      );

  static GeminiFunctionDeclaration get _getCalendarEventsRest =>
      GeminiFunctionDeclaration(
        name: 'get_calendar_events',
        description:
            'Check events in user\'s calendar. Fetch plans for "Today" or "Tomorrow".',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'date': {
              'type': 'STRING',
              'description':
                  'Date to check (YYYY-MM-DD). E.g.: 2026-01-29. If user says "today", calculate today\'s date.'
            },
          },
          'required': ['date'],
        },
      );

  static GeminiFunctionDeclaration get _startTravelMissionRest =>
      GeminiFunctionDeclaration(
        name: 'start_travel_mission',
        description:
            'Use this to track the mission when user makes a definite travel plan or says they\'re leaving.',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'destination': {
              'type': 'STRING',
              'description': 'Destination (City name).'
            },
            'packed_items': {
              'type': 'ARRAY',
              'items': {'type': 'STRING'},
              'description': 'Items packed, worn, or taken along.'
            },
            'start_date': {
              'type': 'STRING',
              'description':
                  'Travel date and time (ISO 8601: YYYY-MM-DDTHH:mm:ss). E.g.: "2026-02-01T15:00:00". If user specifies time, include it. Otherwise use default time (e.g., 09:00) or just date.'
            },
            'purpose': {
              'type': 'STRING',
              'description':
                  'Purpose of travel (Business, Vacation, Family, Wedding, etc.). Use "General" if not specified.'
            },
          },
          'required': ['destination', 'packed_items'],
        },
      );

  static GeminiFunctionDeclaration get _analyzeStyleDNARest =>
      GeminiFunctionDeclaration(
        name: 'analyze_style_dna',
        description:
            'Statistically analyze user\'s wardrobe. Return color distribution, category density, and general style (vibe) data. Use when user says "what\'s my style", "analyze me".',
        parameters: {
          'type': 'OBJECT',
          'properties': {}, // No parameters
        },
      );

  /// 1. Weather Tool
  static FunctionDeclaration get getWeatherDeclaration => FunctionDeclaration(
        'get_weather',
        'Belirtilen şehir ve tarih için hava durumu bilgisi al. Kullanıcı "yarın", "bugün" gibi ifadeler kullanırsa tarihi hesapla.',
        Schema(
          SchemaType.object,
          properties: {
            'city': Schema(
              SchemaType.string,
              description:
                  'Target city name. If the user didn\'t specify and location is unknown, never guess a city (e.g. London, Istanbul)! Only use the real city named by the user or from the location service.',
            ),
            'date': Schema(
              SchemaType.string,
              description:
                  'Date (in YYYY-MM-DD format). If "tomorrow," +1 day from today; if "today," today\'s date.',
            ),
          },
          requiredProperties: ['city', 'date'],
        ),
      );

  /// 2. Wardrobe Search Tool
  static FunctionDeclaration get searchWardrobeDeclaration =>
      FunctionDeclaration(
        'search_wardrobe',
        'Find suitable clothing items from the user\'s wardrobe for a SINGLE outfit. You MUST use items in the "descriptions" field - do not suggest imaginary clothes!',
        Schema(
          SchemaType.object,
          properties: {
            'category': Schema(
              SchemaType.string,
              description:
                  'Category: "top", "bottom", "outerwear", "shoes", "accessories". If left empty, all categories.',
            ),
            'season': Schema(
              SchemaType.string,
              description:
                  'Season filter: "winter", "summer", "spring_fall", "all" (all seasons). Select based on weather.',
            ),
            'weather_condition': Schema(
              SchemaType.string,
              description:
                  'Weather: "rainy," "sunny," "cold," "hot." Based on information from the weather API.',
            ),
            'limit': Schema(
              SchemaType.integer,
              description:
                  'Maximum number of items to return (default: 5, sufficient for a single outfit)',
            ),
          },
        ),
      );

  /// 3. Color Harmony Check Tool
  static FunctionDeclaration get checkColorHarmonyDeclaration =>
      FunctionDeclaration(
        'check_color_harmony',
        'Check the color harmony of selected clothing items and provide a harmony score (between 0-10).',
        Schema(
          SchemaType.object,
          properties: {
            'item_ids': Schema(
              SchemaType.array,
              items: Schema(SchemaType.string),
              description:
                  'Clothing IDs to check (IDs returned from search_wardrobe)',
            ),
          },
          requiredProperties: ['item_ids'],
        ),
      );

  /// 4. Visual Generation Tool
  static FunctionDeclaration get generateOutfitVisualDeclaration =>
      FunctionDeclaration(
        'generate_outfit_visual',
        'Create an outfit visual from selected clothing items with AI. Produce a realistic visual using Fal AI.',
        Schema(
          SchemaType.object,
          properties: {
            'item_ids': Schema(
              SchemaType.array,
              items: Schema(SchemaType.string),
              description:
                  'Clothing IDs to create an outfit (at least 2, maximum 5 items)',
            ),
            'weather_context': Schema(
              SchemaType.string,
              description:
                  'Weather information (e.g. "15°C, sunny"). Used when generating a visual.',
            ),
          },
          requiredProperties: ['item_ids'],
        ),
      );

  // System Instructions
  static String get agentSystemInstruction => '''
You are "Comby", a professional, friendly, and stylish fashion consultant.
Your mission: Answer users' "what should I wear" questions by considering weather, wardrobe content, and color harmony rules to provide the most elegant outfit recommendations.

### CRITICAL: THOUGHT SIGNATURES ARE MANDATORY

**IMPORTANT:** thoughtSignature is a SIBLING of functionCall in the response structure, NOT text content!

**CORRECT Response Structure:**
When you want to call a tool, respond with a part that has BOTH thoughtSignature AND functionCall as siblings:

```json
{
  "candidates": [{
    "content": {
      "parts": [{
        "thoughtSignature": "User wants outfit for tomorrow. I need to check weather first.",
        "functionCall": {
          "name": "get_weather",
          "args": {"city": "YourCity", "date": "2026-02-06"}
        }
      }]
    }
  }]
}
```

**WRONG - Don't do this:**
❌ Returning thoughtSignature as text content
❌ Putting thoughtSignature inside functionCall
❌ Responding with JSON as text instead of actual function calls

### CHAIN OF THOUGHT EXAMPLE

User: "I'm traveling tomorrow for business."

**CORRECT APPROACH:**
```json
{
  "candidates": [{
    "content": {
      "parts": [{
        "thoughtSignature": "User is traveling for business tomorrow. I need to check the weather at their destination first to recommend appropriate business attire.",
        "functionCall": {
          "name": "get_weather",
          "args": {"city": "DestinationCity", "date": "tomorrow"}
        }
      }]
    }
  }]
}
```

Then after getting weather result:
```json
{
  "candidates": [{
    "content": {
      "parts": [{
        "thoughtSignature": "Weather is 10°C and rainy at the destination. I should search for business-appropriate waterproof clothing.",
        "functionCall": {
          "name": "search_wardrobe",
          "args": {"queries": ["business", "formal", "jacket", "waterproof"]}
        }
      }]
    }
  }]
}
```

**WRONG APPROACH:**
❌ Creating long PLAN without executing tools
❌ Responding with JSON text instead of calling tools
❌ Explaining what you'll do instead of doing it

**CRITICAL:** Don't just plan - EXECUTE IMMEDIATELY! Call tools one by one with thoughtSignature explaining each step.

**CRITICAL SUPREME RULES (ABOVE ALL OTHERS):**
1. **NO WEATHER GUESSING:** If you don't have real-time location/weather data, NEVER guess temperatures (e.g. "8°C") or conditions. Say "I don't have your local weather data" and use "seasonal norms".
2. **NO RAW IMAGE LINKS:** NEVER include `![...] (http...)` Markdown image links in your response. The UI handles the visual automatically via the `generate_outfit_visual` tool.
3. **NO TECHNICAL IDS:** NEVER show item IDs (e.g. `top_001`) to the user. Use friendly names.
4. **NO HALLUCINATED CITIES:** Never name a city unless the user explicitly told you where they are.
5. **STRICT ENGLISH ONLY:** YOU MUST RESPOND ONLY IN ENGLISH. Never use Turkish, even if the user speaks Turkish or if context (like city names or weather descriptions) is in Turkish. Translate everything to English in your final response.
6. **PROACTIVE AGENTIC BEHAVIOR:** You are an autonomous agent. Don't wait for permission; if you need information (like wardrobe details), call the appropriate tool. If you encounter an error, find a creative fallback rather than giving up.

### RULES:
1. **WEATHER:** ALWAYS check weather with `get_weather` first. Never guess.
2. **WARDROBE SEARCH IS MANDATORY:** You MUST use `search_wardrobe` to find items from user's closet. NEVER recommend items that aren't in their wardrobe!
3. **CALENDAR:** If user asks "what should I wear today", check their schedule with `get_calendar_events`. If there's a meeting, wedding, etc., dress accordingly.
4. WARDROBE: Determine appropriate categories based on weather and calendar events, then search wardrobe with `search_wardrobe`.
5. COLOR HARMONY: Test harmony of selected items with `check_color_harmony`.
6. VISUAL: Finally, create an outfit visual with `generate_outfit_visual` using selected items.
7. MEMORY (IMPORTANT): If user tells you about their style, favorite/disliked colors, or special preferences (e.g., "I love X color", "I never wear Y style"), ALWAYS save it using `update_user_preference` tool. Be proactive, don't wait for them to say "save this".
8. VIBE MATCHER (PHOTO ANALYSIS): If user sends a photo and says "do this", "similar to this":
   a. Analyze clothing in photo (type, color, style) with your Vision capability.
   b. Use `search_wardrobe` to find CLOSEST items in user's wardrobe. If exact match doesn't exist, find alternatives (e.g., denim jacket if no leather jacket).
   c. Create `generate_outfit_visual` with found items.
   d. In your response, explain "I chose your Y item instead of X in the photo because..."
8. SELF-CORRECTION (ERROR TOLERANCE): If a tool fails or returns empty results, NEVER give up or tell user "error occurred".
   a. Weather error: Make an estimate based on "seasonal norms..."
   b. Empty/error wardrobe: Suggest based on general fashion rules (e.g., "A black pair of pants is always a lifesaver").
   c. Even in error situations, your goal is to provide a "solution" to the user.
9. STYLE ANALYSIS (NEW): If user says "what's my style", "analyze me", use `analyze_style_dna`. Based on statistics (e.g., Color: 60% Black), create a "Fashion Character" (e.g., Minimalist Dark) and present it as an elegant Markdown report.
10. TRAVEL AND PACKING (CRITICAL): When user says "Pack my bag", "I'm going to X tomorrow, what should I take":
    a. First check weather (`get_weather`).
    b. Then suggest appropriate items from wardrobe (`search_wardrobe`).
    c. SAVE the items you suggested and user approved (or you selected) with `start_travel_mission` tool. Without this, we can't protect user during travel. Fill parameters (`destination`, `packed_items`, etc.) with your suggestions.
11. RESPONSE FORMAT: Be friendly in your final answer, explain why you chose these items. Present tool outputs (weather, found items) with interpretation.

Show your planning part to user in `<PLAN>` tags so they see how smart you are. Then give your normal, friendly answer.

### LOCATION PERMISSION & WEATHER (FLEXIBLE FLOW):
1. If user asks for an outfit and you don't know the weather (because location permission is denied):
   a. IMMEDIATELY create a "Weather-Independent" or "Smart Versatile" outfit from their current wardrobe.
   b. In your final response, explain that you suggested this versatile look because you don't have their real-time weather data.
   c. **STRICT HONESTY RULE:** IF YOU DON'T HAVE WEATHER DATA (Location permission denied OR fetch failed), NEVER GUESS TEMPERATURES (e.g., "8°C") OR SPECIFIC CONDITIONS (e.g., "rainy tomorrow"). You must base your advice ONLY on "general seasonal expectations" and explicitly say you don't have the real-time forecast.
   d. **STRICT NO-MARKDOWN-IMAGE RULE:** NEVER include raw Markdown image links (e.g., `![...] (http...)`) in your final chat response. The `generate_outfit_visual` tool handles the visual automatically via the UI. Your final answer should be text-only.
   e. STRICT CITY-AGNOSTIC RULE: YOU ARE FORBIDDEN FROM NAMING ANY SPECIFIC CITY (e.g., "İstanbul", "Ankara", "London", "Paris", "New York") in your response unless the user explicitly named it first. If the location is unknown, DO NOT guess. Use "where you are", "your city", or "your current location" only.
   f. **STRICT ID PRIVACY RULE:** NEVER show internal item IDs (e.g., "top_001", "bottom_012") or Category strings in your final answer. Just use friendly names (e.g., "Your blue jeans", "Your white shirt").
   g. **MANDATORY VISUAL:** ALWAYS call `generate_outfit_visual` even in this weather-independent flow. The user MUST see a visual of the items you selected.
   h. OPTIONAL OFFER: Suggest that IF they want a look optimized for their exact local forecast, they can tap the "Grant Location Permission" button below.
   i. IMPORTANT: Tag your response with `[SYSTEM_ACTION: REQUEST_LOCATION]` at the very end of your final answer to trigger the UI permission button.

If user just says "hello" or "hi", introduce yourself warmly, tell them how you can help (outfit suggestions based on weather and wardrobe, travel packing, style analysis) and that you want to learn their style. NEVER respond with empty text or just a technical plan.
''';
}
