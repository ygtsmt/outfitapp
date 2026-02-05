import 'dart:io';
import 'dart:developer';
import 'package:injectable/injectable.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/core/services/agent_service.dart';
import 'package:comby/app/features/chat/models/agent_models.dart';
import 'package:comby/core/services/gemini_rest_service.dart';
import 'package:comby/core/services/gemini_models.dart';
import 'dart:convert';
import 'package:comby/core/services/tool_registry.dart';

sealed class ChatResult {}

class ChatTextResult extends ChatResult {
  final String text;
  final List<AgentStep>? agentSteps;
  final String? imageUrl;
  final String? visualRequestId;

  ChatTextResult(
    this.text, {
    this.agentSteps,
    this.imageUrl,
    this.visualRequestId,
  });
}

class ChatSearchResult extends ChatResult {
  final String query;
  ChatSearchResult(this.query);
}

@injectable
class ChatUseCase {
  final ClosetUseCase _closetUseCase;
  final AgentService _agentService;
  final GeminiRestService _geminiService;

  // Manuel history tracking
  final List<GeminiContent> _chatHistory = [];

  // Model
  final String _model =
      'gemini-3-flash-preview'; // Faster than Pro, same thought signature support

  bool _wardrobeSent = false;

  ChatUseCase(
    this._closetUseCase,
    this._agentService,
    this._geminiService,
  ) {
    // Warm-up greeting
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Başlangıçta boş history ile hazır
  }

  /// Kullanıcının gardırobunu JSON formatında al
  Future<String> _getWardrobeContext() async {
    try {
      final items = await _closetUseCase.getUserClosetItems();

      if (items.isEmpty) {
        return 'User\'s wardrobe is empty.';
      }

      final itemsJson = items
          .map((item) => {
                'id': item.id,
                'imageUrl': item.imageUrl,
                'category': item.category,
                'subcategory': item.subcategory,
                'color': item.color,
                'pattern': item.pattern,
                'season': item.season,
                'material': item.material,
                'brand': item.brand,
              })
          .toList();

      return '''
USER'S WARDROBE (${items.length} items):
${jsonEncode(itemsJson)}

IMPORTANT INSTRUCTIONS:
1. Respond to the user in NATURAL LANGUAGE, don't show JSON!
2. When describing clothing, only use imageUrls, don't show in JSON format.
3. Example good response: "You have 1 white sweater in your wardrobe. imageUrl: https://..."
4. Example bad response: [{"id":"123", "imageUrl":"https://..."...}]
''';
    } catch (e) {
      return 'Failed to get wardrobe info: $e';
    }
  }

  Future<ChatResult> sendMessage(
    String message, {
    List<String>? mediaPaths,
    void Function(String)? onAgentStep, // NEW: Step Callback
  }) async {
    // 🤖 Outfit önerisi mi? Agent'a yönlendir
    // 🤖 Text mesajı ise direkt Agent'a yönlendir (Hafıza ve Tool yetenekleri için)
    // Medya varsa (şimdilik) normal akıştan devam edebilir veya ilerde Agent'a medya desteği eklenebilir.
    // 🤖 Agent her zaman devreye girsin (Text veya Görsel)
    // Medya varsa da Agent'a gönderiyoruz (Vision yeteneği)

    // if (mediaPaths == null || mediaPaths.isEmpty) { // ESKİ KONTROL KALDIRILDI
    log('🤖 Agent\'a yönlendiriliyor (REST): $message');

    try {
      final agentResponse = await _agentService.executeAgentTask(
        userMessage: message,
        geminiService: _geminiService,
        history: _chatHistory,
        model: _model,
        imagePaths: mediaPaths, // GÖRSEL DESTEĞİ EKLENDİ
        onStep: onAgentStep, // NEW: Step Callback Passed
      );

      // Agent sonucunu history'ye ekle
      _chatHistory.add(GeminiContent(role: 'user', parts: [
        GeminiTextPart(message)
      ])); // TODO: Görselleri de history'ye eklemek gerekebilir ama şimdilik sadece text
      _chatHistory.add(GeminiContent(
          role: 'model', parts: [GeminiTextPart(agentResponse.finalAnswer)]));

      return ChatTextResult(
        agentResponse.finalAnswer,
        agentSteps: agentResponse.steps,
        imageUrl: agentResponse.imageUrl,
        visualRequestId: agentResponse.visualRequestId,
      );
    } catch (e) {
      log('❌ Agent hatası: $e');
      return ChatTextResult(
        'Sorry, an error occurred during the process: $e',
      );
    }
  }
}
