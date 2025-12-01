import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ginly/app/data/models/firebase_user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:ginly/app/core/services/first_install_bonus_service.dart';

@injectable
class CreateAccountUseCase {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;
  final FirstInstallBonusService bonusService;

  CreateAccountUseCase({
    required this.auth,
    required this.googleSignIn,
    required this.firestore,
    required this.bonusService,
  });

  Future<User?> createAccountWithEmail(String email, String password) async {
    try {
      final currentUser = auth.currentUser;

      // Eğer kullanıcı anonymous ise, hesabını email ile linkle
      if (currentUser != null && currentUser.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );

        final UserCredential userCredential =
            await currentUser.linkWithCredential(credential);

        // Display name güncelle
        await userCredential.user?.updateDisplayName('User');
        await userCredential.user?.reload();

        return userCredential.user;
      } else {
        // Normal hesap oluşturma
        final UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return userCredential.user;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> execute(
    User user,
    String displayname, {
    String? authProvider,
    bool isUpgradeFromAnonymous = false,
  }) async {
    final userDoc = firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    // Platform bilgisi al
    String platform;
    if (kIsWeb) {
      platform = 'web';
    } else if (Platform.isIOS) {
      platform = 'ios';
    } else if (Platform.isAndroid) {
      platform = 'android';
    } else {
      platform = 'unknown';
    }

    if (docSnapshot.exists) {
      // Eğer anonymous hesap upgrade ediliyor ise, sadece auth provider'ı güncelle
      if (isUpgradeFromAnonymous) {
        await userDoc.update({
          'profile_info.authProvider': authProvider,
          'profile_info.platform': platform,
          'profile_info.isAnonymous': false,
          'profile_info.email': user.email,
          'profile_info.emailVerified': user.emailVerified,
          'profile_info.displayName': displayname,
        });
        print('Anonymous hesap başarıyla upgrade edildi: ${user.email}');
      } else {
        print('Kullanıcı zaten kayıtlı, işlem yapılmadı.');
      }
      return;
    }

    // Yeni kullanıcı oluşturma
    final userMap = FirebaseUserModel.toMap(
      user,
      displayName: displayname,
      authProvider: authProvider,
      platform: platform, // iOS, Android, Web
    );

    // 🎯 Önce kullanıcıyı 0 kredi ile oluştur
    final profileInfo = {
      ...userMap,
      'totalCredit': 0, // Başlangıçta 0
      'isAnonymous': authProvider == 'anonymous',
      'hasReceivedFirstInstallBonus': false, // Henüz almadı
      'is_can_watch_ads': true, // Yeni kullanıcılar reklam izleyebilir
      'user_used_premium_template':
          false, // Premium template kullanma hakkı var
      'is_debug': kDebugMode, // Debug mode'da oluşturulan hesaplar işaretlensin
    };

    await userDoc.set({'profile_info': profileInfo}, SetOptions(merge: true));
    print('✅ New user created: ${user.email ?? user.uid}');

    // 🎁 First Install Bonus ver (cihaz bazlı kontrol)
    final bonusAmount = await bonusService.applyFirstInstallBonus(
      user.uid,
      authProvider ?? 'unknown',
    );

    if (bonusAmount > 0) {
      print('🎉 First install bonus applied: $bonusAmount credits');
    } else {
      print('ℹ️ No bonus applied (device already used or error)');
    }
  }

  Future<User?> createAccountWithGoogle() async {
    try {
      final currentUser = auth.currentUser;

      if (currentUser != null && currentUser.isAnonymous) {
        // Guest hesabını Google ile yükselt
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null; // User cancelled

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await currentUser.linkWithCredential(credential);
        return userCredential.user;
      } else {
        // Normal Google hesap oluşturma
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null; // User cancelled

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> createAccountWithApple() async {
    try {
      final currentUser = auth.currentUser;

      if (currentUser != null && currentUser.isAnonymous) {
        // Guest hesabını Apple ile yükselt
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
        final OAuthCredential oAuthCredential = oAuthProvider.credential(
          idToken: credential.identityToken,
          accessToken: credential.authorizationCode,
        );

        final UserCredential userCredential =
            await currentUser.linkWithCredential(oAuthCredential);
        return userCredential.user;
      } else {
        // Normal Apple hesap oluşturma
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
        final OAuthCredential oAuthCredential = oAuthProvider.credential(
          idToken: credential.identityToken,
          accessToken: credential.authorizationCode,
        );

        final UserCredential userCredential =
            await auth.signInWithCredential(oAuthCredential);
        return userCredential.user;
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return null; // User cancelled
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
