// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_generate_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoGenerateResponseModel _$VideoGenerateResponseModelFromJson(
        Map<String, dynamic> json) =>
    VideoGenerateResponseModel(
      id: json['id'] as String?,
      model: json['model'] as String?,
      version: json['version'] as String?,
      input: json['input'] == null
          ? null
          : Input.fromJson(json['input'] as Map<String, dynamic>),
      logs: json['logs'] as String?,
      output: json['output'] as String?,
      dataRemoved: json['data_removed'] as bool?,
      error: json['error'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      startedAt: json['started_at'] as String?,
      completedAt: json['completed_at'] as String?,
      urls: json['urls'] == null
          ? null
          : VideoUrls.fromJson(json['urls'] as Map<String, dynamic>),
      metrics: json['metrics'] == null
          ? null
          : Metrics.fromJson(json['metrics'] as Map<String, dynamic>),
      fromTemplate: json['from_template'] as bool?,
      templateName: json['template_name'] as String?,
      isWasRefund: json['is_was_refund'] as bool?,
      traceId: json['trace_id'] as String?,
      templateId: (json['template_id'] as num?)?.toInt(),
      videoId: (json['video_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VideoGenerateResponseModelToJson(
        VideoGenerateResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'model': instance.model,
      'version': instance.version,
      'input': instance.input,
      'logs': instance.logs,
      'output': instance.output,
      'data_removed': instance.dataRemoved,
      'error': instance.error,
      'status': instance.status,
      'created_at': instance.createdAt,
      'started_at': instance.startedAt,
      'completed_at': instance.completedAt,
      'urls': instance.urls,
      'metrics': instance.metrics,
      'from_template': instance.fromTemplate,
      'template_name': instance.templateName,
      'is_was_refund': instance.isWasRefund,
      'trace_id': instance.traceId,
      'template_id': instance.templateId,
      'video_id': instance.videoId,
    };

Input _$InputFromJson(Map<String, dynamic> json) => Input(
      aspectRatio: json['aspectRatio'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      effect: json['effect'] as String?,
      image: json['image'] as String?,
      lastFrameImage: json['last_frame_image'] as String?,
      motionMode: json['motion_mode'] as String?,
      prompt: json['prompt'] as String?,
      quality: json['quality'] as String?,
      seed: (json['seed'] as num?)?.toInt(),
      style: json['style'] as String?,
    );

Map<String, dynamic> _$InputToJson(Input instance) => <String, dynamic>{
      'aspectRatio': instance.aspectRatio,
      'duration': instance.duration,
      'effect': instance.effect,
      'image': instance.image,
      'last_frame_image': instance.lastFrameImage,
      'motion_mode': instance.motionMode,
      'prompt': instance.prompt,
      'quality': instance.quality,
      'seed': instance.seed,
      'style': instance.style,
    };

VideoUrls _$VideoUrlsFromJson(Map<String, dynamic> json) => VideoUrls(
      cancel: json['cancel'] as String?,
      get: json['get'] as String?,
      stream: json['stream'] as String?,
      web: json['web'] as String?,
    );

Map<String, dynamic> _$VideoUrlsToJson(VideoUrls instance) => <String, dynamic>{
      'cancel': instance.cancel,
      'get': instance.get,
      'stream': instance.stream,
      'web': instance.web,
    };

Metrics _$MetricsFromJson(Map<String, dynamic> json) => Metrics(
      predictTime: (json['predict_time'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MetricsToJson(Metrics instance) => <String, dynamic>{
      'predict_time': instance.predictTime,
    };
