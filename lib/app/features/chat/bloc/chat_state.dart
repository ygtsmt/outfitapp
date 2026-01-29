part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final List<String>? imageUrls; // ✅ Görsel URL'leri (AI'dan gelen)
  final List<String>?
      localMediaPaths; // ✅ Kullanıcının gönderdiği medya dosyaları
  final List<AgentStep>? agentSteps; // 🤖 Agent adımları
  final String? visualRequestId; // ⏳ Bekleyen görsel isteği

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.imageUrls,
    this.localMediaPaths,
    this.agentSteps,
    this.visualRequestId,
  });

  @override
  List<Object?> get props =>
      [text, isUser, imageUrls, localMediaPaths, agentSteps, visualRequestId];
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? errorMessage;
  final List<String>
      selectedMedia; // ✅ Seçili medya dosyaları (henüz gönderilmedi)
  final String? agentThinkingText; // 🤖 Agent'ın o an ne düşündüğü

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.selectedMedia = const [],
    this.agentThinkingText,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? errorMessage,
    List<String>? selectedMedia,
    String? agentThinkingText,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMedia: selectedMedia ?? this.selectedMedia,
      agentThinkingText: agentThinkingText ?? this.agentThinkingText,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        errorMessage,
        selectedMedia,
        agentThinkingText,
      ];
}
