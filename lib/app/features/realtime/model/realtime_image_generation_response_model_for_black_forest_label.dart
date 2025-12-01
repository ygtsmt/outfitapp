import 'package:json_annotation/json_annotation.dart';

part 'realtime_image_generation_response_model_for_black_forest_label.g.dart';

@JsonSerializable()
class RealtimeImageGenerationResponseModelForBlackForest {
  final String? id;
  final String? model;
  final String? version;
  final Map<String, dynamic>? input;
  final List<String>? output;
  final String? status;
  final bool? isDeleted;
  final bool? isRealtimeImage;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  RealtimeImageGenerationResponseModelForBlackForest({
    this.id,
    this.model,
    this.version,
    this.input,
    this.output,
    this.status,
    this.createdAt,
    this.isDeleted,
    this.isRealtimeImage,
  });

  factory RealtimeImageGenerationResponseModelForBlackForest.fromJson(
          Map<String, dynamic> json) =>
      _$RealtimeImageGenerationResponseModelForBlackForestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$RealtimeImageGenerationResponseModelForBlackForestToJson(this);

  /// 🆕 Manual copyWith metodu
  RealtimeImageGenerationResponseModelForBlackForest copyWith({
    String? id,
    String? model,
    String? version,
    Map<String, dynamic>? input,
    List<String>? output,
    String? status,
    bool? isDeleted,
    bool? isRealtimeImage,
    String? createdAt,
  }) {
    return RealtimeImageGenerationResponseModelForBlackForest(
      id: id ?? this.id,
      model: model ?? this.model,
      version: version ?? this.version,
      input: input ?? this.input,
      output: output ?? this.output,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      isRealtimeImage: isRealtimeImage ?? this.isRealtimeImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
