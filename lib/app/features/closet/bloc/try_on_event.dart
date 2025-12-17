part of 'try_on_bloc.dart';

abstract class TryOnEvent extends Equatable {
  const TryOnEvent();

  @override
  List<Object?> get props => [];
}

class GenerateTryOnEvent extends TryOnEvent {
  final List<String> imageUrls; // [model_url, closet1_url, closet2_url]

  const GenerateTryOnEvent(this.imageUrls);

  @override
  List<Object?> get props => [imageUrls];
}



