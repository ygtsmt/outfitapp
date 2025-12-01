part of "create_account_bloc.dart";

abstract class _CreateAccountEvent extends Equatable {
  const _CreateAccountEvent();

  @override
  List<Object?> get props => [];
}

class CreateAccountEvent extends _CreateAccountEvent {
  final String email;
  final String password;
  final String displayName;

  const CreateAccountEvent({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object> get props => [
        email,
        password,
        displayName,
      ];
}

class CreateAccountWithGoogleEvent extends _CreateAccountEvent {
  const CreateAccountWithGoogleEvent();
}

class CreateAccountWithAppleEvent extends _CreateAccountEvent {
  const CreateAccountWithAppleEvent();
}
