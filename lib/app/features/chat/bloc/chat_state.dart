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
  final bool requestsLocation; // 📍 Konum izni talebi
    final String? activeSessionId;


  const ChatMessage({
    required this.text,
    required this.isUser,
    this.imageUrls,
    this.localMediaPaths,
    this.agentSteps,
    this.visualRequestId,
    this.requestsLocation = false,
    this.activeSessionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isUser': isUser,
      'imageUrls': imageUrls,
      'localMediaPaths': localMediaPaths,
      'agentSteps': agentSteps?.map((x) => x.toMap()).toList(),
      'visualRequestId': visualRequestId,
      'requestsLocation': requestsLocation,
      'activeSessionId': activeSessionId,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] as String,
      isUser: map['isUser'] as bool,
      imageUrls: (map['imageUrls'] as List<dynamic>?)?.cast<String>(),
      localMediaPaths:
          (map['localMediaPaths'] as List<dynamic>?)?.cast<String>(),
      agentSteps: map['agentSteps'] != null
          ? List<AgentStep>.from(
              (map['agentSteps'] as List<dynamic>).map<AgentStep?>(
                (x) => AgentStep.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      visualRequestId: map['visualRequestId'] as String?,
      requestsLocation: map['requestsLocation'] as bool? ?? false,
      activeSessionId: map['activeSessionId'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        text,
        isUser,
        imageUrls,
        localMediaPaths,
        agentSteps,
        visualRequestId,
        requestsLocation,
        activeSessionId,
      ];
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? errorMessage;
  final List<String>
      selectedMedia; // ✅ Seçili medya dosyaları (henüz gönderilmedi)
  final String? agentThinkingText; // 🤖 Agent'ın o an ne düşündüğü
  final String? activeSessionId;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.selectedMedia = const [],
    this.agentThinkingText,
    this.activeSessionId,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? errorMessage,
    List<String>? selectedMedia,
    String? agentThinkingText,
    String? activeSessionId,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMedia: selectedMedia ?? this.selectedMedia,
      agentThinkingText: agentThinkingText ?? this.agentThinkingText,
      activeSessionId: activeSessionId ?? this.activeSessionId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        errorMessage,
        selectedMedia,
        agentThinkingText,
        activeSessionId,
      ];
}
