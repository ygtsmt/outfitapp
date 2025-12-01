import 'package:json_annotation/json_annotation.dart';

part 'video_generate_response_model.g.dart';

@JsonSerializable()
class VideoGenerateResponseModel {
  final String? id;
  final String? model;
  final String? version;
  final Input? input;
  final String? logs;
  final String? output;
  @JsonKey(name: 'data_removed')
  final bool? dataRemoved;
  final String? error;
  final String? status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'started_at')
  final String? startedAt;
  @JsonKey(name: 'completed_at')
  final String? completedAt;
  final VideoUrls? urls;
  final Metrics? metrics;
  @JsonKey(name: 'from_template')
  final bool? fromTemplate;
  @JsonKey(name: 'template_name')
  final String? templateName;
  @JsonKey(name: 'is_was_refund')
  final bool? isWasRefund;
  @JsonKey(name: 'trace_id')
  final String? traceId;
  @JsonKey(name: 'template_id')
  final int? templateId;
  @JsonKey(name: 'video_id')
  final int? videoId;

  VideoGenerateResponseModel({
    this.id,
    this.model,
    this.version,
    this.input,
    this.logs,
    this.output,
    this.dataRemoved,
    this.error,
    this.status,
    this.createdAt,
    this.startedAt,
    this.completedAt,
    this.urls,
    this.metrics,
    this.fromTemplate,
    this.templateName,
    this.isWasRefund,
    this.traceId,
    this.templateId,
    this.videoId,
  });

  factory VideoGenerateResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VideoGenerateResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoGenerateResponseModelToJson(this);
  VideoGenerateResponseModel copyWith({
    String? id,
    String? model,
    String? version,
    Input? input,
    String? logs,
    String? output,
    bool? dataRemoved,
    String? error,
    String? status,
    String? createdAt,
    String? startedAt,
    String? completedAt,
    VideoUrls? urls,
    Metrics? metrics,
    bool? fromTemplate,
    String? templateName,
    bool? isWasRefund,
    String? traceId,
    int? templateId,
    int? videoId,
  }) {
    return VideoGenerateResponseModel(
      id: id ?? this.id,
      model: model ?? this.model,
      version: version ?? this.version,
      input: input ?? this.input,
      logs: logs ?? this.logs,
      output: output ?? this.output,
      dataRemoved: dataRemoved ?? this.dataRemoved,
      error: error ?? this.error,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      urls: urls ?? this.urls,
      metrics: metrics ?? this.metrics,
      fromTemplate: fromTemplate ?? this.fromTemplate,
      templateName: templateName ?? this.templateName,
      isWasRefund: isWasRefund ?? this.isWasRefund,
      traceId: traceId ?? this.traceId,
      templateId: templateId ?? this.templateId,
      videoId: videoId ?? this.videoId,
    );
  }
}

@JsonSerializable()
class Input {
  final String? aspectRatio;
  final int? duration;
  final String? effect;
  final String? image;
  @JsonKey(name: 'last_frame_image')
  final String? lastFrameImage;
  @JsonKey(name: 'motion_mode')
  final String? motionMode;
  final String? prompt;
  final String? quality;
  final int? seed;
  final String? style;

  Input({
    this.aspectRatio,
    this.duration,
    this.effect,
    this.image,
    this.lastFrameImage,
    this.motionMode,
    this.prompt,
    this.quality,
    this.seed,
    this.style,
  });

  factory Input.fromJson(Map<String, dynamic> json) => _$InputFromJson(json);
  Map<String, dynamic> toJson() => _$InputToJson(this);
}

@JsonSerializable()
class VideoUrls {
  final String? cancel;
  final String? get;
  final String? stream;
  final String? web;

  VideoUrls({
    this.cancel,
    this.get,
    this.stream,
    this.web,
  });

  factory VideoUrls.fromJson(Map<String, dynamic> json) =>
      _$VideoUrlsFromJson(json);
  Map<String, dynamic> toJson() => _$VideoUrlsToJson(this);
}

@JsonSerializable()
class Metrics {
  @JsonKey(name: 'predict_time')
  final double? predictTime;

  Metrics({this.predictTime});

  factory Metrics.fromJson(Map<String, dynamic> json) =>
      _$MetricsFromJson(json);
  Map<String, dynamic> toJson() => _$MetricsToJson(this);
}
