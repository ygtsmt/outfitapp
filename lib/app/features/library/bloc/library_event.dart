part of 'library_bloc.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object> get props => [];
}

class GetUserGeneratedVideosEvent extends LibraryEvent {
  const GetUserGeneratedVideosEvent();

  @override
  List<Object> get props => [];
}

class GetUserGeneratedImagesEvent extends LibraryEvent {
  const GetUserGeneratedImagesEvent();

  @override
  List<Object> get props => [];
}

class GetUserGeneratedRealtimeImagesEvent extends LibraryEvent {
  const GetUserGeneratedRealtimeImagesEvent();

  @override
  List<Object> get props => [];
}

class UpdateUserVideoOutputEvent extends LibraryEvent {
  final VideoGenerateResponseModel newModel;

  const UpdateUserVideoOutputEvent(
    this.newModel,
  );

  @override
  List<Object> get props => [
        newModel,
      ];
}

class SoftDeleteUserGeneratedVideoEvent extends LibraryEvent {
  final String videoId;
  const SoftDeleteUserGeneratedVideoEvent({required this.videoId});

  @override
  List<Object> get props => [videoId];
}

class SoftDeleteImageEvent extends LibraryEvent {
  final String imageId;
  const SoftDeleteImageEvent({required this.imageId});

  @override
  List<Object> get props => [imageId];
}

class SoftDeleteRealtimeImageEvent extends LibraryEvent {
  final String imageId;
  const SoftDeleteRealtimeImageEvent({required this.imageId});

  @override
  List<Object> get props => [imageId];
}

class RefreshUserVideosEvent extends LibraryEvent {
  const RefreshUserVideosEvent();
}

class CheckVideoStatusesEvent extends LibraryEvent {
  const CheckVideoStatusesEvent();
}

class CheckPendingPixverseOriginalVideosEvent extends LibraryEvent {
  const CheckPendingPixverseOriginalVideosEvent();
  
  @override
  List<Object> get props => [];
}
