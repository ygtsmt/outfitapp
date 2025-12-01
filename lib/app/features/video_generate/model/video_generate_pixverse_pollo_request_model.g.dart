// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_generate_pixverse_pollo_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoGeneratePixversePolloRequestModel
    _$VideoGeneratePixversePolloRequestModelFromJson(
            Map<String, dynamic> json) =>
        VideoGeneratePixversePolloRequestModel(
          input: VideoGeneratePixversePolloRequestInputModel.fromJson(
              json['input'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$VideoGeneratePixversePolloRequestModelToJson(
        VideoGeneratePixversePolloRequestModel instance) =>
    <String, dynamic>{
      'input': instance.input,
    };

VideoGeneratePixversePolloRequestInputModel
    _$VideoGeneratePixversePolloRequestInputModelFromJson(
            Map<String, dynamic> json) =>
        VideoGeneratePixversePolloRequestInputModel(
          mode: json['mode'] as String?,
          image: json['image'] as String?,
          prompt: json['prompt'] as String?,
          imageTail: json['imageTail'] as String?,
          length: (json['length'] as num?)?.toInt(),
          negativePrompt: json['negativePrompt'] as String?,
          seed: (json['seed'] as num?)?.toInt(),
          resolution: json['resolution'] as String?,
          style: json['style'] as String?,
          aspectRatio: json['aspectRatio'] as String?,
          templateName: json['templateName'] as String?,
          effect: json['effect'] as String?,
        );

Map<String, dynamic> _$VideoGeneratePixversePolloRequestInputModelToJson(
    VideoGeneratePixversePolloRequestInputModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('mode', instance.mode);
  writeNotNull('image', instance.image);
  writeNotNull('prompt', instance.prompt);
  writeNotNull('imageTail', instance.imageTail);
  writeNotNull('length', instance.length);
  writeNotNull('negativePrompt', instance.negativePrompt);
  writeNotNull('seed', instance.seed);
  writeNotNull('resolution', instance.resolution);
  writeNotNull('style', instance.style);
  writeNotNull('aspectRatio', instance.aspectRatio);
  writeNotNull('templateName', instance.templateName);
  writeNotNull('effect', instance.effect);
  return val;
}
