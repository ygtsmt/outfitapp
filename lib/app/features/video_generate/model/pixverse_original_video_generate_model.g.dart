// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pixverse_original_video_generate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PixverseOriginalVideoGenerateRequest
    _$PixverseOriginalVideoGenerateRequestFromJson(Map<String, dynamic> json) =>
        PixverseOriginalVideoGenerateRequest(
          duration: (json['duration'] as num).toInt(),
          imgId: (json['img_id'] as num).toInt(),
          model: json['model'] as String,
          motionMode: json['motion_mode'] as String,
          prompt: json['prompt'] as String,
          quality: json['quality'] as String,
          templateId: (json['template_id'] as num).toInt(),
          seed: (json['seed'] as num?)?.toInt() ?? 0,
        );

Map<String, dynamic> _$PixverseOriginalVideoGenerateRequestToJson(
        PixverseOriginalVideoGenerateRequest instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'img_id': instance.imgId,
      'model': instance.model,
      'motion_mode': instance.motionMode,
      'prompt': instance.prompt,
      'quality': instance.quality,
      'template_id': instance.templateId,
      'seed': instance.seed,
    };

PixverseOriginalVideoGenerateResponse
    _$PixverseOriginalVideoGenerateResponseFromJson(
            Map<String, dynamic> json) =>
        PixverseOriginalVideoGenerateResponse(
          errCode: (json['ErrCode'] as num?)?.toInt(),
          errMsg: json['ErrMsg'] as String?,
          resp: json['Resp'] == null
              ? null
              : PixverseVideoGenerateResp.fromJson(
                  json['Resp'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$PixverseOriginalVideoGenerateResponseToJson(
        PixverseOriginalVideoGenerateResponse instance) =>
    <String, dynamic>{
      'ErrCode': instance.errCode,
      'ErrMsg': instance.errMsg,
      'Resp': instance.resp,
    };

PixverseVideoGenerateResp _$PixverseVideoGenerateRespFromJson(
        Map<String, dynamic> json) =>
    PixverseVideoGenerateResp(
      videoId: (json['video_id'] as num?)?.toInt(),
      credits: (json['credits'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PixverseVideoGenerateRespToJson(
        PixverseVideoGenerateResp instance) =>
    <String, dynamic>{
      'video_id': instance.videoId,
      'credits': instance.credits,
    };
