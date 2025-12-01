import 'package:json_annotation/json_annotation.dart';

part 'pixverse_original_video_result_model.g.dart';

/// Pixverse Original API - Video Result Response Model
@JsonSerializable()
class PixverseOriginalVideoResultResponse {
  @JsonKey(name: 'ErrCode')
  final int? errCode;

  @JsonKey(name: 'ErrMsg')
  final String? errMsg;

  @JsonKey(name: 'Resp')
  final PixverseVideoResultResp? resp;

  PixverseOriginalVideoResultResponse({
    this.errCode,
    this.errMsg,
    this.resp,
  });

  factory PixverseOriginalVideoResultResponse.fromJson(
          Map<String, dynamic> json) =>
      _$PixverseOriginalVideoResultResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PixverseOriginalVideoResultResponseToJson(this);
}

@JsonSerializable()
class PixverseVideoResultResp {
  @JsonKey(name: 'create_time')
  final String? createTime;

  final int? id;

  @JsonKey(name: 'modify_time')
  final String? modifyTime;

  @JsonKey(name: 'negative_prompt')
  final String? negativePrompt;

  @JsonKey(name: 'outputHeight')
  final int? outputHeight;

  @JsonKey(name: 'outputWidth')
  final int? outputWidth;

  final String? prompt;

  @JsonKey(name: 'resolution_ratio')
  final int? resolutionRatio;

  final int? seed;

  final int? size;

  final int? status; // 0: processing, 1: succeeded, 2: failed

  final String? style;

  final String? url;

  PixverseVideoResultResp({
    this.createTime,
    this.id,
    this.modifyTime,
    this.negativePrompt,
    this.outputHeight,
    this.outputWidth,
    this.prompt,
    this.resolutionRatio,
    this.seed,
    this.size,
    this.status,
    this.style,
    this.url,
  });

  factory PixverseVideoResultResp.fromJson(Map<String, dynamic> json) =>
      _$PixverseVideoResultRespFromJson(json);

  Map<String, dynamic> toJson() => _$PixverseVideoResultRespToJson(this);
}
