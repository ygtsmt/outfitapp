import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:comby/app/features/chat/data/chat_usecase.dart';
import 'package:comby/app/features/chat/utils/parse_image_urls.dart';

part 'chat_event.dart';
part 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCase _chatUseCase;

  ChatBloc(this._chatUseCase) : super(const ChatState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<SelectMediaEvent>(_onSelectMedia);
    on<ClearMediaEvent>(_onClearMedia);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // ✅ Media'yı temizlemeden önce kaydet
    final mediaToSend =
        state.selectedMedia.isNotEmpty ? state.selectedMedia : null;

    // ✅ Kullanıcı mesajını oluştur (media varsa ekle)
    final userMessage = ChatMessage(
      text: event.message,
      isUser: true,
      localMediaPaths: mediaToSend,
    );
    final messages = List<ChatMessage>.from(state.messages)..add(userMessage);

    emit(state.copyWith(
      status: ChatStatus.loading,
      messages: messages,
      selectedMedia: [], // ✅ Gönderildikten sonra temizle
    ));

    try {
      // ✅ Kaydedilmiş media'yı gönder (state'ten değil!)
      final result = await _chatUseCase.sendMessage(
        event.message,
        mediaPaths: mediaToSend,
      );

      /// 🔥 TOOL İSTEDİ
      if (result is ChatSearchResult) {
        final searchInfo = '🔍 "${result.query}" için bilgi aranıyor...';

        final searchingBubble = ChatMessage(text: searchInfo, isUser: false);

        emit(state.copyWith(
          messages: [...messages, searchingBubble],
        ));

        /// ⚠️ burada NORMALDE API çağırırsın
        /// örnek dummy data
        final weatherData = 'Ankara bugün 11°C, parçalı bulutlu, rüzgar hafif.';

        final finalAiResult = await _chatUseCase.sendMessage(
          'Bu hava durumu verisini kullanıcıya doğal dilde anlat: $weatherData',
        );

        emit(state.copyWith(
          status: ChatStatus.success,
          messages: [
            ...messages,
            searchingBubble,
            ChatMessage(
              text: (finalAiResult as ChatTextResult).text,
              isUser: false,
            ),
          ],
        ));
        return;
      }

      /// NORMAL TEXT
      final responseText = (result as ChatTextResult).text;

      // ✅ URL'leri çıkar ve metni temizle
      final parsed = parseImageUrls(responseText);

      emit(state.copyWith(
        status: ChatStatus.success,
        messages: [
          ...messages,
          ChatMessage(
            text: parsed
                .cleanedText, // ✅ Temizlenmiş metin (imageUrl: ... olmadan)
            isUser: false,
            imageUrls: parsed.imageUrls.isNotEmpty
                ? parsed.imageUrls
                : null, // ✅ Çıkarılan URL'ler
          ),
        ],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelectMedia(
    SelectMediaEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(selectedMedia: event.mediaPaths));
  }

  void _onClearMedia(
    ClearMediaEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(selectedMedia: []));
  }
}
