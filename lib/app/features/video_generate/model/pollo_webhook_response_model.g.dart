// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pollo_webhook_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolloWebhookResponseModel _$PolloWebhookResponseModelFromJson(
        Map<String, dynamic> json) =>
    PolloWebhookResponseModel(
      status: json['status'] as String?,
      taskId: json['taskId'] as String?,
      generations: (json['generations'] as List<dynamic>?)
          ?.map(
              (e) => PolloWebhookGeneration.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PolloWebhookResponseModelToJson(
        PolloWebhookResponseModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'taskId': instance.taskId,
      'generations': instance.generations,
    };

PolloWebhookGeneration _$PolloWebhookGenerationFromJson(
        Map<String, dynamic> json) =>
    PolloWebhookGeneration(
      id: json['id'] as String?,
      url: json['url'] as String?,
      status: json['status'] as String?,
      failMsg: json['failMsg'] as String?,
      mediaType: json['mediaType'] as String?,
      createdDate: json['createdDate'] as String?,
      updatedDate: json['updatedDate'] as String?,
    );

Map<String, dynamic> _$PolloWebhookGenerationToJson(
        PolloWebhookGeneration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'status': instance.status,
      'failMsg': instance.failMsg,
      'mediaType': instance.mediaType,
      'createdDate': instance.createdDate,
      'updatedDate': instance.updatedDate,
    };
