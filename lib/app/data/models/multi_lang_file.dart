import 'package:json_annotation/json_annotation.dart';

part 'multi_lang_file.g.dart';

@JsonSerializable()
class MultilangFile {
  final String? en;
  final String? fr;
  final String? de;
  final String? tr;

  MultilangFile({this.en, this.fr, this.de, this.tr});

  factory MultilangFile.fromJson(Map<String, dynamic> json) =>
      _$MultilangFileFromJson(json);

  Map<String, dynamic> toJson() => _$MultilangFileToJson(this);
}
