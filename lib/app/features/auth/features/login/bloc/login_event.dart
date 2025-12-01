part of "login_bloc.dart";

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginAccountEvent extends LoginEvent {
  const LoginAccountEvent();

  @override
  List<Object> get props => [];
}

class LoginWithEmailEvent extends LoginEvent {
  final String email;
  final String password;

  const LoginWithEmailEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LoginWithGoogleEvent extends LoginEvent {
  const LoginWithGoogleEvent();

  @override
  List<Object> get props => [];
}

class LoginWithAppleEvent extends LoginEvent {
  const LoginWithAppleEvent();

  @override
  List<Object> get props => [];
}

class ResetPasswordEvent extends LoginEvent {
  final String email;

  const ResetPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class LoginAsGuestEvent extends LoginEvent {
  const LoginAsGuestEvent();

  @override
  List<Object> get props => [];
}
