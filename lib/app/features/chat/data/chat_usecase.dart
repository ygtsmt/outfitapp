import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import 'package:comby/core/constants/app_constants.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'dart:convert';

sealed class ChatResult {}

class ChatTextResult extends ChatResult {
  final String text;
  ChatTextResult(this.text);
}

class ChatSearchResult extends ChatResult {
  final String query;
  ChatSearchResult(this.query);
}

@injectable
class ChatUseCase {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final ClosetUseCase _closetUseCase;

  bool _wardrobeSent = false; // Gardırop gönderildi mi?

  ChatUseCase(this._closetUseCase) {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: geminiApiKey,
    );
    _chatSession = _model.startChat();
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
    String finalMessage;

    // ✅ Media varsa gardırop context'ini GÖNDERME
    if (mediaPaths != null && mediaPaths.isNotEmpty) {
      // Kullanıcı fotoğraf/video gönderiyorsa, kullanıcının yazdığı mesajı kullan
      finalMessage = message;
    } else {
      // Media yoksa normal gardırop akışı
      if (!_wardrobeSent) {
        final wardrobeContext = await _getWardrobeContext();
        finalMessage = '$wardrobeContext\n\nKullanıcı: $message';
        _wardrobeSent = true;
      } else {
        // Sonraki mesajlarda sadece kullanıcı mesajını gönder
        // Gemini zaten gardırobu ve önceki konuşmayı hatırlıyor
        finalMessage = message;
      }
    }

    // ✅ Media varsa multi-part content oluştur
    if (mediaPaths != null && mediaPaths.isNotEmpty) {
      final parts = <Part>[];

      // Text ekle
      parts.add(TextPart(finalMessage));

      // Her media dosyasını ekle
      for (final path in mediaPaths) {
        final file = File(path);
        if (!await file.exists()) continue;

        final bytes = await file.readAsBytes();
        final mimeType = _getMimeType(path);

        parts.add(DataPart(mimeType, bytes));
      }

      final response = await _chatSession.sendMessage(
        Content.multi(parts),
      );

      final candidate = response.candidates.first;
      final responseParts = candidate.content.parts;

      for (final part in responseParts) {
        if (part is FunctionCall) {
          if (part.name == 'google_search') {
            final query = part.args['query'] ?? part.args['action_input'] ?? '';
            return ChatSearchResult(query.toString());
          }
        }
      }

      return ChatTextResult(
        response.text ?? 'Cevap oluşturulamadı.',
      );
    }

    // ✅ Media yoksa normal text-only mesaj gönder
    final response = await _chatSession.sendMessage(
      Content.text(finalMessage),
    );

    final candidate = response.candidates.first;
    final parts = candidate.content.parts;

    for (final part in parts) {
      if (part is FunctionCall) {
        if (part.name == 'google_search') {
          final query = part.args['query'] ?? part.args['action_input'] ?? '';
          return ChatSearchResult(query.toString());
        }
      }
    }

    return ChatTextResult(
      response.text ?? 'Cevap oluşturulamadı.',
    );
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
