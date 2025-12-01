// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppDocumentModel _$AppDocumentModelFromJson(Map<String, dynamic> json) =>
    AppDocumentModel(
      privacyPolicy: json['privacyPolicy'] == null
          ? null
          : MultilangFile.fromJson(
              json['privacyPolicy'] as Map<String, dynamic>),
      refundPolicy: json['refund-policy'] == null
          ? null
          : MultilangFile.fromJson(
              json['refund-policy'] as Map<String, dynamic>),
      termsAndConditions: json['termsAndConditions'] == null
          ? null
          : MultilangFile.fromJson(
              json['termsAndConditions'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppDocumentModelToJson(AppDocumentModel instance) =>
    <String, dynamic>{
      'privacyPolicy': instance.privacyPolicy,
      'refund-policy': instance.refundPolicy,
      'termsAndConditions': instance.termsAndConditions,
    };
