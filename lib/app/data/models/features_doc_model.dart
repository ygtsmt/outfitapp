import 'package:json_annotation/json_annotation.dart';

part 'features_doc_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FeaturesDocModel {
  final String id;
  final String? title;
  final String? title_tr;
  final String? title_de;
  final String? title_fr;
  final String? title_ar;
  final String? title_ru;
  final String? title_zh;
  final String? title_es;
  final String? title_hi;
  final String? title_pt;
  final String? title_id;

  // Dinamik key -> List of templates
  final Map<String, List<VideoTemplate>> templates;
  final bool? showOnAppleTemplates;
  final bool? showOnAndroidTemplates;
  final bool? dont_use_doc;

  FeaturesDocModel({
    required this.id,
    this.title,
    this.title_tr,
    this.title_de,
    this.title_fr,
    this.title_ar,
    this.title_ru,
    this.title_zh,
    this.title_es,
    this.title_hi,
    this.title_pt,
    this.title_id,
    required this.templates,
    this.showOnAppleTemplates,
    this.showOnAndroidTemplates,
    this.dont_use_doc,
  });

  factory FeaturesDocModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final title = json['title'] as String?;
    final title_tr = json['title_tr'] as String?;
    final title_de = json['title_de'] as String?;
    final title_fr = json['title_fr'] as String?;
    final title_ar = json['title_ar'] as String?;
    final title_ru = json['title_ru'] as String?;
    final title_zh = json['title_zh'] as String?;
    final title_es = json['title_es'] as String?;
    final title_hi = json['title_hi'] as String?;
    final title_pt = json['title_pt'] as String?;
    final title_id = json['title_id'] as String?;
    final showOnAppleTemplates = json['showOnAppleTemplates'] as bool?;
    final showOnAndroidTemplates = json['showOnAndroidTemplates'] as bool?;
    final dont_use_doc = json['dont_use_doc'] as bool?;

    final Map<String, List<VideoTemplate>> templates = {};

    for (final entry in json.entries) {
      final key = entry.key;

      // 'id' ve 'title' gibi alanları atla
      if (key == 'id' ||
          key == 'title' ||
          key == 'title_tr' ||
          key == 'title_de' ||
          key == 'title_fr' ||
          key == 'title_ar' ||
          key == 'title_ru' ||
          key == 'title_zh' ||
          key == 'title_es' ||
          key == 'title_hi' ||
          key == 'title_pt' ||
          key == 'title_id') {
        continue;
      }

      final value = entry.value;

      try {
        List<VideoTemplate> parsedList;

        if (value is List) {
          parsedList = value
              .map((e) => VideoTemplate.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (value is Map) {
          parsedList = value.values
              .map((e) => VideoTemplate.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          continue;
        }

        // Güvensiz key'leri atla veya temizle
        if (key.trim().isEmpty || key.endsWith('.')) continue;

        // Template'leri rank'a göre sırala (rank null ise en sona koy)
        parsedList.sort((a, b) {
          final rankA = a.rank ?? 999999;
          final rankB = b.rank ?? 999999;
          return rankA.compareTo(rankB);
        });

        templates[key] = parsedList;
      } catch (e) {
        // Parsing hatasını yut
        continue;
      }
    }

    return FeaturesDocModel(
      id: id,
      title: title,
      templates: templates,
      title_tr: title_tr,
      title_de: title_de,
      title_fr: title_fr,
      title_ar: title_ar,
      title_ru: title_ru,
      title_zh: title_zh,
      title_es: title_es,
      title_hi: title_hi,
      title_pt: title_pt,
      title_id: title_id,
      showOnAppleTemplates: showOnAppleTemplates,
      showOnAndroidTemplates: showOnAndroidTemplates,
      dont_use_doc: dont_use_doc,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (title_tr != null) 'title_tr': title_tr,
        if (title_de != null) 'title_de': title_de,
        if (title_fr != null) 'title_fr': title_fr,
        if (title_ar != null) 'title_ar': title_ar,
        if (title_ru != null) 'title_ru': title_ru,
        if (title_zh != null) 'title_zh': title_zh,
        if (title_es != null) 'title_es': title_es,
        if (title_hi != null) 'title_hi': title_hi,
        if (title_pt != null) 'title_pt': title_pt,
        if (title_id != null) 'title_id': title_id,
        if (showOnAppleTemplates != null)
          'showOnAppleTemplates': showOnAppleTemplates,
        if (showOnAndroidTemplates != null)
          'showOnAndroidTemplates': showOnAndroidTemplates,
        if (dont_use_doc != null) 'dont_use_doc': dont_use_doc,
        ...templates.map((key, value) =>
            MapEntry(key, value.map((e) => e.toJson()).toList())),
      };
}

@JsonSerializable()
class VideoTemplate {
  final String id;
  final String? quality;
  final String? label;
  final String? labelTr;
  final String? labelFr;
  final String? labelDe;
  final String? labelAr;
  final String? labelRu;
  final String? labelZh;
  final String? labelEs;
  final String? labelHi;
  final String? labelPt;
  final String? labelId;
  final String? aiModel;
  final String? prompt;
  final String? previewUrl;
  final int? requiredCredit;
  final int? template_id;
  final String? style;
  final bool? isMustSinglePhoto;
  final int? seed;
  final String? title;
  @JsonKey(name: 'title_tr')
  final String? titleTr;
  @JsonKey(name: 'title_de')
  final String? titleDe;
  @JsonKey(name: 'title_fr')
  final String? titleFr;
  @JsonKey(name: 'title_ar')
  final String? titleAr;
  @JsonKey(name: 'title_ru')
  final String? titleRu;
  @JsonKey(name: 'title_zh')
  final String? titleZh;
  @JsonKey(name: 'title_es')
  final String? titleEs;
  @JsonKey(name: 'title_hi')
  final String? titleHi;
  @JsonKey(name: 'title_pt')
  final String? titlePt;
  @JsonKey(name: 'title_id')
  final String? titleId;
  final String? negativePrompt;
  final String? motionMode;
  @JsonKey(name: 'responseType')
  final String? responseType;
  @JsonKey(name: 'aspectRatio')
  final String? aspectRatio;
  final int? duration;
  final String? effect;
  final bool? isTrend;
  final bool? showThisTemplateIOS;
  final bool? showThisTemplateAndroid;
  final int? rank;
  final bool? dont_use_template;
  final String? ticket;
  @JsonKey(name: 'is_premium_template')
  final bool?
      isPremiumTemplate; // Premium template mi? (true ise sadece 1 kere ücretsiz kullanılabilir)

  VideoTemplate({
    required this.id,
    this.quality,
    this.label,
    this.labelTr,
    this.labelFr,
    this.labelDe,
    this.labelAr,
    this.labelRu,
    this.labelZh,
    this.labelEs,
    this.labelHi,
    this.labelPt,
    this.labelId,
    this.aiModel,
    this.prompt,
    this.previewUrl,
    this.requiredCredit,
    this.template_id,
    this.style,
    this.isMustSinglePhoto,
    this.seed,
    this.title,
    this.titleTr,
    this.titleDe,
    this.titleFr,
    this.titleAr,
    this.titleRu,
    this.titleZh,
    this.titleEs,
    this.titleHi,
    this.titlePt,
    this.titleId,
    this.negativePrompt,
    this.motionMode,
    this.responseType,
    this.aspectRatio,
    this.duration,
    this.effect,
    this.isTrend,
    this.showThisTemplateIOS,
    this.showThisTemplateAndroid,
    this.rank,
    this.dont_use_template,
    this.ticket,
    this.isPremiumTemplate,
  });

  factory VideoTemplate.fromJson(Map<String, dynamic> json) =>
      _$VideoTemplateFromJson(json);
  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() => _$VideoTemplateToJson(this);
}
