// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pixverse_original_image_upload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PixverseOriginalImageUploadRequest _$PixverseOriginalImageUploadRequestFromJson(
        Map<String, dynamic> json) =>
    PixverseOriginalImageUploadRequest(
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$PixverseOriginalImageUploadRequestToJson(
        PixverseOriginalImageUploadRequest instance) =>
    <String, dynamic>{
      'imageUrl': instance.imageUrl,
    };

PixverseOriginalImageUploadResponse
    _$PixverseOriginalImageUploadResponseFromJson(Map<String, dynamic> json) =>
        PixverseOriginalImageUploadResponse(
          errCode: (json['ErrCode'] as num?)?.toInt(),
          errMsg: json['ErrMsg'] as String?,
          resp: json['Resp'] == null
              ? null
              : PixverseImageUploadResp.fromJson(
                  json['Resp'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$PixverseOriginalImageUploadResponseToJson(
        PixverseOriginalImageUploadResponse instance) =>
    <String, dynamic>{
      'ErrCode': instance.errCode,
      'ErrMsg': instance.errMsg,
      'Resp': instance.resp,
    };

PixverseImageUploadResp _$PixverseImageUploadRespFromJson(
        Map<String, dynamic> json) =>
    PixverseImageUploadResp(
      imgId: (json['img_id'] as num?)?.toInt(),
      imgUrl: json['img_url'] as String?,
    );

Map<String, dynamic> _$PixverseImageUploadRespToJson(
        PixverseImageUploadResp instance) =>
    <String, dynamic>{
      'img_id': instance.imgId,
      'img_url': instance.imgUrl,
    };
