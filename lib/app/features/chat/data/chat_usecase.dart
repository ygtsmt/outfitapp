import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';
import 'package:comby/core/constants/app_constants.dart';

@injectable
class ChatUseCase {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  ChatUseCase() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: geminiApiKey,
    );
    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      return response.text ?? 'Üzgünüm, bir cevap oluşturulamadı.';
    } catch (e) {
      throw Exception('Mesaj gönderilirken hata oluştu: $e');
    }
  }
}
