part of 'closet_bloc.dart';

class ClosetState extends Equatable {
  final EventStatus? gettingClosetItemsStatus;
  final List<ClosetItem>? closetItems;
  final EventStatus? gettingModelItemsStatus;
  final List<ModelItem>? modelItems;
  final String? errorMessage;

  const ClosetState({
    this.gettingClosetItemsStatus,
    this.closetItems,
    this.gettingModelItemsStatus,
    this.modelItems,
    this.errorMessage,
  });

  ClosetState copyWith({
    EventStatus? gettingClosetItemsStatus,
    List<ClosetItem>? closetItems,
    EventStatus? gettingModelItemsStatus,
    List<ModelItem>? modelItems,
    String? errorMessage,
  }) {
    return ClosetState(
      gettingClosetItemsStatus:
          gettingClosetItemsStatus ?? this.gettingClosetItemsStatus,
      closetItems: closetItems ?? this.closetItems,
      gettingModelItemsStatus:
          gettingModelItemsStatus ?? this.gettingModelItemsStatus,
      modelItems: modelItems ?? this.modelItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        gettingClosetItemsStatus,
        closetItems,
        gettingModelItemsStatus,
        modelItems,
        errorMessage,
      ];
}

