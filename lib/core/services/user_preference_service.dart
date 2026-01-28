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
}
