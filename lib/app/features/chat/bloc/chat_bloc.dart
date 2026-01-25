import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:comby/app/features/chat/data/chat_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCase _chatUseCase;

  ChatBloc(this._chatUseCase) : super(const ChatState()) {
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final userMessage = ChatMessage(text: event.message, isUser: true);
    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(userMessage);

    emit(state.copyWith(
      status: ChatStatus.loading,
      messages: updatedMessages,
    ));

    try {
      final responseText = await _chatUseCase.sendMessage(event.message);
      final aiMessage = ChatMessage(text: responseText, isUser: false);

      final finalMessages = List<ChatMessage>.from(updatedMessages)
        ..add(aiMessage);

      emit(state.copyWith(
        status: ChatStatus.success,
        messages: finalMessages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
