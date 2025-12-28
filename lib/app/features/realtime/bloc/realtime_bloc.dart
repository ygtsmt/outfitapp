import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ginfit/app/features/auth/features/profile/data/models/report_model.dart';
import 'package:ginfit/app/features/realtime/data/realtime_usecase.dart';
import 'package:ginfit/core/core.dart';

import 'package:equatable/equatable.dart';
import 'package:ginfit/core/utils.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'realtime_event.dart';
part 'realtime_state.dart';

@singleton
class RealtimeBloc extends Bloc<RealtimeEvent, RealtimeState> {
  final RealtimeUsecase generateUseCase;

  RealtimeBloc({
    required this.generateUseCase,
  }) : super(const RealtimeState()) {
    on<GenerateImageForRealtimeFluxFree>((event, emit) async {
      try {
        emit(state.copyWith(status: EventStatus.processing));

        // Seed logic: if history exists, use previous seed; otherwise generate random seed
        int seedToUse;
        if (state.realtimePhotoBase64LIST != null &&
            state.realtimePhotoBase64LIST!.isNotEmpty) {
          // Use previous seed for consistency
          seedToUse = state.currentSeed ?? Random().nextInt(99999);
        } else {
          // Generate new random seed for first image
          seedToUse = Random().nextInt(99999);
        }

        final result = await generateUseCase
            .generateImageForRealtimeFluxFree(event.prompt, seed: seedToUse);

        if (result != null && result.base64Image.isNotEmpty) {
          emit(state.copyWith(
            status: EventStatus.success,
            realtimePhotoBase64: result.base64Image,
            realtimePhotoIsBase64: true,
            currentSeed: seedToUse, // Store the seed for next generation
          ));
        }
      } catch (e) {
        emit(state.copyWith(status: EventStatus.failure));
      }
      emit(state.copyWith(status: EventStatus.idle));
    });
    on<GenerateImageForRealtimeFlux>((event, emit) async {
      final startTime = DateTime.now();

      try {
        emit(state.copyWith(status: EventStatus.processing));

        // Seed logic: if history exists, use previous seed; otherwise generate random seed
        int seedToUse;
        if (state.realtimePhotoBase64LIST != null &&
            state.realtimePhotoBase64LIST!.isNotEmpty) {
          // Use previous seed for consistency
          seedToUse = state.currentSeed ?? Random().nextInt(99999);
        } else {
          // Generate new random seed for first image
          seedToUse = Random().nextInt(99999);
        }

        final result = await generateUseCase.generateImageForRealtimeFlux(
          event.prompt,
          seed: seedToUse,
        );

        if (result != null && result.base64Image.isNotEmpty) {
          final updatedList =
              List<String>.from(state.realtimePhotoBase64LIST ?? [])
                ..add(result.base64Image);

          emit(state.copyWith(
            status: EventStatus.success,
            realtimePhotoBase64: result.base64Image,
            realtimePhotoIsBase64: true,
            realtimePhotoBase64LIST: updatedList,
            currentSeed: seedToUse, // Store the seed for next generation
          ));

          // Realtime AI başarılı
        }
      } catch (e) {
        emit(state.copyWith(status: EventStatus.failure));

        // Realtime AI hatası
      }

      emit(state.copyWith(status: EventStatus.idle));
    });

    on<SoftDeleteRealtimeImageEvent>((event, emit) async {
      emit(state.copyWith(
        realtimeImageSoftDeleteStatus: EventStatus.processing,
      ));
      try {
        final result = await generateUseCase
            .softDeleteUserGeneratedRealtimeImage(imageId: event.imageId);

        if (result == EventStatus.success) {
          emit(state.copyWith(
            realtimeImageSoftDeleteStatus: EventStatus.success,
          ));
        }
      } catch (e) {
        emit(
            state.copyWith(realtimeImageSoftDeleteStatus: EventStatus.failure));
      }
      emit(state.copyWith(realtimeImageSoftDeleteStatus: EventStatus.idle));
    });
    on<SelectedRealtimeBase64Event>((event, emit) async {
      emit(state.copyWith(realtimePhotoBase64: event.selectedBase64));
    });
  }
}
