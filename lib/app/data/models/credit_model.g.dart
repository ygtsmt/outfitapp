// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateCreditRequirements _$GenerateCreditRequirementsFromJson(
        Map<String, dynamic> json) =>
    GenerateCreditRequirements(
      imageRequiredCredits: (json['per_image_required_credit'] as num).toInt(),
      realtimeImageRequiredCredits:
          (json['per_realtime_image_required_credit'] as num).toInt(),
      videoRequiredCredits: (json['per_video_required_credit'] as num).toInt(),
      videoTemplateRequiredCredits:
          (json['per_template_required_credit'] as num).toInt(),
    );

Map<String, dynamic> _$GenerateCreditRequirementsToJson(
        GenerateCreditRequirements instance) =>
    <String, dynamic>{
      'per_image_required_credit': instance.imageRequiredCredits,
      'per_realtime_image_required_credit':
          instance.realtimeImageRequiredCredits,
      'per_video_required_credit': instance.videoRequiredCredits,
      'per_template_required_credit': instance.videoTemplateRequiredCredits,
    };
