part of 'text_to_image_bloc.dart';

class TextToImageState extends Equatable {
  final EventStatus? status;
  final EventStatus? textToImageStatus;
  final String? textToImagePhotoBase64;
  final String? textToImagePhotoUrl;
  final bool? textToImagePhotoIsBase64;
  final String? filterErrorMessage;

  const TextToImageState({
    this.status,
    this.textToImageStatus,
    this.textToImagePhotoBase64,
    this.textToImagePhotoUrl,
    this.textToImagePhotoIsBase64,
    this.filterErrorMessage,
  });

  TextToImageState copyWith({
    EventStatus? status,
    EventStatus? textToImageStatus,
    String? textToImagePhotoBase64,
    String? textToImagePhotoUrl,
    bool? textToImagePhotoIsBase64,
    String? filterErrorMessage,
  }) {
    return TextToImageState(
      status: status ?? this.status,
      textToImageStatus: textToImageStatus ?? this.textToImageStatus,
      textToImagePhotoBase64:
          textToImagePhotoBase64 ?? this.textToImagePhotoBase64,
      textToImagePhotoUrl: textToImagePhotoUrl ?? this.textToImagePhotoUrl,
      textToImagePhotoIsBase64:
          textToImagePhotoIsBase64 ?? this.textToImagePhotoIsBase64,
      filterErrorMessage: filterErrorMessage ?? this.filterErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        textToImageStatus,
        textToImagePhotoBase64,
        textToImagePhotoUrl,
        textToImagePhotoIsBase64,
        filterErrorMessage,
      ];
}
