part of 'realtime_bloc.dart';

class RealtimeState extends Equatable {
  final EventStatus? status;
  final EventStatus? realtimeImageSoftDeleteStatus;
  final String? errorMessage;
  final String? realtimePhotoBase64;
  final List<String>? realtimePhotoBase64LIST;
  final String? realtimePhotoUrl;
  final bool? realtimePhotoIsBase64;
  final int? currentSeed;

  const RealtimeState({
    this.status,
    this.realtimeImageSoftDeleteStatus,
    this.errorMessage,
    this.realtimePhotoBase64,
    this.realtimePhotoBase64LIST,
    this.realtimePhotoUrl,
    this.realtimePhotoIsBase64,
    this.currentSeed,
  });

  RealtimeState copyWith({
    EventStatus? status,
    EventStatus? realtimeImageSoftDeleteStatus,
    String? errorMessage,
    String? realtimePhotoBase64,
    List<String>? realtimePhotoBase64LIST,
    String? realtimePhotoUrl,
    bool? realtimePhotoIsBase64,
    int? currentSeed,
  }) {
    return RealtimeState(
      status: status ?? this.status,
      realtimeImageSoftDeleteStatus:
          realtimeImageSoftDeleteStatus ?? this.realtimeImageSoftDeleteStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      realtimePhotoBase64: realtimePhotoBase64 ?? this.realtimePhotoBase64,
      realtimePhotoBase64LIST:
          realtimePhotoBase64LIST ?? this.realtimePhotoBase64LIST,
      realtimePhotoUrl: realtimePhotoUrl ?? this.realtimePhotoUrl,
      realtimePhotoIsBase64:
          realtimePhotoIsBase64 ?? this.realtimePhotoIsBase64,
      currentSeed: currentSeed ?? this.currentSeed,
    );
  }

  @override
  List<Object?> get props => [
        status,
        realtimeImageSoftDeleteStatus,
        errorMessage,
        realtimePhotoBase64,
        realtimePhotoBase64LIST,
        realtimePhotoUrl,
        realtimePhotoIsBase64,
        currentSeed,
      ];
}
