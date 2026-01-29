import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:injectable/injectable.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

@injectable
class LoginUseCase {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  LoginUseCase({
    required this.auth,
    required this.googleSignIn,
  });

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // Kullanıcı oturumu iptal etti

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> loginWithApple() async {
    try {
      // Apple Sign-In işlemini başlat
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Firebase için OAuthProvider oluştur
      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final OAuthCredential oAuthCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Firebase ile giriş yap
      final UserCredential userCredential =
          await auth.signInWithCredential(oAuthCredential);
      return userCredential.user;
    } on SignInWithAppleAuthorizationException catch (e) {
      // Apple Sign-In iptal edildi veya hata oluştu
      if (e.code == AuthorizationErrorCode.canceled) {
        // Kullanıcı iptal etti, sessizce döndür
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> loginAsGuest() async {
    try {
      final UserCredential userCredential = await auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }
}

@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn(
        scopes: [calendar.CalendarApi.calendarEventsReadonlyScope],
      );
}
