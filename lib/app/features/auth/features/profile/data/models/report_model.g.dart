// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
      contentUrlOrBase64: json['contentUrlOrBase64'] as String?,
      description: json['description'] as String?,
      userId: json['userId'] as String,
      type: json['type'] as String?,
      isBase64: json['isBase64'] as bool?,
      prompt: json['prompt'] as String?,
      createdAt: json['createdAt'] as String?,
      contentId: json['contentId'] as String?,
      collectionName: json['collectionName'] as String?,
      documentId: json['documentId'] as String?,
    );

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'contentUrlOrBase64': instance.contentUrlOrBase64,
      'description': instance.description,
      'userId': instance.userId,
      'type': instance.type,
      'isBase64': instance.isBase64,
      'prompt': instance.prompt,
      'createdAt': instance.createdAt,
      'contentId': instance.contentId,
      'collectionName': instance.collectionName,
      'documentId': instance.documentId,
    };
