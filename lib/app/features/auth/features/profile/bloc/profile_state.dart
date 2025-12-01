part of "profile_bloc.dart";

class ProfileState extends Equatable {
  const ProfileState({
    this.status = EventStatus.idle,
    this.logoutStatus = EventStatus.idle,
    this.deleteAccountStatus = EventStatus.idle,
    this.changePasswordStatus = EventStatus.idle,
    required this.auth,
    required this.googleSignIn,
    this.profileInfo,
    this.profileGeneralErrorMessage,
    this.profileImageUploadStatus = EventStatus.idle,
    this.updateUsernameStatus = EventStatus.idle,
  });

  final EventStatus status;
  final EventStatus logoutStatus;
  final EventStatus deleteAccountStatus;
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;
  final UserProfile? profileInfo;
  final String? profileGeneralErrorMessage;
  final EventStatus changePasswordStatus;
  final EventStatus profileImageUploadStatus;
  final EventStatus updateUsernameStatus;

  ProfileState copyWith({
    EventStatus? status,
    EventStatus? logoutStatus,
    EventStatus? deleteAccountStatus,
    EventStatus? changePasswordStatus,
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    UserProfile? profileInfo,
    String? profileGeneralErrorMessage,
    EventStatus? profileImageUploadStatus,
    EventStatus? updateUsernameStatus,
  }) {
    return ProfileState(
      status: status ?? this.status,
      logoutStatus: logoutStatus ?? this.logoutStatus,
      deleteAccountStatus: deleteAccountStatus ?? this.deleteAccountStatus,
      changePasswordStatus: changePasswordStatus ?? this.changePasswordStatus,
      auth: auth ?? this.auth,
      googleSignIn: googleSignIn ?? this.googleSignIn,
      profileInfo: profileInfo ?? this.profileInfo,
      profileGeneralErrorMessage:
          profileGeneralErrorMessage ?? this.profileGeneralErrorMessage,
      profileImageUploadStatus:
          profileImageUploadStatus ?? this.profileImageUploadStatus,
      updateUsernameStatus: updateUsernameStatus ?? this.updateUsernameStatus,
    );
  }

  @override
  List<Object?> get props => [
        status,
        logoutStatus,
        deleteAccountStatus,
        changePasswordStatus,
        auth,
        googleSignIn,
        profileInfo,
        profileGeneralErrorMessage,
        profileImageUploadStatus,
      ];
}
