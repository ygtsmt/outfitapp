import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@injectable
class UserPreferenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Kullanıcının stil tercihlerini getir (System Prompt olarak formatlanmış)
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
        log('ℹ️ Kullanıcı profili bulunamadı (İlk kullanım olabilir).');
        return '';
      }

      final data = doc.data()!;
      final buffer = StringBuffer();

      buffer.writeln('\n\n--- KULLANICI PROFİLİ VE TERCİHLERİ ---');
      buffer.writeln(
          'Aşağıdaki bilgiler, bu kullanıcı (Yigit) hakkında bilinen gerçeklerdir. Lütfen önerilerini buna göre kişiselleştir:');

      if (data.containsKey('favorite_colors') &&
          (data['favorite_colors'] as List).isNotEmpty) {
        buffer.writeln(
            '- Sevdiği Renkler: ${(data['favorite_colors'] as List).join(", ")}');
      }

      if (data.containsKey('disliked_colors') &&
          (data['disliked_colors'] as List).isNotEmpty) {
        buffer.writeln(
            '- ASLA Önerme (Sevmediği Renkler): ${(data['disliked_colors'] as List).join(", ")}');
      }

      if (data.containsKey('style_keywords') &&
          (data['style_keywords'] as List).isNotEmpty) {
        buffer.writeln(
            '- Giyim Tarzı: ${(data['style_keywords'] as List).join(", ")}');
      }

      if (data.containsKey('notes')) {
        buffer.writeln('- Özel Notlar: ${data['notes']}');
      }

      buffer.writeln('---------------------------------------');

      log('✅ Kullanıcı profili yüklendi: ${buffer.length} karakter');
      return buffer.toString();
    } catch (e) {
      log('❌ Profil yükleme hatası: $e');
      return ''; // Hata durumunda boş dön, akışı bozma
    }
  }

  /// Tercih güncelle (Admin veya UI kullanımı için)
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

  /// Aktif görevi kaydet (Marathon Agent için)
  Future<void> setActiveMission(Map<String, dynamic> missionData) async {
    if (_userId == null) return;

    log('🔥 ACTIVE MISSION KAYDEDİLİYOR: $missionData');

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('preferences')
          .doc('active_mission')
          .set({
        ...missionData,
        'mission_status': 'active', // Cloud Function için queryable field
      });

      log('✅ Mission başarıyla kaydedildi.');
    } catch (e) {
      log('❌ Mission kaydetme hatası: $e');
      rethrow;
    }
  }

  /// Aktif görevi getir
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
        log('✅ Aktif mission bulundu: ${doc.data()}');
        return doc.data();
      }
      return null;
    } catch (e) {
      log('❌ Active mission getirme hatası: $e');
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
      log('✅ FCM Token Firestore\'a kaydedildi.');
    } catch (e) {
      log('❌ FCM Token kaydetme hatası: $e');
    }
  }

  /// Aktif görevi geçmişe taşı ve sil
  Future<void> archiveActiveMission(Map<String, dynamic> missionData) async {
    if (_userId == null) return;

    log('📜 Mission Arşivleniyor: ${missionData['destination']}');

    try {
      final batch = _firestore.batch();

      // 1. History'ye ekle
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

      // 2. Active'den sil
      final activeRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('preferences')
          .doc('active_mission');

      batch.delete(activeRef);

      await batch.commit();
      log('✅ Mission başarıyla arşivlendi ve silindi.');
    } catch (e) {
      log('❌ Mission arşivleme hatası: $e');
      rethrow;
    }
  }
}
