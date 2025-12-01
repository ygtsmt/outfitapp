import 'package:json_annotation/json_annotation.dart';

part 'report_model.g.dart';

@JsonSerializable()
class ReportModel {
  final String? contentUrlOrBase64;
  final String? description;
  final String userId;
  final String? type; // "video" or "image" or "realtimeImage"
  final bool? isBase64; // URL of the reported content
  final String? prompt; // Image generation prompt
  final String? createdAt; // Report creation timestamp
  final String? contentId; // Unique image identifier
  final String? collectionName; // Unique image identifier
  final String? documentId; // Unique image identifier

  ReportModel({
    this.contentUrlOrBase64,
    this.description,
    required this.userId,
    this.type,
    this.isBase64,
    this.prompt,
    this.createdAt,
    this.contentId,
    this.collectionName,
    this.documentId,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportModelToJson(this);

  ReportModel copyWith({
    String? contentUrlOrBase64,
    String? description,
    String? userId,
    String? type,
    bool? isBase64,
    String? prompt,
    String? createdAt,
    String? contentId,
    String? collectionName,
    String? documentId,
  }) {
    return ReportModel(
      contentUrlOrBase64: contentUrlOrBase64 ?? this.contentUrlOrBase64,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      isBase64: isBase64 ?? this.isBase64,
      prompt: prompt ?? this.prompt,
      createdAt: createdAt ?? this.createdAt,
      contentId: contentId ?? this.contentId,
      collectionName: collectionName ?? this.collectionName,
      documentId: documentId ?? this.documentId,
    );
  }
}
