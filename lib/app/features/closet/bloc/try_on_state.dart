part of 'try_on_bloc.dart';

class TryOnState extends Equatable {
  final EventStatus generatingTryOnStatus;
  final String? requestId;
  final String? errorMessage;

  const TryOnState({
    this.generatingTryOnStatus = EventStatus.idle,
    this.requestId,
    this.errorMessage,
  });

  TryOnState copyWith({
    EventStatus? generatingTryOnStatus,
    String? requestId,
    String? errorMessage,
  }) {
    return TryOnState(
      generatingTryOnStatus: generatingTryOnStatus ?? this.generatingTryOnStatus,
      requestId: requestId ?? this.requestId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [generatingTryOnStatus, requestId, errorMessage];
}



