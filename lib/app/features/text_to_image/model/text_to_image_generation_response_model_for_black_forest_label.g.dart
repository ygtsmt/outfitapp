// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_to_image_generation_response_model_for_black_forest_label.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TextToImageImageGenerationResponseModelForBlackForestLabel
    _$TextToImageImageGenerationResponseModelForBlackForestLabelFromJson(
            Map<String, dynamic> json) =>
        TextToImageImageGenerationResponseModelForBlackForestLabel(
          id: json['id'] as String?,
          model: json['model'] as String?,
          version: json['version'] as String?,
          input: json['input'] as Map<String, dynamic>?,
          output: (json['output'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
          status: json['status'] as String?,
          isRealtimeImage: json['isRealtimeImage'] as bool?,
          isDeleted: json['isDeleted'] as bool?,
          createdAt: json['created_at'] as String?,
          urls: json['urls'] == null
              ? null
              : VideoUrls.fromJson(json['urls'] as Map<String, dynamic>),
          prompt: json['prompt'] as String?,
          createdAtDirect: json['createdAt'] as String?,
        );

Map<String,
    dynamic> _$TextToImageImageGenerationResponseModelForBlackForestLabelToJson(
        TextToImageImageGenerationResponseModelForBlackForestLabel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'model': instance.model,
      'version': instance.version,
      'input': instance.input,
      'output': instance.output,
      'status': instance.status,
      'isRealtimeImage': instance.isRealtimeImage,
      'created_at': instance.createdAt,
      'urls': instance.urls,
      'isDeleted': instance.isDeleted,
      'prompt': instance.prompt,
      'createdAt': instance.createdAtDirect,
    };
