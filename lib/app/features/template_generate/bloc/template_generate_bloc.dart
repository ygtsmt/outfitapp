import 'dart:developer';
import 'dart:io';
import 'package:ginfit/app/features/template_generate/data/template_generate_usecase.dart';
import 'package:ginfit/app/features/fal_ai/data/fal_ai_usecase.dart';
import 'package:ginfit/app/features/video_generate/data/video_generate_usecase.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_pixverse_pollo_request_model.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginfit/core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'template_generate_event.dart';
part 'template_generate_state.dart';

@singleton
class TemplateGenerateBloc
    extends Bloc<TemplateGenerateEvent, TemplateGenerateState> {
  final TemplateGenerateUsecase templateUseCase;
  final FalAiUsecase falAiUsecase;
  final VideoGenerateUsecase videoGenerateUsecase;

  TemplateGenerateBloc({
    required this.templateUseCase,
    required this.falAiUsecase,
    required this.videoGenerateUsecase,
  }) : super(const TemplateGenerateState()) {
    on<UploadPhotoForTemplateEvent>(
      (event, emit) async {
        emit(state.copyWith(
          uploadStatus: EventStatus.processing,
          isGenerationStarted: true,
        ));
        try {
          // Upload image
          final imageUrl =
              await templateUseCase.uploadUserImage(event.imageFile);

          // Create video generation request
          final pixverseModel = VideoGeneratePixversePolloRequestInputModel(
            mode: 'normal',
            image: imageUrl,
            prompt: event.prompt,
            negativePrompt: event.negativePrompt,
            length: event.length ?? 5,
            aspectRatio: event.aspectRatio,
            seed: event.seed,
            resolution: event.resolution,
            style: event.style,
            templateName: event.templateName,
            effect: event.effect,
          );

          log('Template Pixverse Model: ${pixverseModel.toJson()}');

          emit(state.copyWith(
            uploadStatus: EventStatus.success,
            uploadedPhotoUrl: imageUrl,
            generateStatus: EventStatus.processing,
          ));

          VideoGenerateResponseModel? result;

          // Check template AI model
          if (event.aiModel == 'falaipixverse4Effect') {
            log('Using Fal AI Pixverse 4.5 (effects) for template generation');
            // Generate video using Fal AI Pixverse 4.5 effects endpoint
            result = await falAiUsecase.generateFalAiVideo(pixverseModel);

            if (result?.id != null) {
              // Save video to Firebase
              await falAiUsecase.addUserVideo(result!);
            }
          } else if (event.aiModel == 'falaipixverse4' ||
              event.aiModel == 'Pixverse4.5') {
            log('Using Fal AI Pixverse 4.5 (image-to-video) for template generation');
            // Generate video using Fal AI Pixverse 4.5 image-to-video endpoint
            result = await falAiUsecase.generateFalAiImageToVideo(pixverseModel,
                fromTemplate: true);

            if (result?.id != null) {
              // Save video to Firebase
              await falAiUsecase.addUserVideo(result!);
            }
          } else if (event.aiModel == 'hailuo' || event.aiModel == 'Hailuo') {
            log('Using Fal AI Hailuo for template generation');
            // Generate video using Fal AI Hailuo endpoint
            result = await falAiUsecase.generateFalAiHailuoImageToVideo(
                pixverseModel,
                fromTemplate: true);

            if (result?.id != null) {
              // Save video to Firebase
              await falAiUsecase.addUserVideo(result!);
            }
          } else if (event.aiModel == 'originalPixverse45') {
            log('Using Pixverse Original API for template generation');

            // Validate prompt
            final promptText = event.prompt?.trim();
            if (promptText == null || promptText.isEmpty) {
              log('❌ Error: Prompt is null or empty');
              throw Exception('Prompt is required for Pixverse Original API');
            }

            log('📝 Prompt: $promptText');
            log('🔢 Template ID: ${event.templateId}');
            log('⏱️ Duration: ${event.length}');
            log('🎨 Motion Mode: ${pixverseModel.mode}');

            // 1. Upload image to Pixverse Original
            final uploadResponse = await videoGenerateUsecase
                .uploadImageToPixverseOriginal(imageUrl);

            if (uploadResponse?.resp?.imgId == null) {
              throw Exception('Failed to upload image to Pixverse Original');
            }

            final imgId = uploadResponse!.resp!.imgId!;
            log('📷 Image uploaded to Pixverse Original with ID: $imgId');

            // 2. Generate video with Pixverse Original
            result = await videoGenerateUsecase.generateVideoPixverseOriginal(
              imgId: imgId,
              templateId: event.templateId ?? 0,
              prompt: promptText,
              duration: event.length ?? 5,
              quality: event.resolution,
              motionMode: pixverseModel.mode ?? 'normal',
              seed: event.seed ?? 0,
              templateName: event.templateName,
            );

            log('🎬 Video Generate Result: $result');
            log('🆔 Result ID: ${result?.id}');
            log('🔗 Result Trace ID: ${result?.traceId}');

            if (result?.id != null && result?.traceId != null) {
              // Save video to Firebase with 'processing' status
              log('💾 Saving video to Firebase with ID: ${result!.id}');
              await templateUseCase.addUserVideo(result);

              // ✅ Firebase Functions will handle polling automatically
              log('✅ Video saved! Firebase Functions will check status every 30 seconds');
            } else {
              log('⚠️ Video generation returned but ID or TraceID is null!');
              log('⚠️ Result: $result');
            }
          } else {
            log('Using Pollo AI for template generation');
            // Generate video using Pollo AI
            result = await templateUseCase.generateTemplateVideo(pixverseModel);

            if (result?.id != null) {
              // Save video to Firebase
              await templateUseCase.addUserVideo(result!);
            }
          }

          if (result?.id != null) {
            emit(state.copyWith(
              generateStatus: EventStatus.success,
              isGenerationStarted: false,
            ));

            // Refresh library videos
          }
        } catch (e) {
          emit(state.copyWith(
            uploadStatus: EventStatus.failure,
            generateStatus: EventStatus.failure,
            isGenerationStarted: false,
            errorMessage: e.toString(),
          ));

          // Reset state only on error
          emit(state.copyWith(
            uploadStatus: EventStatus.idle,
            generateStatus: EventStatus.idle,
          ));
        }
      },
    );
  }
}
