part of "splash_bloc.dart";

class SplashState extends Equatable {
  const SplashState({
    this.autoLoginStatus = EventStatus.idle,
  });

  final EventStatus autoLoginStatus;

  SplashState copyWith({
    final EventStatus? autoLoginStatus,
  }) {
    return SplashState(
      autoLoginStatus: autoLoginStatus ?? this.autoLoginStatus,
    );
  }

  @override
  List<Object?> get props => [
        autoLoginStatus,
      ];
}
