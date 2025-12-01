part of 'realtime_bloc.dart';

abstract class RealtimeEvent extends Equatable {
  const RealtimeEvent();

  @override
  List<Object> get props => [];
}

class GenerateImageForRealtimeFluxFree extends RealtimeEvent {
  final String prompt;

  const GenerateImageForRealtimeFluxFree({required this.prompt});

  @override
  List<Object> get props => [prompt];
}

class GenerateImageForRealtimeFlux extends RealtimeEvent {
  final String prompt;
  final BuildContext context;

  const GenerateImageForRealtimeFlux({
    required this.prompt,
    required this.context,
  });

  @override
  List<Object> get props => [
        context,
        prompt,
      ];
}

class GenerateImageForRealTimeBlackForest extends RealtimeEvent {
  final String prompt;

  const GenerateImageForRealTimeBlackForest({required this.prompt});

  @override
  List<Object> get props => [prompt];
}

class SoftDeleteRealtimeImageEvent extends RealtimeEvent {
  final String imageId;
  const SoftDeleteRealtimeImageEvent({required this.imageId});

  @override
  List<Object> get props => [imageId];
}

class SelectedRealtimeBase64Event extends RealtimeEvent {
  final String selectedBase64;
  const SelectedRealtimeBase64Event({required this.selectedBase64});

  @override
  List<Object> get props => [selectedBase64];
}

class UseCreditEvent extends RealtimeEvent {
  final int availableCredit;
  final int requiredCredit;
  final BuildContext context;

  const UseCreditEvent({
    required this.availableCredit,
    required this.requiredCredit,
    required this.context,
  });

  @override
  List<Object> get props => [
        availableCredit,
        requiredCredit,
        context,
      ];
}




/* 
part of 'generate_bloc.dart';

abstract class RealtimeEvent extends Equatable {
  const RealtimeEvent();

  @override
  List<Object> get props => [];
}

class GenerateImageForRealtimeEvent extends RealtimeEvent {
  final String userUID;
  final String prompt;

  const GenerateImageForRealtimeEvent(
      {required this.userUID, required this.prompt});

  @override
  List<Object> get props => [userUID, prompt];
}

class GenerateImageForTextToImage extends RealtimeEvent {
  final String userUID;
  final String prompt;

  const GenerateImageForTextToImage(
      {required this.userUID, required this.prompt});

  @override
  List<Object> get props => [userUID, prompt];
}

class GenerateImageForBlackForestTextToImage extends RealtimeEvent {
  final String userUID;
  final String prompt;

  const GenerateImageForBlackForestTextToImage(
      {required this.userUID, required this.prompt});

  @override
  List<Object> get props => [userUID, prompt];
}


 */