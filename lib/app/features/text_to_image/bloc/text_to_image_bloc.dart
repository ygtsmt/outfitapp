import 'package:flutter/material.dart';
import 'package:ginfit/app/features/text_to_image/data/text_to_image_usecase.dart';
import 'package:ginfit/core/core.dart';

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'text_to_image_event.dart';
part 'text_to_image_state.dart';

@singleton
class TextToImageBloc extends Bloc<TextToImageEvent, TextToImageState> {
  final TextToImageUsecase generateUseCase;

  TextToImageBloc({
    required this.generateUseCase,
  }) : super(const TextToImageState()) {
    on<GenerateImageForTextToImageFluxFree>((event, emit) async {
      try {
        emit(state.copyWith(status: EventStatus.processing));

        final result = await generateUseCase
            .generateImageForTextToImageFluxFree(event.prompt, event.size);

        if (result != null && result.base64Image.isNotEmpty) {
          emit(state.copyWith(
            status: EventStatus.success,
            textToImagePhotoBase64: result.base64Image,
            textToImagePhotoIsBase64: true,
          ));

          // Image üretildikten sonra Firebase'e kaydet
          await generateUseCase.saveTextToImageToFirebase(result, event.prompt);
        }
      } catch (e) {
        emit(state.copyWith(status: EventStatus.failure));
      }
      emit(state.copyWith(status: EventStatus.idle));
    });
    on<GenerateImageForTextToImageFlux>((event, emit) async {
      try {
        // Text to Image başladı

        emit(state.copyWith(
          textToImageStatus: EventStatus.processing,
          filterErrorMessage: null, // Clear previous filter error
        ));

        final result = await generateUseCase.generateImageForTextToImageFlux(
            event.prompt, event.size);

        if (result != null && result.base64Image.isNotEmpty) {
          emit(state.copyWith(
            textToImageStatus: EventStatus.success,
            textToImagePhotoBase64: result.base64Image,
            textToImagePhotoIsBase64: true,
          ));

          // Text to Image başarılı

          // Image üretildikten sonra Firebase'e kaydet
          await generateUseCase.saveTextToImageToFirebase(result, event.prompt);
        } else if (result == null) {
          // This means 422 filter error occurred
          emit(state.copyWith(
            textToImageStatus: EventStatus.failure,
            filterErrorMessage:
                'To avoid being filtered, please enter your prompt with a different wording',
          ));

          // Text to Image başarısız (filter error)
        }
      } catch (e) {
        emit(state.copyWith(textToImageStatus: EventStatus.failure));

        // Text to Image başarısız
      }
      emit(state.copyWith(textToImageStatus: EventStatus.idle));
    });
  }
}
