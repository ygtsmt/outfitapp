import 'dart:developer';
import 'package:ginly/app/features/closet/data/try_on_usecase.dart';
import 'package:ginly/core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'try_on_event.dart';
part 'try_on_state.dart';

@singleton
class TryOnBloc extends Bloc<TryOnEvent, TryOnState> {
  final TryOnUseCase tryOnUseCase;

  TryOnBloc({
    required this.tryOnUseCase,
  }) : super(const TryOnState()) {
    on<GenerateTryOnEvent>((event, emit) async {
      emit(state.copyWith(generatingTryOnStatus: EventStatus.processing));
      try {
        final result = await tryOnUseCase.generateTryOn(event.imageUrls);

        emit(state.copyWith(
          generatingTryOnStatus: EventStatus.success,
          requestId: result.requestId,
        ));
      } catch (e) {
        log('GenerateTryOnEvent error: $e');
        emit(state.copyWith(
          generatingTryOnStatus: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }
      emit(state.copyWith(generatingTryOnStatus: EventStatus.idle));
    });
  }
}


