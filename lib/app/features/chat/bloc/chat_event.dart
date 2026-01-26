part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}

class SelectMediaEvent extends ChatEvent {
  final List<String> mediaPaths;

  const SelectMediaEvent(this.mediaPaths);

  @override
  List<Object> get props => [mediaPaths];
}

class ClearMediaEvent extends ChatEvent {
  const ClearMediaEvent();
}
