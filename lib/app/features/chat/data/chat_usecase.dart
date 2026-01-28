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
      'gemini-3-flash-preview'; // REST API ile Gemini 3: gemini-3-flash-preview de kullanabiliriz

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
        return 'Kullanıcının gardırobu boş.';
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
KULLANICININ GARDIROBU (${items.length} parça):
${jsonEncode(itemsJson)}

ÖNEMLİ TALİMATLAR:
1. Kullanıcıya DOĞAL DİLDE cevap ver, JSON gösterme!
2. Kıyafetleri açıklarken sadece imageUrl'leri kullan, JSON formatında gösterme.
3. Örnek iyi cevap: "Gardırobunuzda 1 beyaz kazak var. imageUrl: https://..."
4. Örnek kötü cevap: [{"id":"123", "imageUrl":"https://..."...}]
''';
    } catch (e) {
      return 'Gardırop bilgisi alınamadı: $e';
    }
  }

  Future<ChatResult> sendMessage(String message,
      {List<String>? mediaPaths}) async {
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
        'Üzgünüm, işlem sırasında bir hata oluştu: $e',
      );
    }
    // } // ESKİ KONTROL BLOĞU SONU

    // Normal chat akışı
    String finalMessage;

    // User message content
    final userParts = <GeminiPart>[];

    // ✅ Media varsa gardırop context'ini GÖNDERME
    if (mediaPaths != null && mediaPaths.isNotEmpty) {
      finalMessage = message;

      // Media dosyalarını ekle
      for (final path in mediaPaths) {
        final file = File(path);
        if (!await file.exists()) continue;

        final bytes = await file.readAsBytes();
        final mimeType = _getMimeType(path);
        final base64Data = base64Encode(bytes);

        userParts.add(GeminiInlineDataPart(mimeType, base64Data));
      }
    } else {
      // Media yoksa normal gardırop akışı
      if (!_wardrobeSent) {
        final wardrobeContext = await _getWardrobeContext();
        finalMessage = '$wardrobeContext\n\nKullanıcı: $message';
        _wardrobeSent = true;
      } else {
        finalMessage = message;
      }
    }

    // Text'i ekle
    userParts.add(GeminiTextPart(finalMessage));

    // History'ye ekle
    final userContent = GeminiContent(role: 'user', parts: userParts);
    _chatHistory.add(userContent);

    // İsteği gönder
    try {
      final response = await _geminiService.generateContent(
        model: _model,
        request: GeminiRequest(
          contents: _chatHistory,
        ),
      );

      if (response.candidates != null && response.candidates!.isNotEmpty) {
        final content = response.candidates!.first.content;

        // Cevabı history'ye ekle
        _chatHistory.add(content);

        // Text part bul
        final textPart = content.parts.whereType<GeminiTextPart>().firstOrNull;
        final responseText = textPart?.text ?? 'Cevap metni bulunamadı.';

        // Function call (google_search) kontrolü? (Şimdilik yok)

        return ChatTextResult(responseText);
      } else {
        return ChatTextResult('Cevap alınamadı.');
      }
    } catch (e) {
      log('Chat error: $e');
      return ChatTextResult('Hata: $e');
    }
  }

  /// Outfit önerisi isteği mi kontrol et
  bool _isOutfitRequest(String message) {
    final keywords = [
      'ne giysem',
      'kombin öner',
      'outfit',
      'kıyafet öner',
      'yarın için',
      'bugün için',
      'ne giydim',
      'hava durumu',
      'hava nasıl',
      'what should i wear',
      'outfit suggestion',
    ];

    final lowerMessage = message.toLowerCase();
    return keywords.any((k) => lowerMessage.contains(k));
  }

  /// Dosya uzantısından MIME type belirle
  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'application/octet-stream';
    }
  }
}
