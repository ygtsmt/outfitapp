part of 'library_bloc.dart';

class LibraryState extends Equatable {
  final EventStatus? gettingVideoStatus;
  final EventStatus? videoForUpdateStatus;
  final EventStatus? videoSoftDeleteStatus;
  final EventStatus? imageSoftDeleteStatus;
  final EventStatus? realtimeImageSoftDeleteStatus;

  final List<VideoGenerateResponseModel?>? userGeneratedVideos;
  final List<TextToImageImageGenerationResponseModelForBlackForestLabel?>?
      userGeneratedImages;
  final List<TextToImageImageGenerationResponseModelForBlackForestLabel?>?
      userGeneratedRealtimeImages;
  final EventStatus? gettingImagesStatus;
  final EventStatus? gettingRealtimeImagesStatus;
  final EventStatus refreshUserVideosStatus;
  final EventStatus checkVideoStatusesStatus;
  final String? errorMessage;

  const LibraryState({
    this.gettingVideoStatus,
    this.videoForUpdateStatus,
    this.videoSoftDeleteStatus,
    this.imageSoftDeleteStatus,
    this.realtimeImageSoftDeleteStatus,
    this.userGeneratedVideos,
    this.userGeneratedImages,
    this.userGeneratedRealtimeImages,
    this.gettingImagesStatus,
    this.gettingRealtimeImagesStatus,
    this.refreshUserVideosStatus = EventStatus.idle,
    this.checkVideoStatusesStatus = EventStatus.idle,
    this.errorMessage,
  });

  LibraryState copyWith({
    EventStatus? gettingVideoStatus,
    EventStatus? videoForUpdateStatus,
    EventStatus? videoSoftDeleteStatus,
    EventStatus? imageSoftDeleteStatus,
    EventStatus? realtimeImageSoftDeleteStatus,
    List<VideoGenerateResponseModel?>? userGeneratedVideos,
    List<TextToImageImageGenerationResponseModelForBlackForestLabel?>?
        userGeneratedImages,
    List<TextToImageImageGenerationResponseModelForBlackForestLabel?>?
        userGeneratedRealtimeImages,
    EventStatus? gettingImagesStatus,
    EventStatus? gettingRealtimeImagesStatus,
    EventStatus? refreshUserVideosStatus,
    EventStatus? checkVideoStatusesStatus,
    String? errorMessage,
  }) {
    return LibraryState(
      gettingVideoStatus: gettingVideoStatus ?? this.gettingVideoStatus,
      videoForUpdateStatus: videoForUpdateStatus ?? this.videoForUpdateStatus,
      videoSoftDeleteStatus:
          videoSoftDeleteStatus ?? this.videoSoftDeleteStatus,
      imageSoftDeleteStatus:
          imageSoftDeleteStatus ?? this.imageSoftDeleteStatus,
      realtimeImageSoftDeleteStatus:
          realtimeImageSoftDeleteStatus ?? this.realtimeImageSoftDeleteStatus,
      userGeneratedVideos: userGeneratedVideos ?? this.userGeneratedVideos,
      userGeneratedImages: userGeneratedImages ?? this.userGeneratedImages,
      userGeneratedRealtimeImages:
          userGeneratedRealtimeImages ?? this.userGeneratedRealtimeImages,
      gettingImagesStatus: gettingImagesStatus ?? this.gettingImagesStatus,
      gettingRealtimeImagesStatus:
          gettingRealtimeImagesStatus ?? this.gettingRealtimeImagesStatus,
      refreshUserVideosStatus:
          refreshUserVideosStatus ?? this.refreshUserVideosStatus,
      checkVideoStatusesStatus:
          checkVideoStatusesStatus ?? this.checkVideoStatusesStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        gettingVideoStatus,
        videoForUpdateStatus,
        videoSoftDeleteStatus,
        imageSoftDeleteStatus,
        realtimeImageSoftDeleteStatus,
        userGeneratedVideos,
        userGeneratedImages,
        userGeneratedRealtimeImages,
        gettingImagesStatus,
        gettingRealtimeImagesStatus,
        refreshUserVideosStatus,
        checkVideoStatusesStatus,
        errorMessage,
      ];
}
