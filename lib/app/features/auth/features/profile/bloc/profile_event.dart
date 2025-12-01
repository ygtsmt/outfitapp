part of "profile_bloc.dart";

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchProfileInfoEvent extends ProfileEvent {
  final String userId; // Firestore'daki UID

  const FetchProfileInfoEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class LogoutEvent extends ProfileEvent {
  const LogoutEvent();

  @override
  List<Object> get props => [];
}

class DeleteAccountEvent extends ProfileEvent {
  const DeleteAccountEvent();

  @override
  List<Object> get props => [];
}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });
}

class UpdateProfileImageEvent extends ProfileEvent {
  final File imageFile;

  const UpdateProfileImageEvent(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

class UpdateUsernameEvent extends ProfileEvent {
  final String newUsername;

  const UpdateUsernameEvent(this.newUsername);

  @override
  List<Object> get props => [newUsername];
}
