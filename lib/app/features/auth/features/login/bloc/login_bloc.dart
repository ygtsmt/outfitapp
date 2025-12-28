import "package:ginfit/app/features/auth/features/create_account/data/create_account_usecase.dart";
import "package:ginfit/app/features/auth/features/login/data/login_usecase.dart";
import "package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart";
import "package:ginfit/core/enums.dart";
import "package:ginfit/core/core.dart";

import "package:equatable/equatable.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:injectable/injectable.dart";

part "login_event.dart";
part "login_state.dart";

@singleton
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  final CreateAccountUseCase createAccountUseCase;

  LoginBloc({
    required this.loginUseCase,
    required this.createAccountUseCase,
  }) : super(LoginState(
            auth: FirebaseAuth.instance, googleSignIn: GoogleSignIn())) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LoginWithAppleEvent>(_onLoginWithApple);
    on<LoginAsGuestEvent>(_onLoginAsGuest);
    on<ResetPasswordEvent>(resetPassword);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<LoginState> emit,
  ) async {

    emit(state.copyWith(status: EventStatus.processing));

    try {
      final user =
          await loginUseCase.loginWithEmail(event.email, event.password);
      if (user != null) {
        emit(state.copyWith(status: EventStatus.success));

        // Login başarılı

        try {
          getIt<ProfileBloc>().add(FetchProfileInfoEvent(user.uid));
        } catch (e) {
          print('Profile fetch error: $e');
        }
      } else {
        emit(state.copyWith(status: EventStatus.failure));
      }
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        authError: e.code,
      ));
    }
    emit(state.copyWith(status: EventStatus.idle));
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: EventStatus.processing));

    try {
      final user = await loginUseCase.loginWithGoogle();
      if (user != null) {
        emit(state.copyWith(status: EventStatus.success));
        await createAccountUseCase.execute(
          user,
          'DISPLAYNAME',
          authProvider: 'google',
        );

        // Login başarılı

        // Login başarılı olduktan sonra profil bilgilerini yükle
        try {
          getIt<ProfileBloc>().add(FetchProfileInfoEvent(user.uid));
        } catch (e) {
          print('Profile fetch error: $e');
        }
      } else {
        emit(state.copyWith(status: EventStatus.failure));
      }
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        authError: e.code,
      ));
    }
    emit(state.copyWith(status: EventStatus.idle));
  }

  Future<void> _onLoginWithApple(
    LoginWithAppleEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: EventStatus.processing));

    try {
      final user = await loginUseCase.loginWithApple();
      print(user);
      if (user != null) {
        emit(state.copyWith(status: EventStatus.success));
        await createAccountUseCase.execute(
          user,
          'DISPLAYNAME',
          authProvider: 'apple',
        );

        // Login başarılı

        // Login başarılı olduktan sonra profil bilgilerini yükle
        try {
          getIt<ProfileBloc>().add(FetchProfileInfoEvent(user.uid));
        } catch (e) {
          print('Profile fetch error: $e');
        }
      } else {
        emit(state.copyWith(status: EventStatus.failure));
      }
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        authError: e.code,
      ));
    }
    emit(state.copyWith(status: EventStatus.idle));
  }

  Future<void> _onLoginAsGuest(
    LoginAsGuestEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: EventStatus.processing));
    final startTime = DateTime.now();

    try {
      final user = await loginUseCase.loginAsGuest();
      if (user != null) {
        emit(state.copyWith(status: EventStatus.success));
        await createAccountUseCase.execute(
          user,
          'Guest User',
          authProvider: 'anonymous',
        );

        // Login başarılı

        // Login başarılı olduktan sonra profil bilgilerini yükle
        try {
          getIt<ProfileBloc>().add(FetchProfileInfoEvent(user.uid));
        } catch (e) {
          print('Profile fetch error: $e');
        }
      } else {
        emit(state.copyWith(status: EventStatus.failure));
      }
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        status: EventStatus.failure,
        authError: e.code,
      ));
    }
    emit(state.copyWith(status: EventStatus.idle));
  }

  Future<void> resetPassword(event, emit) async {
    emit(state.copyWith(
        resetPasswordStatus: EventStatus.processing,
        resetPasswordMessage: null));
    try {
      await loginUseCase.sendPasswordResetEmail(event.email);
      emit(state.copyWith(
        resetPasswordStatus: EventStatus.success,
        resetPasswordMessage: "Şifre sıfırlama maili gönderildi.",
      ));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        resetPasswordStatus: EventStatus.failure,
        authError: e.code,
      ));
    }
    emit(state.copyWith(
      resetPasswordStatus: EventStatus.idle,
    ));
  }
}
