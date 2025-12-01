import 'package:json_annotation/json_annotation.dart';

part 'video_generate_pollo_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class VideoGeneratePolloRequestModel {
  final VideoGeneratePolloRequestInputModel input;

  VideoGeneratePolloRequestModel({
    required this.input,
  });

  factory VideoGeneratePolloRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VideoGeneratePolloRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoGeneratePolloRequestModelToJson(this);
}

@JsonSerializable(includeIfNull: false)
class VideoGeneratePolloRequestInputModel {
  final String? image;
  final String? imageTail;
  final String? prompt;
  final String? negativePrompt;
  final int? numFrames;
  final int? lenght;
  final String? aspectRatio;
  final String? motion;
  final int? seed;
  final String? model;
  final String? quality;
  final String? style;
  final Map<String, dynamic>? parameters;

  VideoGeneratePolloRequestInputModel({
    this.image,
    this.imageTail,
    this.prompt,
    this.negativePrompt,
    this.numFrames,
    this.lenght,
    this.aspectRatio,
    this.motion,
    this.seed,
    this.model,
    this.quality,
    this.style,
    this.parameters,
  });

  factory VideoGeneratePolloRequestInputModel.fromJson(
          Map<String, dynamic> json) =>
      _$VideoGeneratePolloRequestInputModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$VideoGeneratePolloRequestInputModelToJson(this);

  VideoGeneratePolloRequestInputModel copyWith({
    String? image,
    String? imageTail,
    String? prompt,
    String? negativePrompt,
    int? numFrames,
    int? lenght,
    String? aspectRatio,
    String? motion,
    int? seed,
    String? model,
    String? quality,
    String? style,
    Map<String, dynamic>? parameters,
  }) {
    return VideoGeneratePolloRequestInputModel(
      image: image ?? this.image,
      imageTail: imageTail ?? this.imageTail,
          prompt: prompt ?? this.prompt,
      negativePrompt: negativePrompt ?? this.negativePrompt,
      numFrames: numFrames ?? this.numFrames,
      lenght: lenght ?? this.lenght,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      motion: motion ?? this.motion,
      seed: seed ?? this.seed,
      model: model ?? this.model,
      quality: quality ?? this.quality,
      style: style ?? this.style,
      parameters: parameters ?? this.parameters,
    );
  }
}
