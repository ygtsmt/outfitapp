import 'package:ginly/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'text_to_image_generation_response_model_for_black_forest_label.g.dart';

@JsonSerializable()
class TextToImageImageGenerationResponseModelForBlackForestLabel {
  final String? id;
  final String? model;
  final String? version;
  final Map<String, dynamic>? input;
  final List<String>? output;
  final String? status;
  final bool? isRealtimeImage;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final VideoUrls? urls;
  final bool? isDeleted;
  final String? prompt; // Library'deki data için
  @JsonKey(name: 'createdAt')
  final String? createdAtDirect; // Library'deki data için

  TextToImageImageGenerationResponseModelForBlackForestLabel({
    this.id,
    this.model,
    this.version,
    this.input,
    this.output,
    this.status,
    this.isRealtimeImage,
    this.isDeleted,
    this.createdAt,
    this.urls,
    this.prompt,
    this.createdAtDirect,
  });

  factory TextToImageImageGenerationResponseModelForBlackForestLabel.fromJson(
          Map<String, dynamic> json) =>
      _$TextToImageImageGenerationResponseModelForBlackForestLabelFromJson(
          json);

  Map<String, dynamic> toJson() =>
      _$TextToImageImageGenerationResponseModelForBlackForestLabelToJson(this);

  /// 🆕 Manuel copyWith metodu
  TextToImageImageGenerationResponseModelForBlackForestLabel copyWith({
    String? id,
    String? model,
    String? version,
    Map<String, dynamic>? input,
    List<String>? output,
    String? status,
    bool? isRealtimeImage,
    bool? isDeleted,
    String? createdAt,
    VideoUrls? urls,
    String? prompt,
    String? createdAtDirect,
  }) {
    return TextToImageImageGenerationResponseModelForBlackForestLabel(
      id: id ?? this.id,
      model: model ?? this.model,
      version: version ?? this.version,
      input: input ?? this.input,
      output: output ?? this.output,
      status: status ?? this.status,
      isRealtimeImage: isRealtimeImage ?? false,
      isDeleted: isDeleted ?? false,
      createdAt: createdAt ?? this.createdAt,
      urls: urls ?? this.urls,
      prompt: prompt ?? this.prompt,
      createdAtDirect: createdAtDirect ?? this.createdAtDirect,
    );
  }
}
