import 'package:json_annotation/json_annotation.dart';

part 'pollo_webhook_response_model.g.dart';

@JsonSerializable()
class PolloWebhookResponseModel {
  final String? status;
  final String? taskId;
  final List<PolloWebhookGeneration>? generations;

  PolloWebhookResponseModel({
    this.status,
    this.taskId,
    this.generations,
  });

  factory PolloWebhookResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PolloWebhookResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PolloWebhookResponseModelToJson(this);
}

@JsonSerializable()
class PolloWebhookGeneration {
  final String? id;
  final String? url;
  final String? status;
  final String? failMsg;
  final String? mediaType;
  final String? createdDate;
  final String? updatedDate;

  PolloWebhookGeneration({
    this.id,
    this.url,
    this.status,
    this.failMsg,
    this.mediaType,
    this.createdDate,
    this.updatedDate,
  });

  factory PolloWebhookGeneration.fromJson(Map<String, dynamic> json) =>
      _$PolloWebhookGenerationFromJson(json);

  Map<String, dynamic> toJson() => _$PolloWebhookGenerationToJson(this);
}
