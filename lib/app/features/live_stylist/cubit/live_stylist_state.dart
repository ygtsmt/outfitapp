part of 'live_stylist_cubit.dart';

enum LiveStylistStatus { initial, connecting, connected, error }

class LiveStylistState extends Equatable {
  final LiveStylistStatus status;
  final String? message; // Status info or Error message
  final List<String> logs; // Conversation history
  final bool isMicMuted;

  const LiveStylistState({
    this.status = LiveStylistStatus.initial,
    this.message,
    this.logs = const [],
    this.isMicMuted = false,
  });

  LiveStylistState copyWith({
    LiveStylistStatus? status,
    String? message,
    List<String>? logs,
    bool? isMicMuted,
  }) {
    return LiveStylistState(
      status: status ?? this.status,
      message: message ?? this.message,
      logs: logs ?? this.logs,
      isMicMuted: isMicMuted ?? this.isMicMuted,
    );
  }

  @override
  List<Object?> get props => [status, message, logs, isMicMuted];
}
