import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@injectable
class UserPreferenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Get user style preferences (formatted as System Prompt)
  Future<String> getSystemPromptProfile() async {
    try {
      if (_userId == null) return '';

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('preferences')
          .doc('style_profile')
          .get();

      if (!doc.exists || doc.data() == null) {
        log('ℹ️ User profile not found (might be first use).');
        return '';
      }

      final data = doc.data()!;
      final buffer = StringBuffer();

      buffer.writeln('\n\n--- USER PROFILE AND PREFERENCES ---');
      buffer.writeln(
          'The following facts are known about this user (Yigit). Please personalize your suggestions based on these:');

      if (data.containsKey('favorite_colors') &&
          (data['favorite_colors'] as List).isNotEmpty) {
        buffer.writeln(
            '- Favorite Colors: ${(data['favorite_colors'] as List).join(", ")}');
      }

      if (data.containsKey('disliked_colors') &&
          (data['disliked_colors'] as List).isNotEmpty) {
        buffer.writeln(
            '- Color Preferences: User typically avoids ${(data['disliked_colors'] as List).join(", ")}');
      }

      if (data.containsKey('style_keywords') &&
          (data['style_keywords'] as List).isNotEmpty) {
        buffer.writeln(
            '- Clothing Style: ${(data['style_keywords'] as List).join(", ")}');
      }

      if (data.containsKey('notes')) {
        buffer.writeln('- Special Notes: ${data['notes']}');
      }

      buffer.writeln('---------------------------------------');

      log('✅ User profile loaded: ${buffer.length} characters');
      return buffer.toString();
    } catch (e) {
      log('❌ Profile loading error: $e');
      return ''; // Return empty on error, don't break flow
    }
  }

  /// Update preferences (for Admin or UI use)
  Future<void> updateStyleProfile({
    List<String>? favoriteColors,
    List<String>? dislikedColors,
    List<String>? styleKeywords,
    String? notes,
  }) async {
    if (_userId == null) return;

    final Map<String, dynamic> updates = {};

    // Listeler için arrayUnion kullan, overwrite etme
    if (favoriteColors != null) {
      updates['favorite_colors'] = FieldValue.arrayUnion(favoriteColors);
    }
    if (dislikedColors != null) {
      updates['disliked_colors'] = FieldValue.arrayUnion(dislikedColors);
    }
    if (styleKeywords != null) {
      updates['style_keywords'] = FieldValue.arrayUnion(styleKeywords);
    }
    // String notlar overwrite edilebilir veya birleştirilebilir (şimdilik overwrite)
    if (notes != null) updates['notes'] = notes;

    log('🔥 FIRESTORE YAZMA BAŞLIYOR: userId=$_userId updates=$updates');

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('preferences')
          .doc('style_profile')
          .set(updates, SetOptions(merge: true));

      log('✅ Kullanıcı profili güncellendi (Merged)');
    } catch (e) {
      log('❌ FIRESTORE HATASI: $e');
      rethrow;
    }
  }

  /// Save active mission (for Marathon Agent)
  Future<void> setActiveMission(Map<String, dynamic> missionData) async {
    if (_userId == null) return;

    log('🔥 SAVING ACTIVE MISSION: $missionData');

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('preferences')
          .doc('active_mission')
          .set({
        ...missionData,
        'mission_status': 'active', // Queryable field for Cloud Function
      });

      log('✅ Mission successfully saved.');
    } catch (e) {
      log('❌ Mission saving error: $e');
      rethrow;
    }
  }

  /// Get active mission
  Future<Map<String, dynamic>?> getActiveMission() async {
    if (_userId == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('preferences')
          .doc('active_mission')
          .get();

      if (doc.exists) {
        log('✅ Active mission found: ${doc.data()}');
        return doc.data();
      }
      return null;
    } catch (e) {
      log('❌ Active mission fetch error: $e');
      return null;
    }
  }

  /// FCM Token kaydet
  Future<void> saveFCMToken(String token) async {
    if (_userId == null) return;
    try {
      await _firestore.collection('users').doc(_userId).set({
        'fcm_token': token,
        'last_token_update': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      log('✅ FCM Token saved to Firestore.');
    } catch (e) {
      log('❌ Error saving FCM Token: $e');
    }
  }

  /// Move active mission to history and delete
  Future<void> archiveActiveMission(Map<String, dynamic> missionData) async {
    if (_userId == null) return;

    log('📜 Archiving Mission: ${missionData['destination']}');

    try {
      final batch = _firestore.batch();

      // 1. Add to History
      final historyRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('mission_history')
          .doc(); // Auto-ID

      batch.set(historyRef, {
        ...missionData,
        'archived_at': DateTime.now().toIso8601String(),
        'status': 'completed',
      });

      // 2. Delete from Active
      final activeRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('preferences')
          .doc('active_mission');

      batch.delete(activeRef);

      await batch.commit();
      log('✅ Mission successfully archived and deleted.');
    } catch (e) {
      log('❌ Mission archiving error: $e');
      rethrow;
    }
  }
}
