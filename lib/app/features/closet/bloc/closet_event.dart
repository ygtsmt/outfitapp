part of 'closet_bloc.dart';

abstract class ClosetEvent extends Equatable {
  const ClosetEvent();

  @override
  List<Object> get props => [];
}

// ==================== CLOSET EVENTS ====================

class GetUserClosetItemsEvent extends ClosetEvent {
  const GetUserClosetItemsEvent();

  @override
  List<Object> get props => [];
}

class RefreshClosetItemsEvent extends ClosetEvent {
  const RefreshClosetItemsEvent();

  @override
  List<Object> get props => [];
}

class AddClosetItemEvent extends ClosetEvent {
  final ClosetItem item;

  const AddClosetItemEvent(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateClosetItemEvent extends ClosetEvent {
  final ClosetItem item;

  const UpdateClosetItemEvent(this.item);

  @override
  List<Object> get props => [item];
}

// ==================== MODEL EVENTS ====================

class GetUserModelItemsEvent extends ClosetEvent {
  const GetUserModelItemsEvent();

  @override
  List<Object> get props => [];
}

class RefreshModelItemsEvent extends ClosetEvent {
  const RefreshModelItemsEvent();

  @override
  List<Object> get props => [];
}

class AddModelItemEvent extends ClosetEvent {
  final ModelItem item;

  const AddModelItemEvent(this.item);

  @override
  List<Object> get props => [item];
}

class DeleteModelItemEvent extends ClosetEvent {
  final String itemId;

  const DeleteModelItemEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}
