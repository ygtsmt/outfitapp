import 'package:ginly/app/data/models/multi_lang_file.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_document_model.g.dart';

@JsonSerializable()
class AppDocumentModel {
  @JsonKey(name: 'privacyPolicy')
  final MultilangFile? privacyPolicy;

  @JsonKey(name: 'refund-policy')
  final MultilangFile? refundPolicy;

  final MultilangFile? termsAndConditions;

  AppDocumentModel({
    this.privacyPolicy,
    this.refundPolicy,
    this.termsAndConditions,
  });

  factory AppDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$AppDocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppDocumentModelToJson(this);
}
