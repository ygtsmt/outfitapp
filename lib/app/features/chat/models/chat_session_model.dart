import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comby/app/features/chat/bloc/chat_bloc.dart';
import 'package:equatable/equatable.dart';

class ChatSession extends Equatable {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime lastMessageTime;
  final String title;
  final List<ChatMessage> messages;

  const ChatSession({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.lastMessageTime,
    required this.title,
    required this.messages,
  });

  ChatSession copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? lastMessageTime,
    String? title,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      title: title ?? this.title,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'title': title,
      'messages': messages.map((x) => x.toMap()).toList(),
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'] as String,
      userId: map['userId'] as String,
      startTime: (map['startTime'] as Timestamp).toDate(),
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      title: map['title'] as String,
      messages: List<ChatMessage>.from(
        (map['messages'] as List<dynamic>).map<ChatMessage>(
          (x) => ChatMessage.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, startTime, lastMessageTime, title, messages];
}
