// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_generate_pollo_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoGeneratePolloRequestModel _$VideoGeneratePolloRequestModelFromJson(
        Map<String, dynamic> json) =>
    VideoGeneratePolloRequestModel(
      input: VideoGeneratePolloRequestInputModel.fromJson(
          json['input'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VideoGeneratePolloRequestModelToJson(
        VideoGeneratePolloRequestModel instance) =>
    <String, dynamic>{
      'input': instance.input,
    };

VideoGeneratePolloRequestInputModel
    _$VideoGeneratePolloRequestInputModelFromJson(Map<String, dynamic> json) =>
        VideoGeneratePolloRequestInputModel(
          image: json['image'] as String?,
          imageTail: json['imageTail'] as String?,
          prompt: json['prompt'] as String?,
          negativePrompt: json['negativePrompt'] as String?,
          numFrames: (json['numFrames'] as num?)?.toInt(),
          lenght: (json['lenght'] as num?)?.toInt(),
          aspectRatio: json['aspectRatio'] as String?,
          motion: json['motion'] as String?,
          seed: (json['seed'] as num?)?.toInt(),
          model: json['model'] as String?,
          quality: json['quality'] as String?,
          style: json['style'] as String?,
          parameters: json['parameters'] as Map<String, dynamic>?,
        );

Map<String, dynamic> _$VideoGeneratePolloRequestInputModelToJson(
    VideoGeneratePolloRequestInputModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('image', instance.image);
  writeNotNull('imageTail', instance.imageTail);
  writeNotNull('prompt', instance.prompt);
  writeNotNull('negativePrompt', instance.negativePrompt);
  writeNotNull('numFrames', instance.numFrames);
  writeNotNull('lenght', instance.lenght);
  writeNotNull('aspectRatio', instance.aspectRatio);
  writeNotNull('motion', instance.motion);
  writeNotNull('seed', instance.seed);
  writeNotNull('model', instance.model);
  writeNotNull('quality', instance.quality);
  writeNotNull('style', instance.style);
  writeNotNull('parameters', instance.parameters);
  return val;
}
