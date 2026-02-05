import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:comby/app/features/chat/data/chat_usecase.dart';
import 'package:comby/app/features/chat/utils/parse_image_urls.dart';
import 'package:comby/app/features/chat/models/agent_models.dart';
import 'package:comby/generated/l10n.dart';
import 'package:comby/app/features/chat/data/chat_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comby/app/features/chat/models/chat_session_model.dart';

part 'chat_event.dart';
part 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCase _chatUseCase;
  final ChatRepository _chatRepository;
  final FirebaseAuth _auth;

  String? _currentSessionId;

  ChatBloc(this._chatUseCase, this._chatRepository, this._auth)
      : super(const ChatState()) {
    on<SendMessageEvent>(_onSendMessage);
    on<SelectMediaEvent>(_onSelectMedia);
    on<ClearMediaEvent>(_onClearMedia);
    on<AgentStepUpdated>(_onAgentStepUpdated);
    on<NewSessionEvent>(_onNewSession);
    on<LoadSessionEvent>(_onLoadSession);
  }

  void _onNewSession(NewSessionEvent event, Emitter<ChatState> emit) {
    _currentSessionId = null;
    // Clear chat history in UseCase if possible, or just reset state
    // But ChatUseCase keeps internal history, so we might need a method to clear it.
    // For now, we just reset the UI state.
    emit(const ChatState());
  }

  void _onLoadSession(LoadSessionEvent event, Emitter<ChatState> emit) {
    _currentSessionId = event.session.id;
    emit(state.copyWith(
      status: ChatStatus.success,
      messages: event.session.messages,
    ));
    // Ideally we should also restore the history in ChatUseCase if we want to continue the context.
    // That would require updating ChatUseCase to accept history injection or setting it.
  }

  void _onAgentStepUpdated(
    AgentStepUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(agentThinkingText: event.stepDescription));
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Generate session ID if not exists
    if (_currentSessionId == null) {
      _currentSessionId = _chatRepository.createSessionId();
    }

    // Media'yı temizlemeden önce kaydet
    final mediaToSend =
        state.selectedMedia.isNotEmpty ? state.selectedMedia : null;

    // Kullanıcı mesajını oluştur (media varsa ekle)
    final userMessage = ChatMessage(
      text: event.message,
      isUser: true,
      localMediaPaths: mediaToSend,
    );
    final messages = List<ChatMessage>.from(state.messages)..add(userMessage);

    emit(state.copyWith(
      status: ChatStatus.loading,
      messages: messages,
      selectedMedia: [],
      agentThinkingText: 'Thinking...',
    ));

    try {
      // Kaydedilmiş media'yı gönder (state'ten değil!)
      final result = await _chatUseCase.sendMessage(
        event.message,
        mediaPaths: mediaToSend,
        onAgentStep: (step) => add(AgentStepUpdated(step)),
        useDeepThink: event.useDeepThink, // Pass Deep Think mode
      );

      /// 🔥 TOOL İSTEDİ
      if (result is ChatSearchResult) {
        final searchInfo =
            AppLocalizations.current.searchingForInfo(result.query);

        final searchingBubble = ChatMessage(text: searchInfo, isUser: false);
        final finalMessages = [...messages, searchingBubble];

        emit(state.copyWith(
          messages: finalMessages,
          agentThinkingText: null, // Bitti
        ));

        _saveSession(finalMessages);

        /// ⚠️ You would normally call an API here
        /// example dummy data
        final wardrobeData = '✅ Wardrobe: 5 items found';

        final finalAiResult = await _chatUseCase.sendMessage(
          'Explain this wardrobe data to the user in natural language: $wardrobeData',
        );

        final aiMessage = ChatMessage(
          text: (finalAiResult as ChatTextResult).text,
          isUser: false,
        );
        final updatedMessages = [
          ...messages,
          searchingBubble,
          aiMessage,
        ];

        emit(state.copyWith(
          status: ChatStatus.success,
          messages: updatedMessages,
        ));
        _saveSession(updatedMessages);

        return;
      } else if (result is ChatTextResult) {
        final aiMessage = ChatMessage(
          text: result.text,
          isUser: false,
          visualRequestId: result.visualRequestId,
          imageUrls: result.imageUrl != null ? [result.imageUrl!] : null,
          agentSteps: result.agentSteps,
          requestsLocation: result.requestsLocation,
        );
        final updatedMessages = [...messages, aiMessage];

        emit(state.copyWith(
          status: ChatStatus.success,
          messages: updatedMessages,
          agentThinkingText: null, // Finished
        ));
        _saveSession(updatedMessages);
      }
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: e.toString(),
        agentThinkingText: null, // Clear in case of error
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

  Future<void> _saveSession(List<ChatMessage> messages) async {
    if (_currentSessionId == null || _auth.currentUser == null) return;

    final title =
        messages.firstWhere((m) => m.isUser).text; // Simple title strategy

    final session = ChatSession(
      id: _currentSessionId!,
      userId: _auth.currentUser!.uid,
      startTime: DateTime.now(), // ideally preserve original start time
      lastMessageTime: DateTime.now(),
      title: title.length > 30 ? '${title.substring(0, 30)}...' : title,
      messages: messages,
    );

    await _chatRepository.saveSession(session);
  }
}
