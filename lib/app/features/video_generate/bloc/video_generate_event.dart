part of 'video_generate_bloc.dart';

abstract class VideoGenerateEvent extends Equatable {
  const VideoGenerateEvent();

  @override
  List<Object> get props => [];
}

class HugVideoGenerateEvent extends VideoGenerateEvent {
  final String hugTypePrompt;
  final File imageFile;

  const HugVideoGenerateEvent({
    required this.hugTypePrompt,
    required this.imageFile,
  });

  @override
  List<Object> get props => [hugTypePrompt, imageFile];
}

class UploadUserImageEvent extends VideoGenerateEvent {
  final String filePath; // Galeriden seçilen fotoğrafın dosya yolu

  const UploadUserImageEvent({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

class UpdateRequestModelEvent extends VideoGenerateEvent {
  final VideoGeneratePixversePolloRequestInputModel updatedRequestModel;

  const UpdateRequestModelEvent({required this.updatedRequestModel});
  @override
  List<Object> get props => [updatedRequestModel];
}

class UploadPhotoEvent extends VideoGenerateEvent {
  final File imageFile;
  final bool isFirstphoto;

  const UploadPhotoEvent(
    this.imageFile,
    this.isFirstphoto,
  );

  @override
  List<Object> get props => [
        imageFile,
        isFirstphoto,
      ];
}

class SetKissTypeEvent extends VideoGenerateEvent {
  final String kissType;
  const SetKissTypeEvent({required this.kissType});

  @override
  List<Object> get props => [];
}

class VideoGeneratePolloEvent extends VideoGenerateEvent {
  final VideoGeneratePolloRequestInputModel videoGeneratePolloRequestInputModel;

  const VideoGeneratePolloEvent({
    required this.videoGeneratePolloRequestInputModel,
  });

  @override
  List<Object> get props => [videoGeneratePolloRequestInputModel];
}

class VideoGeneratePixversePolloEvent extends VideoGenerateEvent {
  final VideoGeneratePixversePolloRequestInputModel
      videoGeneratePixversePolloRequestInputModel;

  const VideoGeneratePixversePolloEvent({
    required this.videoGeneratePixversePolloRequestInputModel,
  });

  @override
  List<Object> get props => [videoGeneratePixversePolloRequestInputModel];
}

// CheckPolloStatusEvent kaldırıldı - artık webhook kullanılıyor

class ClearImageEvent extends VideoGenerateEvent {
  final bool isFirstImage; // true for start image, false for end image

  const ClearImageEvent({required this.isFirstImage});

  @override
  List<Object> get props => [isFirstImage];
}

class UpdateImageAspectRatioEvent extends VideoGenerateEvent {
  final bool isStartImage; // true for start image, false for end image
  final double aspectRatio;

  const UpdateImageAspectRatioEvent({
    required this.isStartImage,
    required this.aspectRatio,
  });

  @override
  List<Object> get props => [isStartImage, aspectRatio];
}

class PickImageEvent extends VideoGenerateEvent {
  final bool isStartImage;
  final String? croppedFilePath;

  const PickImageEvent({
    required this.isStartImage,
    this.croppedFilePath,
  });

  @override
  List<Object> get props => [isStartImage, croppedFilePath ?? ''];
}

class UpdateSettingsEvent extends VideoGenerateEvent {
  final String? resolution;
  final int? length;
  final String? aspectRatio;
  final String? style;
  final String? mode;
  final String? negativePrompt;

  const UpdateSettingsEvent({
    this.resolution,
    this.length,
    this.aspectRatio,
    this.style,
    this.mode,
    this.negativePrompt,
  });

  @override
  List<Object> get props => [
        resolution ?? '',
        length ?? 0,
        aspectRatio ?? '',
        style ?? '',
        mode ?? '',
        negativePrompt ?? '',
      ];
}

class GenerateVideoEvent extends VideoGenerateEvent {
  final String prompt;

  const GenerateVideoEvent({
    required this.prompt,
  });

  @override
  List<Object> get props => [prompt];
}

class ResetVideoGenerateFormEvent extends VideoGenerateEvent {
  const ResetVideoGenerateFormEvent();

  @override
  List<Object> get props => [];
}

class RegenerateVideoEvent extends VideoGenerateEvent {
  final VideoGenerateResponseModel originalVideo;
  final int randomSeed;

  const RegenerateVideoEvent({
    required this.originalVideo,
    required this.randomSeed,
  });

  @override
  List<Object> get props => [originalVideo, randomSeed];
}
