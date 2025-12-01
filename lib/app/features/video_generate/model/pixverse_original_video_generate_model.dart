import 'package:json_annotation/json_annotation.dart';

part 'pixverse_original_video_generate_model.g.dart';

/// Pixverse Original API - Video Generate Request Model
@JsonSerializable()
class PixverseOriginalVideoGenerateRequest {
  final int duration;

  @JsonKey(name: 'img_id')
  final int imgId;

  final String model;

  @JsonKey(name: 'motion_mode')
  final String motionMode;

  final String prompt;

  final String quality;

  @JsonKey(name: 'template_id')
  final int templateId;

  final int seed;

  PixverseOriginalVideoGenerateRequest({
    required this.duration,
    required this.imgId,
    required this.model,
    required this.motionMode,
    required this.prompt,
    required this.quality,
    required this.templateId,
    this.seed = 0,
  });

  factory PixverseOriginalVideoGenerateRequest.fromJson(
          Map<String, dynamic> json) =>
      _$PixverseOriginalVideoGenerateRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PixverseOriginalVideoGenerateRequestToJson(this);
}

/// Pixverse Original API - Video Generate Response Model
@JsonSerializable()
class PixverseOriginalVideoGenerateResponse {
  @JsonKey(name: 'ErrCode')
  final int? errCode;

  @JsonKey(name: 'ErrMsg')
  final String? errMsg;

  @JsonKey(name: 'Resp')
  final PixverseVideoGenerateResp? resp;

  PixverseOriginalVideoGenerateResponse({
    this.errCode,
    this.errMsg,
    this.resp,
  });

  factory PixverseOriginalVideoGenerateResponse.fromJson(
          Map<String, dynamic> json) =>
      _$PixverseOriginalVideoGenerateResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PixverseOriginalVideoGenerateResponseToJson(this);
}

@JsonSerializable()
class PixverseVideoGenerateResp {
  @JsonKey(name: 'video_id')
  final int? videoId;

  final int? credits;

  PixverseVideoGenerateResp({
    this.videoId,
    this.credits,
  });

  factory PixverseVideoGenerateResp.fromJson(Map<String, dynamic> json) =>
      _$PixverseVideoGenerateRespFromJson(json);

  Map<String, dynamic> toJson() => _$PixverseVideoGenerateRespToJson(this);
}
