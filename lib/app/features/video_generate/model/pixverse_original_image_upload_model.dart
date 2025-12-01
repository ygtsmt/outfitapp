import 'package:json_annotation/json_annotation.dart';

part 'pixverse_original_image_upload_model.g.dart';

/// Pixverse Original API - Image Upload Request Model
@JsonSerializable()
class PixverseOriginalImageUploadRequest {
  final String? imageUrl;

  PixverseOriginalImageUploadRequest({
    this.imageUrl,
  });

  factory PixverseOriginalImageUploadRequest.fromJson(
          Map<String, dynamic> json) =>
      _$PixverseOriginalImageUploadRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PixverseOriginalImageUploadRequestToJson(this);
}

/// Pixverse Original API - Image Upload Response Model
@JsonSerializable()
class PixverseOriginalImageUploadResponse {
  @JsonKey(name: 'ErrCode')
  final int? errCode;

  @JsonKey(name: 'ErrMsg')
  final String? errMsg;

  @JsonKey(name: 'Resp')
  final PixverseImageUploadResp? resp;

  PixverseOriginalImageUploadResponse({
    this.errCode,
    this.errMsg,
    this.resp,
  });

  factory PixverseOriginalImageUploadResponse.fromJson(
          Map<String, dynamic> json) =>
      _$PixverseOriginalImageUploadResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PixverseOriginalImageUploadResponseToJson(this);
}

@JsonSerializable()
class PixverseImageUploadResp {
  @JsonKey(name: 'img_id')
  final int? imgId;

  @JsonKey(name: 'img_url')
  final String? imgUrl;

  PixverseImageUploadResp({
    this.imgId,
    this.imgUrl,
  });

  factory PixverseImageUploadResp.fromJson(Map<String, dynamic> json) =>
      _$PixverseImageUploadRespFromJson(json);

  Map<String, dynamic> toJson() => _$PixverseImageUploadRespToJson(this);
}
