import 'package:ginly/generated/l10n.dart';

class ErrorMessageHandle {
  static String getFirebaseAuthErrorMessage(String? errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return AppLocalizations.current.invalid_email;

      case 'user-disabled':
        return AppLocalizations.current.user_disabled;

      case 'user-not-found':
        return AppLocalizations.current.user_not_found;

      case 'wrong-password':
        return AppLocalizations.current.wrong_password;

      case 'email-already-in-use':
        return AppLocalizations.current.email_already_in_use;

      case 'operation-not-allowed':
        return AppLocalizations.current.operation_not_allowed;

      case 'weak-password':
        return AppLocalizations.current.weak_password;

      case 'too-many-requests':
        return AppLocalizations.current.too_many_requests;

      case 'account-exists-with-different-credential':
        return AppLocalizations
            .current.account_exists_with_different_credential;

      case 'requires-recent-login':
        return AppLocalizations.current.requires_recent_login;

      case 'credential-already-in-use':
        return AppLocalizations.current.credential_already_in_use;

      case 'invalid-credential':
        return AppLocalizations.current.invalid_credential;

      case 'network-request-failed':
        return AppLocalizations.current.network_request_failed;

      case 'invalid-verification-code':
        return AppLocalizations.current.invalid_verification_code;

      case 'invalid-verification-id':
        return AppLocalizations.current.invalid_verification_id;

      case 'missing-verification-code':
        return AppLocalizations.current.missing_verification_code;

      case 'missing-verification-id':
        return AppLocalizations.current.missing_verification_id;

      default:
        return 'Unkown Error'; // Hata mesajı bulunamazsa
    }
  }
}
