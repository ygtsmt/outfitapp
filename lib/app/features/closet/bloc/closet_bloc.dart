import 'dart:developer';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';
import 'package:comby/app/features/closet/models/model_item_model.dart';
import 'package:comby/core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'closet_event.dart';
part 'closet_state.dart';

@singleton
class ClosetBloc extends Bloc<ClosetEvent, ClosetState> {
  final ClosetUseCase closetUseCase;

  ClosetBloc({
    required this.closetUseCase,
  }) : super(const ClosetState()) {
    // ==================== CLOSET EVENTS ====================
    on<GetUserClosetItemsEvent>((event, emit) async {
      emit(state.copyWith(gettingClosetItemsStatus: EventStatus.processing));
      try {
        final result = await closetUseCase.getUserClosetItems();

        // createdAt'e göre sıralama (yeniden eskiye)
        result.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt);
        });

        emit(state.copyWith(
          gettingClosetItemsStatus: EventStatus.success,
          closetItems: result,
        ));
      } catch (e) {
        log('GetUserClosetItemsEvent error: $e');
        emit(state.copyWith(
          gettingClosetItemsStatus: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }
      emit(state.copyWith(gettingClosetItemsStatus: EventStatus.idle));
    });

    on<RefreshClosetItemsEvent>((event, emit) async {
      emit(state.copyWith(gettingClosetItemsStatus: EventStatus.processing));
      try {
        final result = await closetUseCase.getUserClosetItems();

        // createdAt'e göre sıralama (yeniden eskiye)
        result.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt);
        });

        emit(state.copyWith(
          gettingClosetItemsStatus: EventStatus.success,
          closetItems: result,
        ));
      } catch (e) {
        log('RefreshClosetItemsEvent error: $e');
        emit(state.copyWith(
          gettingClosetItemsStatus: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }
      emit(state.copyWith(gettingClosetItemsStatus: EventStatus.idle));
    });

    on<AddClosetItemEvent>((event, emit) async {
      emit(state.copyWith(gettingClosetItemsStatus: EventStatus.processing));
      try {
        final result = await closetUseCase.addClosetItem(event.item);

        if (result == EventStatus.success) {
          // Item eklendikten sonra listeyi yeniden çek
          final items = await closetUseCase.getUserClosetItems();
          items.sort((a, b) {
            return b.createdAt.compareTo(a.createdAt);
          });

          emit(state.copyWith(
            gettingClosetItemsStatus: EventStatus.success,
            closetItems: items,
          ));
        } else {
          emit(state.copyWith(
            gettingClosetItemsStatus: EventStatus.failure,
            errorMessage: 'Failed to add closet item',
          ));
        }
      } catch (e) {
        log('AddClosetItemEvent error: $e');
        emit(state.copyWith(
          gettingClosetItemsStatus: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }
      emit(state.copyWith(gettingClosetItemsStatus: EventStatus.idle));
    });

    on<UpdateClosetItemEvent>((event, emit) async {
      try {
        final result = await closetUseCase.updateClosetItem(event.item);

        if (result == EventStatus.success) {
          // Item güncellendikten sonra listeyi yeniden çek
          final items = await closetUseCase.getUserClosetItems();
          items.sort((a, b) {
            return b.createdAt.compareTo(a.createdAt);
          });

          emit(state.copyWith(
            closetItems: items,
          ));
        } else {
          emit(state.copyWith(
            errorMessage: 'Failed to update closet item',
          ));
        }
      } catch (e) {
        log('UpdateClosetItemEvent error: $e');
        emit(state.copyWith(
          errorMessage: e.toString(),
        ));
      }
    });

    // ==================== MODEL EVENTS ====================
    on<GetUserModelItemsEvent>((event, emit) async {
      emit(state.copyWith(gettingModelItemsStatus: EventStatus.processing));
      try {
        final result = await closetUseCase.getUserModelItems();

        result.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt);
        });

        emit(state.copyWith(
          gettingModelItemsStatus: EventStatus.success,
          modelItems: result,
        ));
      } catch (e) {
        log('GetUserModelItemsEvent error: $e');
        emit(state.copyWith(
          gettingModelItemsStatus: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }
      emit(state.copyWith(gettingModelItemsStatus: EventStatus.idle));
    });

    on<RefreshModelItemsEvent>((event, emit) async {
      emit(state.copyWith(gettingModelItemsStatus: EventStatus.processing));
      try {
        final result = await closetUseCase.getUserModelItems();

        result.sort((a, b) {
          return b.createdAt.compareTo(a.createdAt);
        });

        emit(state.copyWith(
          gettingModelItemsStatus: EventStatus.success,
          modelItems: result,
        ));
      } catch (e) {
        log('RefreshModelItemsEvent error: $e');
        emit(state.copyWith(
          gettingModelItemsStatus: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }
      emit(state.copyWith(gettingModelItemsStatus: EventStatus.idle));
    });

    on<AddModelItemEvent>((event, emit) async {
      emit(state.copyWith(gettingModelItemsStatus: EventStatus.processing));
      try {
        final result = await closetUseCase.addModelItem(event.item);

        if (result == EventStatus.success) {
          final items = await closetUseCase.getUserModelItems();
          items.sort((a, b) {
            return b.createdAt.compareTo(a.createdAt);
          });

          emit(state.copyWith(
            gettingModelItemsStatus: EventStatus.success,
            modelItems: items,
          ));
        } else {
          emit(state.copyWith(
            gettingModelItemsStatus: EventStatus.failure,
            errorMessage: 'Failed to add model item',
          ));
        }
      } catch (e) {
        log('AddModelItemEvent error: $e');
        emit(state.copyWith(
          gettingModelItemsStatus: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }
      emit(state.copyWith(gettingModelItemsStatus: EventStatus.idle));
    });

    on<DeleteModelItemEvent>((event, emit) async {
      emit(state.copyWith(gettingModelItemsStatus: EventStatus.processing));
      try {
        final result = await closetUseCase.deleteModelItem(event.itemId);

        if (result == EventStatus.success) {
          final items = await closetUseCase.getUserModelItems();
          items.sort((a, b) {
            return b.createdAt.compareTo(a.createdAt);
          });

          emit(state.copyWith(
            gettingModelItemsStatus: EventStatus.success,
            modelItems: items,
          ));
        } else {
          emit(state.copyWith(
            gettingModelItemsStatus: EventStatus.failure,
            errorMessage: 'Failed to delete model item',
          ));
        }
      } catch (e) {
        log('DeleteModelItemEvent error: $e');
        emit(state.copyWith(
          gettingModelItemsStatus: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }
      emit(state.copyWith(gettingModelItemsStatus: EventStatus.idle));
    });
  }
}
