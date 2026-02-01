part of 'live_stylist_cubit.dart';

enum LiveStylistStatus { initial, connecting, connected, error }

class LiveStylistState extends Equatable {
  final LiveStylistStatus status;
  final String? message; // Status info or Error message
  final List<String> logs; // Conversation history

  const LiveStylistState({
    this.status = LiveStylistStatus.initial,
    this.message,
    this.logs = const [],
  });

  LiveStylistState copyWith({
    LiveStylistStatus? status,
    String? message,
    List<String>? logs,
  }) {
    return LiveStylistState(
      status: status ?? this.status,
      message: message ?? this.message,
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object?> get props => [status, message, logs];
}
