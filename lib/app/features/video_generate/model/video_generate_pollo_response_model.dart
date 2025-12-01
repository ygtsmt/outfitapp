import 'package:json_annotation/json_annotation.dart';

part 'video_generate_pollo_response_model.g.dart';

@JsonSerializable()
class VideoGeneratePolloResponseModel {
  final String? code;
  final String? message;
  final PolloData? data;

  VideoGeneratePolloResponseModel({
    this.code,
    this.message,
    this.data,
  });

  factory VideoGeneratePolloResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VideoGeneratePolloResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$VideoGeneratePolloResponseModelToJson(this);

  VideoGeneratePolloResponseModel copyWith({
    String? code,
    String? message,
    PolloData? data,
  }) {
    return VideoGeneratePolloResponseModel(
      code: code ?? this.code,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

@JsonSerializable()
class PolloData {
  final String? taskId;
  final String? status;
  final List<PolloGeneration>? generations;

  PolloData({
    this.taskId,
    this.status,
    this.generations,
  });

  factory PolloData.fromJson(Map<String, dynamic> json) =>
      _$PolloDataFromJson(json);
  Map<String, dynamic> toJson() => _$PolloDataToJson(this);
}

@JsonSerializable()
class PolloGeneration {
  final String? id;
  @JsonKey(name: 'createdDate')
  final String? createdDate;
  @JsonKey(name: 'updatedDate')
  final String? updatedDate;
  final String? status;
  @JsonKey(name: 'failMsg')
  final String? failMsg;
  final String? url;
  @JsonKey(name: 'mediaType')
  final String? mediaType;

  PolloGeneration({
    this.id,
    this.createdDate,
    this.updatedDate,
    this.status,
    this.failMsg,
    this.url,
    this.mediaType,
  });

  factory PolloGeneration.fromJson(Map<String, dynamic> json) =>
      _$PolloGenerationFromJson(json);
  Map<String, dynamic> toJson() => _$PolloGenerationToJson(this);
}
