// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_to_image_flux_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextToImageFluxRequestModel _$TextToImageFluxRequestModelFromJson(
        Map<String, dynamic> json) =>
    TextToImageFluxRequestModel(
      model: json['model'] as String,
      prompt: json['prompt'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      steps: (json['steps'] as num).toInt(),
      n: (json['n'] as num).toInt(),
      seed: (json['seed'] as num).toInt(),
      responseFormat: json['response_format'] as String,
    );

Map<String, dynamic> _$TextToImageFluxRequestModelToJson(
        TextToImageFluxRequestModel instance) =>
    <String, dynamic>{
      'model': instance.model,
      'prompt': instance.prompt,
      'width': instance.width,
      'height': instance.height,
      'steps': instance.steps,
      'n': instance.n,
      'seed': instance.seed,
      'response_format': instance.responseFormat,
    };
