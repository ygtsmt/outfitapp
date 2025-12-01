part of 'video_generate_bloc.dart';

class VideoGenerateState extends Equatable {
  final EventStatus? status;
  final EventStatus uploadStatus;
  final String? kissType;
  final VideoGeneratePixversePolloRequestInputModel? requestModel;
  final double? startImageAspectRatio;
  final double? tailImageAspectRatio;
  final String? errorMessage;

  const VideoGenerateState({
    this.status,
    this.uploadStatus = EventStatus.idle,
    this.kissType,
    this.requestModel,
    this.startImageAspectRatio,
    this.tailImageAspectRatio,
    this.errorMessage,
  });

  VideoGenerateState copyWith({
    EventStatus? status,
    EventStatus? uploadStatus,
    String? kissType,
    VideoGeneratePixversePolloRequestInputModel? requestModel,
    double? startImageAspectRatio,
    double? tailImageAspectRatio,
    String? errorMessage,
  }) {
    return VideoGenerateState(
      status: status ?? this.status,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      kissType: kissType ?? this.kissType,
      requestModel: requestModel ?? this.requestModel,
      startImageAspectRatio:
          startImageAspectRatio ?? this.startImageAspectRatio,
      tailImageAspectRatio: tailImageAspectRatio ?? this.tailImageAspectRatio,
    );
  }

  @override
  List<Object?> get props => [
        status,
        uploadStatus,
        kissType,
        requestModel,
        startImageAspectRatio,
        tailImageAspectRatio,
        errorMessage,
      ];
}