import 'package:json_annotation/json_annotation.dart';

part 'text_to_image_flux_request_model.g.dart';

@JsonSerializable()
class TextToImageFluxRequestModel {
  final String model;
  final String prompt;
  final int width;
  final int height;
  final int steps;
  final int n;
  final int seed;

  @JsonKey(name: 'response_format')
  final String responseFormat;

  const TextToImageFluxRequestModel({
    required this.model,
    required this.prompt,
    required this.width,
    required this.height,
    required this.steps,
    required this.n,
    required this.seed,
    required this.responseFormat,
  });

  factory TextToImageFluxRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TextToImageFluxRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TextToImageFluxRequestModelToJson(this);
}
