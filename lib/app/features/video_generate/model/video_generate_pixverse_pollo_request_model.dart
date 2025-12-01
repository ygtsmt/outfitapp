import 'package:json_annotation/json_annotation.dart';

part 'video_generate_pixverse_pollo_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class VideoGeneratePixversePolloRequestModel {
  final VideoGeneratePixversePolloRequestInputModel input;

  VideoGeneratePixversePolloRequestModel({
    required this.input,
  });

  factory VideoGeneratePixversePolloRequestModel.fromJson(
          Map<String, dynamic> json) =>
      _$VideoGeneratePixversePolloRequestModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$VideoGeneratePixversePolloRequestModelToJson(this);
}

@JsonSerializable(includeIfNull: false)
class VideoGeneratePixversePolloRequestInputModel {
  final String? mode;
  final String? image;
  final String? prompt;
  final String? imageTail;
  final int? length;
  final String? negativePrompt;
  final int? seed;
  final String? resolution;
  final String? style;
  final String? aspectRatio;
  final String? templateName;
  final String? effect;

  VideoGeneratePixversePolloRequestInputModel({
    this.mode,
    this.image,
    this.prompt,
    this.imageTail,
    this.length,
    this.negativePrompt,
    this.seed,
    this.resolution,
    this.style,
    this.aspectRatio,
    this.templateName,
    this.effect,
  });

  factory VideoGeneratePixversePolloRequestInputModel.fromJson(
          Map<String, dynamic> json) =>
      _$VideoGeneratePixversePolloRequestInputModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$VideoGeneratePixversePolloRequestInputModelToJson(this);

  VideoGeneratePixversePolloRequestInputModel copyWith({
    String? mode,
    String? image,
    String? prompt,
    String? imageTail,
    int? length,
    String? negativePrompt,
    int? seed,
    String? resolution,
    String? style,
    String? aspectRatio,
    String? templateName,
    String? effect,
  }) {
    return VideoGeneratePixversePolloRequestInputModel(
      mode: mode ?? this.mode,
      image: image ?? this.image,
      prompt: prompt ?? this.prompt,
      imageTail: imageTail ?? this.imageTail,
      length: length ?? this.length,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      seed: seed ?? this.seed,
      resolution: resolution ?? this.resolution,
      style: style ?? this.style,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      templateName: templateName ?? this.templateName,
      effect: effect ?? this.effect,
    );
  }
}
