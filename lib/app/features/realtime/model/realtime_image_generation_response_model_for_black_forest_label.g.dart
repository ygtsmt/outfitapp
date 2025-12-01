// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_image_generation_response_model_for_black_forest_label.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealtimeImageGenerationResponseModelForBlackForest
    _$RealtimeImageGenerationResponseModelForBlackForestFromJson(
            Map<String, dynamic> json) =>
        RealtimeImageGenerationResponseModelForBlackForest(
          id: json['id'] as String?,
          model: json['model'] as String?,
          version: json['version'] as String?,
          input: json['input'] as Map<String, dynamic>?,
          output: (json['output'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
          status: json['status'] as String?,
          createdAt: json['created_at'] as String?,
          isDeleted: json['isDeleted'] as bool?,
          isRealtimeImage: json['isRealtimeImage'] as bool?,
        );

Map<String, dynamic> _$RealtimeImageGenerationResponseModelForBlackForestToJson(
        RealtimeImageGenerationResponseModelForBlackForest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'model': instance.model,
      'version': instance.version,
      'input': instance.input,
      'output': instance.output,
      'status': instance.status,
      'isDeleted': instance.isDeleted,
      'isRealtimeImage': instance.isRealtimeImage,
      'created_at': instance.createdAt,
    };
