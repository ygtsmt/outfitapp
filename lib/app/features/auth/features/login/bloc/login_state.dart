part of "login_bloc.dart";

class LoginState extends Equatable {
  const LoginState({
    this.status = EventStatus.idle,
    this.resetPasswordStatus = EventStatus.idle,
    this.authError,
    this.resetPasswordMessage,
    required this.auth,
    required this.googleSignIn,
  });

  /// Login işleminin durumu: idle, loading, success veya error
  final EventStatus status;
  final EventStatus resetPasswordStatus;

  /// Hata mesajı (Eğer bir hata oluşursa)
  final String? authError;
  final String? resetPasswordMessage;

  /// Başarılı bir oturum açıldığında kullanıcının bilgileri
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  LoginState copyWith({
    EventStatus? status,
    EventStatus? resetPasswordStatus,
    String? authError,
    String? resetPasswordMessage,
  }) {
    return LoginState(
        status: status ?? this.status,
        resetPasswordStatus: resetPasswordStatus ?? this.resetPasswordStatus,
        authError: authError ?? this.authError,
        resetPasswordMessage: resetPasswordMessage ?? this.resetPasswordMessage,
        auth: auth,
        googleSignIn: googleSignIn);
  }

  @override
  List<Object?> get props => [
        status,
        resetPasswordStatus,
        authError,
        resetPasswordMessage,
        auth,
        googleSignIn,
      ];
}
