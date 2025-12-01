part of "create_account_bloc.dart";

class CreateAccountState extends Equatable {
  const CreateAccountState({
    this.createAccountStatus = EventStatus.idle,
    this.authError,
    required this.auth,
    required this.googleSignIn,
  });

  final EventStatus createAccountStatus;
  final String? authError;
  final FirebaseAuth? auth;
  final GoogleSignIn? googleSignIn;

  CreateAccountState copyWith({
    EventStatus? createAccountStatus,
    String? authError,
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) {
    return CreateAccountState(
      createAccountStatus: createAccountStatus ?? this.createAccountStatus,
      authError: authError ?? this.authError,
      auth: auth,
      googleSignIn: googleSignIn,
    );
  }

  @override
  List<Object?> get props => [
        createAccountStatus,
        authError,
        auth,
        googleSignIn,
      ];
}
