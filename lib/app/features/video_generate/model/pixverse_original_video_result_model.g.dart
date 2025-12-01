// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pixverse_original_video_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PixverseOriginalVideoResultResponse
    _$PixverseOriginalVideoResultResponseFromJson(Map<String, dynamic> json) =>
        PixverseOriginalVideoResultResponse(
          errCode: (json['ErrCode'] as num?)?.toInt(),
          errMsg: json['ErrMsg'] as String?,
          resp: json['Resp'] == null
              ? null
              : PixverseVideoResultResp.fromJson(
                  json['Resp'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$PixverseOriginalVideoResultResponseToJson(
        PixverseOriginalVideoResultResponse instance) =>
    <String, dynamic>{
      'ErrCode': instance.errCode,
      'ErrMsg': instance.errMsg,
      'Resp': instance.resp,
    };

PixverseVideoResultResp _$PixverseVideoResultRespFromJson(
        Map<String, dynamic> json) =>
    PixverseVideoResultResp(
      createTime: json['create_time'] as String?,
      id: (json['id'] as num?)?.toInt(),
      modifyTime: json['modify_time'] as String?,
      negativePrompt: json['negative_prompt'] as String?,
      outputHeight: (json['outputHeight'] as num?)?.toInt(),
      outputWidth: (json['outputWidth'] as num?)?.toInt(),
      prompt: json['prompt'] as String?,
      resolutionRatio: (json['resolution_ratio'] as num?)?.toInt(),
      seed: (json['seed'] as num?)?.toInt(),
      size: (json['size'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      style: json['style'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$PixverseVideoResultRespToJson(
        PixverseVideoResultResp instance) =>
    <String, dynamic>{
      'create_time': instance.createTime,
      'id': instance.id,
      'modify_time': instance.modifyTime,
      'negative_prompt': instance.negativePrompt,
      'outputHeight': instance.outputHeight,
      'outputWidth': instance.outputWidth,
      'prompt': instance.prompt,
      'resolution_ratio': instance.resolutionRatio,
      'seed': instance.seed,
      'size': instance.size,
      'status': instance.status,
      'style': instance.style,
      'url': instance.url,
    };
