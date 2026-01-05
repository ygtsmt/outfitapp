import 'package:firebase_auth/firebase_auth.dart';
import 'package:comby/app/features/auth/features/profile/data/models/user_model.dart';

class EmailVerificationService {
  /// Kullanıcının email doğrulaması gerekli mi kontrol et
  static bool isEmailVerificationRequired(UserProfile profile) {
    // Google veya Apple ile giriş yapıldıysa email doğrulama gerekmez
    if (profile.authProvider == 'google' || profile.authProvider == 'apple') {
      return false;
    }

    // Email doğrulanmamışsa ve totalAdsWatched >= 3 ise doğrulama gerekli
    if (profile.emailVerified != true && (profile.totalAdsWatched ?? 0) >= 3) {
      return true;
    }

    return false;
  }

  /// Email doğrulama durumunu kontrol et
  static Future<bool> checkEmailVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Email doğrulama durumunu yenile
        await user.reload();
        return user.emailVerified;
      }
      return false;
    } catch (e) {
      print('Email verification check error: $e');
      return false;
    }
  }

  /// Email doğrulama email'i gönder
  static Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Send email verification error: $e');
      rethrow;
    }
  }
}
