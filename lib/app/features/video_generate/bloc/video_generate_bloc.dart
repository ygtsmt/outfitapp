import 'dart:io';
import 'dart:math' hide log;
import 'dart:developer';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'package:ginfit/app/features/video_generate/data/video_generate_usecase.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_pollo_request_model.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_pixverse_pollo_request_model.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginfit/app/features/fal_ai/data/fal_ai_usecase.dart';
import 'package:ginfit/core/core.dart';

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'video_generate_event.dart';
part 'video_generate_state.dart';

@singleton
class VideoGenerateBloc extends Bloc<VideoGenerateEvent, VideoGenerateState> {
  final VideoGenerateUsecase generateUseCase;
  final FalAiUsecase falAiUsecase;
  VideoGenerateBloc({
    required this.generateUseCase,
    required this.falAiUsecase,
  }) : super(const VideoGenerateState()) {
    on<UpdateRequestModelEvent>((event, emit) {
      emit(state.copyWith(
        requestModel: event.updatedRequestModel,
      ));
    });

    on<ClearImageEvent>((event, emit) {
      final currentRequestModel =
          state.requestModel ?? VideoGeneratePixversePolloRequestInputModel();
      VideoGeneratePixversePolloRequestInputModel updatedRequestModel;

      if (event.isFirstImage) {
        updatedRequestModel = currentRequestModel.copyWith(image: null);

        if (updatedRequestModel.image != null) {
          updatedRequestModel = VideoGeneratePixversePolloRequestInputModel(
            seed: currentRequestModel.seed,
            style: currentRequestModel.style,
            mode: currentRequestModel.mode,
            prompt: currentRequestModel.prompt,
            resolution: currentRequestModel.resolution,
            length: currentRequestModel.length,
            aspectRatio: currentRequestModel.aspectRatio,
            negativePrompt: currentRequestModel.negativePrompt,
            imageTail: currentRequestModel.imageTail,
          );
        }
      } else {
        updatedRequestModel = currentRequestModel.copyWith(imageTail: null);

        if (updatedRequestModel.imageTail != null) {
          updatedRequestModel = VideoGeneratePixversePolloRequestInputModel(
            seed: currentRequestModel.seed,
            image: currentRequestModel.image,
            style: currentRequestModel.style,
            mode: currentRequestModel.mode,
            prompt: currentRequestModel.prompt,
            resolution: currentRequestModel.resolution,
            length: currentRequestModel.length,
            aspectRatio: currentRequestModel.aspectRatio,
            negativePrompt: currentRequestModel.negativePrompt,
          );
        }
      }

      emit(state.copyWith(
        requestModel: updatedRequestModel,
      ));
    });

    on<UploadPhotoEvent>(
      (event, emit) async {
        emit(state.copyWith(
          uploadStatus: EventStatus.processing,
        ));
        try {
          final imageUrl =
              await generateUseCase.uploadUserImage(event.imageFile);
          if (event.isFirstphoto) {
            getIt<VideoGenerateBloc>().add(
              UpdateRequestModelEvent(
                updatedRequestModel: (state.requestModel ??
                        VideoGeneratePixversePolloRequestInputModel())
                    .copyWith(image: imageUrl),
              ),
            );
          } else {
            getIt<VideoGenerateBloc>().add(
              UpdateRequestModelEvent(
                updatedRequestModel: (state.requestModel ??
                        VideoGeneratePixversePolloRequestInputModel())
                    .copyWith(imageTail: imageUrl),
              ),
            );
          }
          emit(state.copyWith(
            uploadStatus: EventStatus.success,
          ));
        } catch (e) {
          emit(state.copyWith(
            uploadStatus: EventStatus.failure,
          ));
        }
        emit(state.copyWith(
          uploadStatus: EventStatus.idle,
        ));
      },
    );

    on<SetKissTypeEvent>((final event, final emit) {
      emit(state.copyWith(kissType: event.kissType));
    });

    on<VideoGeneratePolloEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: EventStatus.processing));

        final result = await generateUseCase
            .videoGeneratePollo(event.videoGeneratePolloRequestInputModel);
        if (result?.id != null) {
          await generateUseCase.addUserVideoPollo(result!);

          // Webhook dinlemeye başla

          emit(state.copyWith(
            status: EventStatus.success,
          ));
        }
      } catch (e) {
        emit(state.copyWith(status: EventStatus.failure));
      }
      emit(state.copyWith(status: EventStatus.idle));
    });

    // CheckPolloStatusEvent handler kaldırıldı - artık webhook kullanılıyor

    on<VideoGeneratePixversePolloEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: EventStatus.processing));

        final result = await generateUseCase.videoGeneratePixversePollo(
            event.videoGeneratePixversePolloRequestInputModel);
        if (result?.id != null) {
          await generateUseCase.addUserVideoPollo(result!);

          // Webhook dinlemeye başla

          emit(state.copyWith(
            status: EventStatus.success,
          ));
        }
      } catch (e) {
        emit(state.copyWith(status: EventStatus.failure));
      }
      emit(state.copyWith(status: EventStatus.idle));
    });

    on<UpdateImageAspectRatioEvent>((event, emit) {
      if (event.isStartImage) {
        emit(state.copyWith(startImageAspectRatio: event.aspectRatio));
      } else {
        emit(state.copyWith(tailImageAspectRatio: event.aspectRatio));
      }
    });

    on<UpdateSettingsEvent>((event, emit) {
      final currentModel =
          state.requestModel ?? VideoGeneratePixversePolloRequestInputModel();

      final updatedModel = currentModel.copyWith(
        resolution: event.resolution,
        length: event.length,
        aspectRatio: event.aspectRatio,
        style: event.style,
        mode: event.mode,
        negativePrompt: event.negativePrompt,
      );

      emit(state.copyWith(requestModel: updatedModel));
    });

    on<PickImageEvent>((event, emit) async {
      print('🚀 PickImageEvent başladı: isStartImage=${event.isStartImage}');
      try {
        emit(state.copyWith(uploadStatus: EventStatus.processing));
        print('📱 State güncellendi: uploadStatus=processing');

        // Cropped file zaten mevcut, direkt upload et
        if (event.croppedFilePath == null) {
          print('❌ Cropped file path null');
          emit(state.copyWith(
            uploadStatus: EventStatus.failure,
            errorMessage: 'Cropped file path is null',
          ));
          return;
        }

        print('🚀 Firebase Storage\'a upload başlıyor...');
        final result =
            await generateUseCase.uploadUserImage(File(event.croppedFilePath!));
        print('📤 Upload sonucu: $result');

        print('✅ Upload başarılı! URL: $result');
        // Request model'i güncelle
        final currentModel =
            state.requestModel ?? VideoGeneratePixversePolloRequestInputModel();
        final updatedModel = event.isStartImage
            ? currentModel.copyWith(image: result)
            : currentModel.copyWith(imageTail: result);

        print('📱 Request model güncelleniyor...');
        emit(state.copyWith(
          requestModel: updatedModel,
          uploadStatus: EventStatus.success,
        ));
        print('🎉 State güncellendi: uploadStatus=success');
      } catch (e) {
        print('💥 Hata oluştu: $e');
        emit(state.copyWith(
          uploadStatus: EventStatus.failure,
          errorMessage: 'Error uploading image: $e',
        ));
      }

      print('🔄 Upload status idle olarak ayarlanıyor');
      emit(state.copyWith(uploadStatus: EventStatus.idle));
    });

    on<GenerateVideoEvent>((event, emit) async {
      final startTime = DateTime.now();

      try {
        emit(state.copyWith(status: EventStatus.processing));

        final currentState = state;
        final hasImage = currentState.requestModel?.image != null;
        final promptText = event.prompt.trim();

        // Text to Video modu için prompt zorunlu
        if (!hasImage && promptText.isEmpty) {
          emit(state.copyWith(
            status: EventStatus.failure,
            errorMessage: 'Please enter video description',
          ));

          // Hata: Prompt eksik

          return;
        }

        // Request model'i oluştur
        final pixverseModel = VideoGeneratePixversePolloRequestInputModel(
          mode: currentState.requestModel?.mode ?? 'normal',
          image: currentState.requestModel?.image,
          prompt: promptText.isNotEmpty ? promptText : null,
          imageTail: currentState.requestModel?.imageTail,
          length: currentState.requestModel?.length ?? 5,
          negativePrompt: currentState.requestModel?.negativePrompt,
          seed: Random().nextInt(1000),
          resolution: currentState.requestModel?.resolution ?? '720p',
          style: currentState.requestModel?.style ?? 'auto',
          aspectRatio: currentState.requestModel?.aspectRatio ?? '16:9',
        );

        VideoGenerateResponseModel? result;

        // Custom AI Models'i AppBloc'tan al
        final appBloc = getIt<AppBloc>();
        final customModels = appBloc.state.customAIModels;

        // Image-to-video
        if (hasImage) {
          final imageToVideoModel = customModels.imageToVideo.toLowerCase();

          if (imageToVideoModel == 'hailuo') {
            log('✅ Using Hailuo for image-to-video');
            result = await falAiUsecase
                .generateFalAiHailuoImageToVideo(pixverseModel);
          } else {
            log('✅ Using Pixverse for image-to-video');
            result =
                await falAiUsecase.generateFalAiImageToVideo(pixverseModel);
          }

          if (result?.id != null) {
            await falAiUsecase.addUserVideo(result!);
          }
        }
        // Text-to-video
        else {
          final textToVideoModel = customModels.textToVideo.toLowerCase();

          if (textToVideoModel == 'hailuo') {
            log('✅ Using Hailuo for text-to-video');
            result = await falAiUsecase
                .generateFalAiHailuoTextToVideo(pixverseModel);
          } else {
            log('✅ Using Pixverse (Pollo) for text-to-video');
            result =
                await generateUseCase.videoGeneratePixversePollo(pixverseModel);
          }

          if (result?.id != null) {
            if (textToVideoModel == 'hailuo') {
              await falAiUsecase.addUserVideo(result!);
            } else {
              await generateUseCase.addUserVideoPollo(result!);
            }
          }
        }

        if (result?.id != null) {
          emit(state.copyWith(status: EventStatus.success));
        } else {
          emit(state.copyWith(
            status: EventStatus.failure,
            errorMessage: 'Failed to generate video',
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          status: EventStatus.failure,
          errorMessage: 'Error generating video: $e',
        ));

        // Video generate hata
      }

      emit(state.copyWith(status: EventStatus.idle));
    });

    on<ResetVideoGenerateFormEvent>((event, emit) {
      // Form'u default değerlerine reset et
      final defaultModel = VideoGeneratePixversePolloRequestInputModel(
        mode: 'normal',
        image: null,
        prompt: null,
        imageTail: null,
        length: 5,
        negativePrompt: null,
        seed: 0,
        resolution: '540p',
        style: 'auto',
        aspectRatio: '1:1',
      );

      emit(state.copyWith(
        requestModel: defaultModel,
        startImageAspectRatio: null,
        tailImageAspectRatio: null,
        errorMessage: null,
      ));
    });

    on<RegenerateVideoEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: EventStatus.processing));

        final originalVideo = event.originalVideo;
        final randomSeed = event.randomSeed;

        if (originalVideo.fromTemplate == true) {
          // Template'den üretildiyse generateTemplateVideo kullan
          print('Regenerating from template with seed: $randomSeed');
          // TODO: Template regenerate logic
          emit(state.copyWith(status: EventStatus.success));
        } else {
          // Custom video ise videoGeneratePixversePollo kullan
          print('Regenerating custom video with seed: $randomSeed');

          // Orijinal video'dan input'ları al
          final input = originalVideo.input;
          if (input != null) {
            // VideoGeneratePixversePolloRequestInputModel oluştur
            final requestModel = VideoGeneratePixversePolloRequestInputModel(
              mode: input.motionMode ?? 'normal',
              image: input.image,
              prompt: input.prompt,
              imageTail: input.lastFrameImage,
              resolution: input.quality ?? '540p',
              length: input.duration ?? 5,
              aspectRatio: input.aspectRatio ?? '1:1',
              style: input.style ?? 'auto',
              seed: randomSeed, // Random seed kullan
            );

            // Video generate et
            final result =
                await generateUseCase.videoGeneratePixversePollo(requestModel);

            if (result != null) {
              // Başarılı
              emit(state.copyWith(status: EventStatus.success));
              print('✅ Video regenerated successfully with seed: $randomSeed');
            } else {
              emit(state.copyWith(
                status: EventStatus.failure,
                errorMessage: 'Failed to regenerate video',
              ));
            }
          } else {
            emit(state.copyWith(
              status: EventStatus.failure,
              errorMessage: 'No input data found for regeneration',
            ));
          }
        }
      } catch (e) {
        print('Error in regenerate: $e');
        emit(state.copyWith(
          status: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    });

    // Webhook ile task'ı dinlemeye başla (artık Firebase Functions'da yapılıyor)

    // Image aspect ratio hesapla
  }
}
