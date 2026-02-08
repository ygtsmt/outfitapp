import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:math' hide log;
import 'package:comby/core/constants/app_constants.dart';

@lazySingleton
class LiveAgentService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  // Stream controller to broadcast events to UI (Audio, Text, etc.)
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> connect({String? userName}) async {
    if (_isConnected) return;

    final uri = Uri.parse(
        'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=$geminiApiKey');

    log('🔌 Connecting to Gemini Live API...');
    print(
        '🔌 Connecting to Gemini Live API at $uri'); // Explicit print for user visibility
    try {
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready; // Wait for connection to be ready
      _isConnected = true;
      print('✅ WebSocket Connected!');

      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          log('❌ WebSocket Error: $error');
          _disconnectCleanup();
          log('🔴 WebSocket Error: $error');
          _eventController.add({"error": "WebSocket Error: $error"});
          disconnect(); // Use disconnect as per snippet
        },
        onDone: () {
          log('🔴 WebSocket Closed'); // Simplified log as per snippet
          disconnect(); // Use disconnect as per snippet
        },
      );

      _isConnected = true;
      log('🟢 Connected to Gemini Live API'); // Updated log as per snippet
      _eventController.add({
        'status': 'connected'
      }); // Added as per original logic, but after connection established

      // Send Setup Message immediately after connection
      _sendSetupMessage(userName: userName); // Pass userName
    } catch (e) {
      log('🔴 Connection Failed: $e'); // Updated log as per snippet
      _isConnected = false;
      _eventController
          .add({"error": "Connection Failed: $e"}); // Added as per snippet
      rethrow;
    }
  }

  void _disconnectCleanup() {
    _isConnected = false;
    _subscription?.cancel();
    _channel = null;
  }

  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
    }
    _disconnectCleanup();
  }

  /// Initial Setup Message to configure the session
  void _sendSetupMessage({String? userName}) {
    // STEP 1: Build supreme rules (from chat)
    final supremeRules = '''

🦾 SUPREME RULES (CRITICAL - NEVER VIOLATE):

1. HALLUCINATION CHECK:
   - If 'search_wardrobe' returns EMPTY or NO items, you MUST say: "I couldn't find any matching items in your wardrobe."
   - NEVER make up clothing items that weren't returned by the tool
   - Only suggest items explicitly listed in the tool response

2. SUPREME HONESTY:
   - If weather data fails, say: "I couldn't get weather data, but based on typical [season] conditions..."
   - NEVER guess temperatures or weather conditions
   - Base all recommendations on actual data or seasonal norms

3. NATURAL LANGUAGE UNDERSTANDING:
   - Understand user INTENT, not just keywords
   - Turkish "sıcak" → search for "shorts", "t-shirt", "linen" (English tags)
   - Turkish "düğün" → search for "suit", "dress", "formal" (English tags)
   - Adapt context naturally without rigid scripts

4. CREATIVE FALLBACK:
   - If a tool fails, find an alternative solution
   - Example: No weather? Use seasonal defaults
   - Example: Empty wardrobe? Suggest building a basic capsule

5. CONVERSATIONAL FLEXIBILITY:
   - If user says "hi", respond naturally as a friendly stylist
   - Don't force tool usage unless contextually needed
   - Casual chat is perfectly acceptable
''';

    // STEP 2: Build full system instruction
    final systemInstruction =
        '''You are "Comby", a professional, friendly, and stylish AI fashion consultant specialized in voice interactions.

${userName != null ? "The user's name is $userName. Address them by name occasionally to create a personal connection." : ""}

### YOUR IDENTITY
You are a conversational voice assistant who helps users with fashion and styling through natural dialogue. You have real-time access to their wardrobe and can provide personalized outfit recommendations.

### CRITICAL DATABASE INFO
The wardrobe database uses ENGLISH tags for all attributes (colors, materials, occasions, seasons, styles).

**CONTEXT-AWARE TAG INFERENCE:**
When users describe their needs in ANY language, you must:
1. **Understand the CONTEXT** (weather, occasion, season, mood, activity)
2. **Infer appropriate clothing attributes** in English
3. **Use multiple related tags** for better search results

**Inference Examples:**
- Hot weather context → "shorts", "linen", "cotton", "lightweight", "breathable", "summer"
- Formal event context → "suit", "dress", "formal", "elegant", "dressy", "business"
- Cold weather context → "winter", "wool", "coat", "sweater", "warm", "insulated"
- Casual context → "casual", "comfortable", "relaxed", "everyday"
- Color mentions → Use English color names: "red", "blue", "black", "white", etc.

**Key Principle:** Think about what clothing ATTRIBUTES would be appropriate for the user's situation, then search using those English keywords.

$supremeRules

### YOUR CAPABILITIES
- Natural voice conversation about fashion and style
- Personalized outfit recommendations based on weather and user's actual wardrobe
- Real-time wardrobe search and analysis
- Style advice and fashion insights

### RESPONSE STYLE
- Keep responses CONCISE for voice interaction (2-3 sentences max unless explaining outfit)
- Speak naturally, as if talking to a friend
- Use Turkish if user speaks Turkish, English if they speak English
- Be encouraging and positive

### AVAILABLE TOOLS
You have access to:
1. **search_wardrobe**: Find clothing items (use English attribute keywords)
2. **get_weather**: Check current weather for better recommendations

**CRITICAL: BE PROACTIVE!**
- When user asks about outfits → AUTOMATICALLY check weather AND search wardrobe
- Don't ask "Should I check the weather?" → JUST DO IT
- Don't ask "Let me look at your wardrobe?" → JUST SEARCH
- You're a stylist, not an assistant. Take initiative!

Example:
❌ BAD: "Should I check the weather for you?"
✅ GOOD: *checks weather automatically* "It's 8°C today, let me find you a warm outfit..."
''';

    final setupMsg = {
      "setup": {
        "model":
            "models/gemini-2.5-flash-native-audio-latest", // Updated to supported model
        "generation_config": {
          "response_modalities": ["AUDIO"], // We want Audio back
          "speech_config": {
            "voice_config": {
              "prebuilt_voice_config": {
                "voice_name": "Kore" // Example voice
              }
            }
          }
        },
        "system_instruction": {
          "parts": [
            {"text": systemInstruction}
          ]
        },
        "tools": [
          // Define tools here if needed, consistent with REST tools
          {
            "function_declarations": [
              {
                "name": "search_wardrobe",
                "description":
                    "Search for clothing items. CRITICAL: Provide a LIST of English keywords and synonyms (e.g. ['trousers', 'pants', 'jeans'] or ['red', 'scarlet']) to ensure matches. The database uses ENGLISH tags only.",
                "parameters": {
                  "type": "OBJECT",
                  "properties": {
                    "queries": {
                      "type": "ARRAY",
                      "items": {"type": "STRING"},
                      "description":
                          "List of English search terms and synonyms. Example: ['summer', 'shorts', 'linen', 't-shirt'] for hot weather."
                    }
                  },
                  "required": ["queries"]
                }
              },
              {
                "name": "get_weather",
                "description":
                    "Get current weather at user's location. Use when user mentions weather-dependent contexts ('hot', 'cold', 'raining') or asks for weather-based advice.",
                "parameters": {"type": "OBJECT", "properties": {}}
              }
            ]
          }
        ]
      }
    };
    _sendJson(setupMsg);
  }

  void _handleMessage(dynamic message) {
    String? textMessage;
    if (message is String) {
      textMessage = message;
    } else if (message is Uint8List) {
      try {
        textMessage = utf8.decode(message);
        log('📦 Converted Binary: ${textMessage.substring(0, min(100, textMessage.length))}...');
      } catch (e) {
        log('❌ Failed to decode binary message: $e');
        print('❌ Failed to decode binary message: $e');
      }
    }

    if (textMessage != null) {
      try {
        final data = jsonDecode(textMessage);
        // log('📩 Recv: $data'); // Verbose logging

        // Check for specific server types
        if (data is Map<String, dynamic>) {
          if (data.containsKey('serverContent')) {
            final content = data['serverContent'];
            if (content is Map<String, dynamic> &&
                content.containsKey('modelTurn')) {
              final parts = content['modelTurn']['parts'] as List;
              for (var part in parts) {
                if (part['text'] != null) {
                  _eventController.add({'text': part['text']});
                }
                if (part['inlineData'] != null) {
                  // Audio data
                  final mimeType = part['inlineData']['mimeType'];
                  if (mimeType.startsWith('audio/')) {
                    log('🔊 Audio Chunk Received');
                    _eventController.add({'audio': part['inlineData']['data']});
                  }
                }
              }
            }
          }

          // Handle Tool Calls with Thought Signatures
          if (data.containsKey('toolCall')) {
            final toolCall = data['toolCall'];
            final functionCalls = toolCall['functionCalls'] as List?;

            if (functionCalls != null) {
              for (var call in functionCalls) {
                String thoughtSignature = '';

                // Try to get thought signature from API
                if (call['thoughtSignature'] != null) {
                  thoughtSignature = call['thoughtSignature'] as String;

                  // Try to decode if base64 (same logic as chat)
                  if (RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(thoughtSignature)) {
                    try {
                      thoughtSignature =
                          utf8.decode(base64Decode(thoughtSignature));
                      log('🔓 Decoded thought signature from base64');
                    } catch (e) {
                      log('⚠️ Could not decode thought signature: $e');
                    }
                  }
                }

                // Fallback: Generate human-friendly thought
                if (thoughtSignature.isEmpty) {
                  thoughtSignature = _generateThoughtSignature(
                    call['name'] as String,
                    call['args'] as Map<String, dynamic>? ?? {},
                  );
                  log('🤖 Generated thought signature for: ${call['name']}');
                }

                // Emit to UI
                _eventController.add({
                  'thought': thoughtSignature,
                  'toolName': call['name'],
                });
                log('💭 Thought: $thoughtSignature');
              }
            }

            // Continue with existing tool call handling
            _eventController.add({'toolCall': data['toolCall']});
          }
        }
      } catch (e) {
        log('❌ Error parsing message: $e');
        print('❌ Error parsing message: $e');
      }
    }
  }

  void _sendJson(Map<String, dynamic> data) {
    if (_channel != null) {
      final jsonString = jsonEncode(data);
      // log('📤 Sending: $jsonString'); // Use log for internal
      if (data.containsKey('setup'))
        print('📤 Sending Setup: $jsonString'); // Explicit print for setup
      _channel!.sink.add(jsonString);
    }
  }

  /// Stream Audio Data (PCM) to the model
  void sendAudioChunk(Uint8List pcmData) {
    if (!_isConnected) return;

    final msg = {
      "realtime_input": {
        "media_chunks": [
          {
            "mime_type": "audio/pcm;rate=16000", // Ensure recorder matches this
            "data": base64Encode(pcmData)
          }
        ]
      }
    };
    _sendJson(msg);
  }

  /// Stream Image Data (JPEG) to the model
  void sendImageFrame(Uint8List jpegBytes) {
    if (!_isConnected) return;

    final msg = {
      "realtime_input": {
        "media_chunks": [
          {"mime_type": "image/jpeg", "data": base64Encode(jpegBytes)}
        ]
      }
    };
    _sendJson(msg);
  }

  /// Send Tool Response back to model
  void sendToolResponse(Map<String, dynamic> response) {
    final msg = {"tool_response": response};
    _sendJson(msg);
  }

  /// Generate dynamic thought signature based on tool context when API doesn't provide one
  /// This creates context-aware thoughts that reflect actual user queries and tool operations
  String _generateThoughtSignature(String toolName, Map<String, dynamic> args) {
    // Natural, human-like thinking messages (like a real stylist)
    final naturalPhrases = {
      'search_wardrobe': [
        '👀 Let me check your closet...',
        '🤔 Hmm, what do you have...',
        '💭 Looking through your wardrobe...',
        '✨ Checking your options...',
      ],
      'get_weather': [
        '🌤️ Checking the weather...',
        '☁️ Let me see what it\'s like outside...',
        '🌡️ Hmm, what\'s the temperature...',
      ],
    };

    final phrases = naturalPhrases[toolName];
    if (phrases != null && phrases.isNotEmpty) {
      // Pick a random phrase for variety
      final randomIndex = DateTime.now().millisecond % phrases.length;
      return phrases[randomIndex];
    }

    // Default for unknown tools
    return '🤔 Thinking...';
  }
}
