part of 'chat_bloc.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final List<String>? imageUrls; // ✅ Görsel URL'leri (AI'dan gelen)
  final List<String>?
      localMediaPaths; // ✅ Kullanıcının gönderdiği medya dosyaları

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.imageUrls,
    this.localMediaPaths,
  });

  @override
  List<Object?> get props => [text, isUser, imageUrls, localMediaPaths];
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? errorMessage;
  final List<String>
      selectedMedia; // ✅ Seçili medya dosyaları (henüz gönderilmedi)

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.selectedMedia = const [],
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? errorMessage,
    List<String>? selectedMedia,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMedia: selectedMedia ?? this.selectedMedia,
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage, selectedMedia];
}
