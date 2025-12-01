import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

/// Basit ve güvenli First Install Bonus servisi
/// - Sadece cihaz bazlı kontrol
/// - Firebase'den kredi miktarını oku
/// - Her cihaz sadece 1 kere bonus alabilir
@injectable
class FirstInstallBonusService {
  final FirebaseFirestore _firestore;
  static const _storage = FlutterSecureStorage();
  static const _deviceIdKey = 'unique_device_fingerprint';

  FirstInstallBonusService(this._firestore);

  /// Benzersiz cihaz ID'si al veya oluştur
  Future<String> _getDeviceId() async {
    try {
      // 1. Storage'da var mı kontrol et
      final storedId = await _storage.read(key: _deviceIdKey);
      if (storedId != null && storedId.isNotEmpty) {
        return storedId;
      }

      // 2. Yeni oluştur
      final deviceInfo = DeviceInfoPlugin();
      String deviceFingerprint;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final androidId = androidInfo.id ?? 'unknown';
        final model = androidInfo.model ?? 'unknown';
        final brand = androidInfo.brand ?? 'unknown';
        // UUID kaldırıldı - sadece cihaz bilgisi kullan (her seferinde aynı olacak)
        deviceFingerprint = 'android_${androidId}_${brand}_$model';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final idfv = iosInfo.identifierForVendor ?? 'unknown';
        final model = iosInfo.model ?? 'unknown';
        // UUID kaldırıldı - sadece IDFV kullan (her seferinde aynı olacak)
        deviceFingerprint = 'ios_${idfv}_$model';
      } else {
        final uniqueId = const Uuid().v4();
        deviceFingerprint = 'unknown_$uniqueId';
      }

      // 3. Storage'a kaydet
      await _storage.write(key: _deviceIdKey, value: deviceFingerprint);
      debugPrint('✅ New device fingerprint created: $deviceFingerprint');
      return deviceFingerprint;
    } catch (e) {
      debugPrint('❌ Error getting device ID: $e');
      final fallbackId =
          'fallback_${const Uuid().v4()}_${DateTime.now().millisecondsSinceEpoch}';
      try {
        await _storage.write(key: _deviceIdKey, value: fallbackId);
      } catch (_) {}
      return fallbackId;
    }
  }

  /// Bu cihaz daha önce first install bonus aldı mı?
  Future<bool> hasDeviceReceivedBonus() async {
    try {
      final deviceId = await _getDeviceId();
      final deviceDoc = await _firestore
          .collection('device_first_install_bonus')
          .doc(deviceId)
          .get();

      final hasReceived =
          deviceDoc.exists && deviceDoc.data()?['claimed'] == true;
      debugPrint(
          '📱 Device bonus check - deviceId: $deviceId, hasReceived: $hasReceived');
      return hasReceived;
    } catch (e) {
      debugPrint('❌ Error checking device bonus: $e');
      return true; // Güvenli taraf: hata varsa bonus verme
    }
  }

  /// First install bonus ver - Cloud Functions üzerinden
  /// Returns: Verilen kredi miktarı (0 = bonus verilemedi)
  Future<int> applyFirstInstallBonus(String userId, String authProvider) async {
    try {
      debugPrint('🎁 Requesting first install bonus via Cloud Function...');

      // Device ID al
      final deviceId = await _getDeviceId();

      // Cloud Function çağır
      final callable =
          FirebaseFunctions.instance.httpsCallable('claimFirstInstallBonus');

      final result = await callable.call({
        'deviceId': deviceId,
        'authProvider': authProvider,
      });

      // Sonucu parse et
      final success = result.data['success'] as bool;
      final creditAmount = result.data['creditAmount'] as int;
      final message = result.data['message'] as String;

      if (success) {
        debugPrint(
            '🎉 First install bonus applied! Amount: $creditAmount credits');
        debugPrint('📝 Message: $message');
        return creditAmount;
      } else {
        debugPrint('❌ First install bonus failed');
        return 0;
      }
    } on FirebaseFunctionsException catch (e) {
      debugPrint('❌ FirebaseFunctionsException: ${e.code} - ${e.message}');

      // Hata kodlarına göre özel handling
      switch (e.code) {
        case 'already-exists':
          debugPrint('ℹ️ Bonus already claimed (user or device)');
          break;
        case 'unauthenticated':
          debugPrint('ℹ️ User not authenticated');
          break;
        case 'invalid-argument':
          debugPrint('ℹ️ Invalid device ID');
          break;
        default:
          debugPrint('ℹ️ Unknown error: ${e.code}');
      }

      return 0;
    } catch (e) {
      debugPrint('❌ Error applying first install bonus: $e');
      return 0;
    }
  }

  /// Debug/Test için bonus sıfırlama (sadece debug modda)
  Future<void> resetBonusForTesting(String userId) async {
    if (!kDebugMode) return;

    try {
      final deviceId = await _getDeviceId();

      // Kullanıcı bonus durumunu sıfırla
      await _firestore.collection('users').doc(userId).update({
        'profile_info.hasReceivedFirstInstallBonus': false,
      });

      // Cihaz bonus durumunu sıfırla
      await _firestore
          .collection('device_first_install_bonus')
          .doc(deviceId)
          .delete();

      debugPrint(
          '🔄 First install bonus reset for testing - User: $userId, Device: $deviceId');
    } catch (e) {
      debugPrint('❌ Error resetting bonus: $e');
    }
  }
}
