part of 'text_to_image_bloc.dart';

abstract class TextToImageEvent extends Equatable {
  const TextToImageEvent();

  @override
  List<Object> get props => [];
}

class GenerateImageForTextToImageFluxFree extends TextToImageEvent {
  final String prompt;
  final Size size;

  const GenerateImageForTextToImageFluxFree({
    required this.prompt,
    required this.size,
  });

  @override
  List<Object> get props => [prompt, size];
}

class GenerateImageForTextToImageFlux extends TextToImageEvent {
  final String prompt;
  final Size size;

  const GenerateImageForTextToImageFlux({
    required this.prompt,
    required this.size,
  });

  @override
  List<Object> get props => [prompt, size];
}

class GenerateImageForTextToImageBlackForest extends TextToImageEvent {
  final String prompt;

  const GenerateImageForTextToImageBlackForest({required this.prompt});

  @override
  List<Object> get props => [prompt];
}
