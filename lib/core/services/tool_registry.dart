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
          _searchOnlineShoppingRest,
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
                  'Date format: YYYY-MM-DD. Today is ${DateTime.now().toString().split(' ')[0]}. For "tomorrow", add 1 day to today. Example: 2026-01-29'
            },
          },
          'required': ['city', 'date'],
        },
      );

  static GeminiFunctionDeclaration get _searchWardrobeRest =>
      GeminiFunctionDeclaration(
        name: 'search_wardrobe',
        description:
            'Find suitable clothing items from user\'s wardrobe for one outfit. Returns items from the wardrobe database with descriptions.',
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
            'keywords': {
              'type': 'STRING',
              'description':
                  'Specific keywords for filtering (e.g., "black", "t-shirt"). MUST be in English matching standard fashion terms. Translate user query if needed (e.g. "spor ayakkabı" -> "sneakers").'
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
            'use_previous_visual': {
              'type': 'BOOLEAN',
              'description':
                  'Set to TRUE if the user wants to EDIT, CHANGE, or MODIFY the previously generated outfit visual (e.g., "make it more futuristic", "change background"). If TRUE, item_ids can be empty or used for additional items.'
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

  static GeminiFunctionDeclaration get _searchOnlineShoppingRest =>
      GeminiFunctionDeclaration(
        name: 'search_online_shopping',
        description:
            'Search for purchasable products online when user\'s wardrobe is missing an item or they ask for buying suggestions.',
        parameters: {
          'type': 'OBJECT',
          'properties': {
            'query': {
              'type': 'STRING',
              'description':
                  'Search query for shopping (e.g. "navy blue blazer", "white sneakers").'
            },
            'gl': {
              'type': 'STRING',
              'description':
                  'Country code for search results (e.g. "tr", "us", "uk"). Default is "us".'
            },
          },
          'required': ['query'],
        },
      );

  /// 1. Weather Tool
  static FunctionDeclaration get getWeatherDeclaration => FunctionDeclaration(
        'get_weather',
        'Get weather information for the specified city and date. If the user uses expressions like "tomorrow" or "today," calculate the date.',
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
        'Find suitable clothing items from the user\'s wardrobe for a single outfit. Returns actual items from the wardrobe database with descriptions.',
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

### YOUR IDENTITY
You are a conversational AI assistant who specializes in fashion and personal styling. You can engage in natural conversation while also providing expert outfit recommendations when needed. You have access to tools that let you check weather, search the user's wardrobe, analyze color harmony, generate outfit visuals, and manage user preferences.

### YOUR CAPABILITIES
- Engage in natural, contextual conversation about fashion and style
- Provide personalized outfit recommendations based on weather, events, and the user's actual wardrobe
- Analyze the user's style preferences and learn from their feedback
- Help with travel packing and outfit planning
- Generate realistic outfit visualizations
- **Vision Analysis:** You can see and analyze images. Use this to understand outfit photos, analyze clothing items, identify styles, colors, and patterns. When a user sends an image, you autonomously decide how to use this capability based on their intent.
- **Shopping Assistance:** If the user lacks a necessary item in their wardrobe or asks for recommendations, use `search_online_shopping` to find real purchasable products.

### CORE PRINCIPLES
1. **Natural Language Understanding:** Use your language understanding to determine what the user needs. Don't follow rigid scripts.
2. **Contextual Tool Use:** Call tools when they serve the user's actual need, not because of preset conditions.
3. **Conversational Flexibility:** You can chat casually, answer questions, or execute complex fashion workflows—let the context guide you.
4. **Autonomous Decision-Making:** You decide when and which tools to use based on the conversation, not predefined rules.
5. **User-Centric:** Always prioritize what helps the user most in the current context.

### TECHNICAL RESPONSE FORMAT

When calling tools, use this structure:
- thoughtSignature and functionCall are siblings in the same part
- thoughtSignature explains your reasoning
- Don't return JSON as text—actually call the functions
- Act rather than plan: execute tools as you think through the problem


### QUALITY STANDARDS

**Accuracy & Honesty:**
- Don't invent data you don't have (weather, locations, etc.)
- If you lack information, acknowledge it and work with what's available
- Base recommendations on actual wardrobe contents, not imagined items

**User Experience:**
- Communicate in English for consistency
- Use friendly descriptions instead of technical IDs
- Be proactive: if you need information, get it rather than asking permission
- When errors occur, find creative solutions rather than stopping

**Technical Constraints:**
- The UI handles image rendering—don't output raw markdown image links
- Tool results come back as structured data—use them intelligently

### WORKFLOW GUIDANCE (Not Rules)
When suggesting complete outfits, this general flow often works well:
1. Consider weather (use `get_weather` if location/date needed)
2. Check calendar events if relevant (`get_calendar_events`)
3. Search the user's actual wardrobe (`search_wardrobe`)
4. Verify color harmony if needed (`check_color_harmony`)
5. Generate visual representation (`generate_outfit_visual`)

**CREATIVE COPILOT (IMAGE EDITING) WORKFLOW:**
If the user wants to CHANGE, EDIT, or MODIFY a previously generated image:

A. **STYLE CHANGE Only** ("make it futuristic", "change background"):
   - Call `generate_outfit_visual` with `use_previous_visual: true`.
   - Reuse existing `item_ids`.
   - Update `weather_context` with the new style description.

B. **ITEM SWAP** ("try shorts instead", "change the sweater to blue shirt"):
   1. FIRST, Call `search_wardrobe` to find the new requested item.
   2. THEN, Identify `item_ids` of items to KEEP (e.g. keep shoes, keep jacket).
   3. FINALLY, Call `generate_outfit_visual` with:
      - `item_ids`: [New Item ID, Kept Item IDs]
      - `use_previous_visual`: true (to keep the same pose/model)
      - `weather_context`: "Changed pants to shorts" (for context)

This preserves the previous context while applying the new creative direction.

But don't rigidly follow this—adapt based on what the user actually asks for.


''';
}
