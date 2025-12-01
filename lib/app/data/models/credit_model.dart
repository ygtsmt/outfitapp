import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'credit_model.g.dart';

@JsonSerializable()
class GenerateCreditRequirements extends Equatable {
  const GenerateCreditRequirements({
    required this.imageRequiredCredits,
    required this.realtimeImageRequiredCredits,
    required this.videoRequiredCredits,
    required this.videoTemplateRequiredCredits,
  });

  @JsonKey(name: 'per_image_required_credit')
  final int imageRequiredCredits;

  @JsonKey(name: 'per_realtime_image_required_credit')
  final int realtimeImageRequiredCredits;

  @JsonKey(name: 'per_video_required_credit')
  final int videoRequiredCredits;

  @JsonKey(name: 'per_template_required_credit')
  final int videoTemplateRequiredCredits;

  factory GenerateCreditRequirements.fromJson(Map<String, dynamic> json) =>
      _$GenerateCreditRequirementsFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateCreditRequirementsToJson(this);

  @override
  List<Object?> get props => [
        imageRequiredCredits,
        realtimeImageRequiredCredits,
        videoRequiredCredits,
        videoTemplateRequiredCredits,
      ];
}
