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

class LoadSessionEvent extends ChatEvent {
  final ChatSession session;
  const LoadSessionEvent(this.session);
  @override
  List<Object> get props => [session];
}

class NewSessionEvent extends ChatEvent {
  const NewSessionEvent();
}

class AgentStepUpdated extends ChatEvent {
  final String stepDescription;
  const AgentStepUpdated(this.stepDescription);

  @override
  List<Object> get props => [stepDescription];
}
