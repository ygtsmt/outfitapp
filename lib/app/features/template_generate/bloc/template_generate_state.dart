part of 'template_generate_bloc.dart';

class TemplateGenerateState extends Equatable {
  final EventStatus uploadStatus;
  final EventStatus generateStatus;
  final String? errorMessage;
  final String? uploadedPhotoUrl;
  final bool isGenerationStarted;

  const TemplateGenerateState({
    this.uploadStatus = EventStatus.idle,
    this.generateStatus = EventStatus.idle,
    this.errorMessage,
    this.uploadedPhotoUrl,
    this.isGenerationStarted = false,
  });

  TemplateGenerateState copyWith({
    EventStatus? uploadStatus,
    EventStatus? generateStatus,
    String? errorMessage,
    String? uploadedPhotoUrl,
    bool? isGenerationStarted,
  }) {
    return TemplateGenerateState(
      uploadStatus: uploadStatus ?? this.uploadStatus,
      generateStatus: generateStatus ?? this.generateStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedPhotoUrl: uploadedPhotoUrl ?? this.uploadedPhotoUrl,
      isGenerationStarted: isGenerationStarted ?? this.isGenerationStarted,
    );
  }

  @override
  List<Object?> get props => [
        uploadStatus,
        generateStatus,
        errorMessage,
        uploadedPhotoUrl,
        isGenerationStarted,
      ];
}

