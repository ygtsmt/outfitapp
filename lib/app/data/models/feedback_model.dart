import 'package:json_annotation/json_annotation.dart';

part 'feedback_model.g.dart';

@JsonSerializable()
class FeedbackModel {
  final String userId;
  final String message;
  final DateTime createdAt;
  final String? imageUrl;

  FeedbackModel({
    required this.userId,
    required this.message,
    required this.createdAt,
    this.imageUrl,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$FeedbackModelFromJson(json);

  Map<String, dynamic> toJson() => _$FeedbackModelToJson(this);
}
