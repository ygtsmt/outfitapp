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

  Future<void> connect() async {
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
          _eventController.add({'error': error.toString()});
        },
        onDone: () {
          log('🔌 WebSocket Closed: ${_channel?.closeCode} - ${_channel?.closeReason}');
          print(
              '🔌 WebSocket Closed: ${_channel?.closeCode} - ${_channel?.closeReason}');
          _disconnectCleanup();
          _eventController.add({'status': 'disconnected'});
        },
      );

      // Send Setup Message immediately after connection
      _sendSetupMessage();

      _eventController.add({'status': 'connected'});
      log('✅ Connected to Gemini Live API');
    } catch (e) {
      log('❌ Connection Failed: $e');
      _isConnected = false;
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
  void _sendSetupMessage() {
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
            {
              "text":
                  "You are a helpful AI fashion stylist. You can see the user's wardrobe. If the user speaks Turkish, you MUST reply in Turkish. \n\nCRITICAL: The wardrobe database uses ENGLISH tags (e.g., 'summer', 'winter', 'cotton', 'formal'). \nWhen the user describes a context (e.g., 'hava çok sıcak', 'düğüne gidiyorum'), DO NOT just translate directly. \nINSTEAD, INFER the relevant clothing attributes in English (e.g., 'hot' -> search for 'shorts', 'linen', 't-shirt'; 'wedding' -> search for 'suit', 'dress'). \nAlways search for these English attribute terms to find the best items."
            }
          ]
        },
        "tools": [
          // Define tools here if needed, consistent with REST tools
          {
            "function_declarations": [
              {
                "name": "search_wardrobe",
                "description":
                    "Search for items in the user's wardrobe based on category or query.",
                "parameters": {
                  "type": "OBJECT",
                  "properties": {
                    "query": {
                      "type": "STRING",
                      "description":
                          "Description of the item to search related to"
                    }
                  },
                  "required": ["query"]
                }
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

          // Handle Tool Calls
          if (data.containsKey('toolCall')) {
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
}
