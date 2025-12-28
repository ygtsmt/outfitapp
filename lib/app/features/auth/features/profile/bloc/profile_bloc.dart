import "dart:developer";
import "dart:io";
import "package:ginfit/app/features/auth/features/create_account/data/create_account_usecase.dart";
import "package:ginfit/app/features/auth/features/login/data/login_usecase.dart";
import "package:ginfit/app/features/auth/features/profile/data/models/user_model.dart";
import "package:ginfit/app/features/auth/features/profile/data/profile_usecase.dart";
import "package:ginfit/core/core.dart";
import "package:equatable/equatable.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:injectable/injectable.dart";

part "profile_event.dart";
part "profile_state.dart";

@singleton
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final LoginUseCase loginUseCase;
  final CreateAccountUseCase createAccountUseCase;
  final ProfileUseCase profileUseCase;

  ProfileBloc({
    required this.loginUseCase,
    required this.createAccountUseCase,
    required this.profileUseCase,
  }) : super(
          ProfileState(
            auth: FirebaseAuth.instance,
            googleSignIn: GoogleSignIn(),
          ),
        ) {
    on<FetchProfileInfoEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: EventStatus.processing));
        final profileInfo = await profileUseCase.fetchUserProfile(event.userId);
        if (profileInfo != null) {
          emit(state.copyWith(
            status: EventStatus.success,
            profileInfo: profileInfo,
          ));
        } else {
          emit(state.copyWith(
            status: EventStatus.failure,
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          status: EventStatus.failure,
        ));
      }
    });

    on<LogoutEvent>((event, emit) async {
      try {
        emit(state.copyWith(logoutStatus: EventStatus.processing));
        await profileUseCase.logout();
        emit(state.copyWith(
          logoutStatus: EventStatus.success,
        ));
      } catch (e) {
        emit(state.copyWith(
          logoutStatus: EventStatus.failure,
        ));
      }
      emit(state.copyWith(logoutStatus: EventStatus.idle));
    });
    on<DeleteAccountEvent>((event, emit) async {
      try {
        emit(state.copyWith(deleteAccountStatus: EventStatus.processing));
        await profileUseCase.deleteAccount();
        emit(state.copyWith(
          deleteAccountStatus: EventStatus.success,
        ));
      } catch (e) {
        emit(state.copyWith(
          deleteAccountStatus: EventStatus.failure,
        ));
      }
      emit(state.copyWith(deleteAccountStatus: EventStatus.idle));
    });

    on<ChangePasswordEvent>((event, emit) async {
      try {
        emit(state.copyWith(changePasswordStatus: EventStatus.processing));
        await profileUseCase.changePassword(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
        );
        emit(state.copyWith(changePasswordStatus: EventStatus.success));
      } on FirebaseException catch (e) {
        emit(state.copyWith(
          profileGeneralErrorMessage: e.code,
          changePasswordStatus: EventStatus.failure,
        ));
      }
    });

    on<UpdateProfileImageEvent>((event, emit) async {
      emit(state.copyWith(profileImageUploadStatus: EventStatus.processing));

      try {
        final newImageUrl =
            await profileUseCase.updateProfilePhoto(event.imageFile);
        await profileUseCase.updateUserProfileImageUrl(newImageUrl ?? '');
        emit(state.copyWith(
          profileImageUploadStatus: EventStatus.success,
        ));
        getIt<ProfileBloc>()
            .add(FetchProfileInfoEvent(state.auth.currentUser?.uid ?? ''));
      } catch (e) {
        log(e.toString());
        emit(state.copyWith(
          profileImageUploadStatus: EventStatus.failure,
        ));
      }
      emit(state.copyWith(profileImageUploadStatus: EventStatus.idle));
    });

    on<UpdateUsernameEvent>((event, emit) async {
      try {
        emit(state.copyWith(updateUsernameStatus: EventStatus.processing));
        await profileUseCase.updateUsername(event.newUsername);
        emit(state.copyWith(updateUsernameStatus: EventStatus.success));
        // Refresh profile info after successful update
        getIt<ProfileBloc>()
            .add(FetchProfileInfoEvent(state.auth.currentUser?.uid ?? ''));
      } catch (e) {
        emit(state.copyWith(
          updateUsernameStatus: EventStatus.failure,
          profileGeneralErrorMessage: e.toString(),
        ));
      }
      emit(state.copyWith(updateUsernameStatus: EventStatus.idle));
    });
  }
}
