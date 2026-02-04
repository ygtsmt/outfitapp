import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:comby/app/features/chat/models/chat_session_model.dart';
import 'package:uuid/uuid.dart';

@injectable
class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ChatRepository({
    required this.firestore,
    required this.auth,
  });

  /// Saves or updates a chat session in Firestore
  Future<void> saveSession(ChatSession session) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .doc(session.id)
          .set(session.toMap());

      log('Chat session saved: ${session.id}');
    } catch (e) {
      log('Error saving chat session: $e');
    }
  }

  /// Fetches all chat sessions for the current user, ordered by lastMessageTime desc
  Future<List<ChatSession>> getSessions() async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) {
            try {
              return ChatSession.fromMap(doc.data());
            } catch (e) {
              log('Error parsing chat session: $e');
              return null;
            }
          })
          .whereType<ChatSession>()
          .toList();
    } catch (e) {
      log('Error fetching chat sessions: $e');
      return [];
    }
  }

  /// Deletes a chat session
  Future<void> deleteSession(String sessionId) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return;

      await firestore
          .collection('users')
          .doc(userId)
          .collection('chat_sessions')
          .doc(sessionId)
          .delete();

      log('Chat session deleted: $sessionId');
    } catch (e) {
      log('Error deleting chat session: $e');
    }
  }

  /// Creates a new session ID
  String createSessionId() {
    return const Uuid().v4();
  }
}
