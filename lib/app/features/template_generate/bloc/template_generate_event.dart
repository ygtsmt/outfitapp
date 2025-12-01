part of 'template_generate_bloc.dart';

abstract class TemplateGenerateEvent extends Equatable {
  const TemplateGenerateEvent();

  @override
  List<Object> get props => [];
}

class UploadPhotoForTemplateEvent extends TemplateGenerateEvent {
  final File imageFile;
  final String? prompt;
  final String? negativePrompt;
  final int? length;
  final String aspectRatio;
  final int? seed;
  final String resolution;
  final String style;
  final String? templateName;
  final String? effect;
  final String? aiModel; // Template'in AI model bilgisi
  final int? templateId; // Template ID for Pixverse Original API

  const UploadPhotoForTemplateEvent({
    required this.imageFile,
    this.prompt,
    this.negativePrompt,
    this.length,
    required this.aspectRatio,
    this.seed,
    required this.resolution,
    required this.style,
    this.templateName,
    this.aiModel,
    this.effect,
    this.templateId,
  });

  @override
  List<Object> get props => [
        imageFile,
        prompt ?? '',
        negativePrompt ?? '',
        length ?? 0,
        aspectRatio,
        seed ?? 0,
        resolution,
        style,
        templateName ?? '',
        aiModel ?? '',
        effect ?? '',
        templateId ?? 0,
      ];
}
