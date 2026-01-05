import "package:comby/app/features/auth/features/create_account/data/create_account_usecase.dart";
import "package:comby/core/enums.dart";
import "package:equatable/equatable.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:google_sign_in/google_sign_in.dart";
import "package:injectable/injectable.dart";

part "create_account_event.dart";
part "create_account_state.dart";

@singleton
class CreateAccountBloc extends Bloc<_CreateAccountEvent, CreateAccountState> {
  final CreateAccountUseCase createAccountUseCase;

  CreateAccountBloc({required this.createAccountUseCase})
      : super(CreateAccountState(
            auth: FirebaseAuth.instance, googleSignIn: GoogleSignIn())) {
    on<CreateAccountEvent>(_onCreateAccountWithEmail);
    on<CreateAccountWithGoogleEvent>(_onCreateAccountWithGoogle);
    on<CreateAccountWithAppleEvent>(_onCreateAccountWithApple);
  }

  Future<void> _onCreateAccountWithEmail(
    CreateAccountEvent event,
    Emitter<CreateAccountState> emit,
  ) async {
    emit(state.copyWith(createAccountStatus: EventStatus.processing));
    final startTime = DateTime.now();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final isUpgradeFromAnonymous = currentUser?.isAnonymous ?? false;

      final user = await createAccountUseCase.createAccountWithEmail(
        event.email,
        event.password,
      );

      if (user != null) {
        await user.updateDisplayName(event.displayName);
        await user.reload();

        emit(state.copyWith(createAccountStatus: EventStatus.success));

        await createAccountUseCase.execute(
          user,
          event.displayName,
          authProvider: 'email',
          isUpgradeFromAnonymous: isUpgradeFromAnonymous,
        );

        // Analytics: Kayıt başarılı

        if (isUpgradeFromAnonymous) {
          print('✅ Anonymous hesap başarıyla email ile upgrade edildi!');
        } else {
          print('✅ Yeni email hesabı oluşturuldu!');
        }
      } else {
        emit(state.copyWith(createAccountStatus: EventStatus.failure));
      }
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        createAccountStatus: EventStatus.failure,
        authError: e.code,
      ));
    }
    emit(state.copyWith(createAccountStatus: EventStatus.idle));
  }

  Future<void> _onCreateAccountWithGoogle(
    CreateAccountWithGoogleEvent event,
    Emitter<CreateAccountState> emit,
  ) async {
    emit(state.copyWith(createAccountStatus: EventStatus.processing));
    final startTime = DateTime.now();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final isUpgradeFromAnonymous = currentUser?.isAnonymous ?? false;

      final user = await createAccountUseCase.createAccountWithGoogle();

      if (user != null) {
        emit(state.copyWith(createAccountStatus: EventStatus.success));

        await createAccountUseCase.execute(
          user,
          user.displayName ?? 'Google User',
          authProvider: 'google',
          isUpgradeFromAnonymous: isUpgradeFromAnonymous,
        );

        // Kayıt başarılı

        if (isUpgradeFromAnonymous) {
          print('✅ Anonymous hesap başarıyla Google ile upgrade edildi!');
        } else {
          print('✅ Yeni Google hesabı oluşturuldu!');
        }
      } else {
        emit(state.copyWith(createAccountStatus: EventStatus.failure));
      }
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        createAccountStatus: EventStatus.failure,
        authError: e.code,
      ));
    }
    emit(state.copyWith(createAccountStatus: EventStatus.idle));
  }

  Future<void> _onCreateAccountWithApple(
    CreateAccountWithAppleEvent event,
    Emitter<CreateAccountState> emit,
  ) async {
    emit(state.copyWith(createAccountStatus: EventStatus.processing));
    final startTime = DateTime.now();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final isUpgradeFromAnonymous = currentUser?.isAnonymous ?? false;

      final user = await createAccountUseCase.createAccountWithApple();

      if (user != null) {
        emit(state.copyWith(createAccountStatus: EventStatus.success));

        final displayName = user.displayName ??
            '${user.email?.split('@').first ?? 'Apple User'}';

        await createAccountUseCase.execute(
          user,
          displayName,
          authProvider: 'apple',
          isUpgradeFromAnonymous: isUpgradeFromAnonymous,
        );

        // Kayıt başarılı

        if (isUpgradeFromAnonymous) {
          print('✅ Anonymous hesap başarıyla Apple ile upgrade edildi!');
        } else {
          print('✅ Yeni Apple hesabı oluşturuldu!');
        }
      } else {
        emit(state.copyWith(createAccountStatus: EventStatus.failure));
      }
    } on FirebaseException catch (e) {
      emit(state.copyWith(
        createAccountStatus: EventStatus.failure,
        authError: e.code,
      ));
    }
    emit(state.copyWith(createAccountStatus: EventStatus.idle));
  }
}
