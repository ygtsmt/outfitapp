// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_generate_pollo_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoGeneratePolloResponseModel _$VideoGeneratePolloResponseModelFromJson(
        Map<String, dynamic> json) =>
    VideoGeneratePolloResponseModel(
      code: json['code'] as String?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : PolloData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VideoGeneratePolloResponseModelToJson(
        VideoGeneratePolloResponseModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

PolloData _$PolloDataFromJson(Map<String, dynamic> json) => PolloData(
      taskId: json['taskId'] as String?,
      status: json['status'] as String?,
      generations: (json['generations'] as List<dynamic>?)
          ?.map((e) => PolloGeneration.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PolloDataToJson(PolloData instance) => <String, dynamic>{
      'taskId': instance.taskId,
      'status': instance.status,
      'generations': instance.generations,
    };

PolloGeneration _$PolloGenerationFromJson(Map<String, dynamic> json) =>
    PolloGeneration(
      id: json['id'] as String?,
      createdDate: json['createdDate'] as String?,
      updatedDate: json['updatedDate'] as String?,
      status: json['status'] as String?,
      failMsg: json['failMsg'] as String?,
      url: json['url'] as String?,
      mediaType: json['mediaType'] as String?,
    );

Map<String, dynamic> _$PolloGenerationToJson(PolloGeneration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdDate': instance.createdDate,
      'updatedDate': instance.updatedDate,
      'status': instance.status,
      'failMsg': instance.failMsg,
      'url': instance.url,
      'mediaType': instance.mediaType,
    };
