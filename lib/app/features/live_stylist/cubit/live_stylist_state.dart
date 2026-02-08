part of 'live_stylist_cubit.dart';

enum LiveStylistStatus {
  initial,
  checkingPermissions,
  permissionsDenied,
  connecting,
  connected,
  error
}

class LiveStylistState extends Equatable {
  final LiveStylistStatus status;
  final String? message; // Status info or Error message
  final List<String> logs; // Conversation history
  final bool isMicMuted;
  final bool isAiSpeaking; // Tracks if AI is currently outputting audio
  final bool isUserSpeaking; // Tracks if user is currently speaking

  // Permissions
  final bool isCameraPermissionGranted;
  final bool isMicPermissionGranted;

  // Thought Signature fields
  final String? currentThought;
  final String? currentToolName;
  final bool hasActiveThought;

  const LiveStylistState({
    this.status = LiveStylistStatus.initial,
    this.message,
    this.logs = const [],
    this.isMicMuted = false,
    this.isAiSpeaking = false,
    this.isUserSpeaking = false,
    this.isCameraPermissionGranted = false,
    this.isMicPermissionGranted = false,
    this.currentThought,
    this.currentToolName,
    this.hasActiveThought = false,
  });

  LiveStylistState copyWith({
    LiveStylistStatus? status,
    String? message,
    List<String>? logs,
    bool? isMicMuted,
    bool? isAiSpeaking,
    bool? isUserSpeaking,
    bool? isCameraPermissionGranted,
    bool? isMicPermissionGranted,
    String? currentThought,
    String? currentToolName,
    bool? hasActiveThought,
  }) {
    return LiveStylistState(
      status: status ?? this.status,
      message: message ?? this.message,
      logs: logs ?? this.logs,
      isMicMuted: isMicMuted ?? this.isMicMuted,
      isAiSpeaking: isAiSpeaking ?? this.isAiSpeaking,
      isUserSpeaking: isUserSpeaking ?? this.isUserSpeaking,
      isCameraPermissionGranted:
          isCameraPermissionGranted ?? this.isCameraPermissionGranted,
      isMicPermissionGranted:
          isMicPermissionGranted ?? this.isMicPermissionGranted,
      currentThought: currentThought ?? this.currentThought,
      currentToolName: currentToolName ?? this.currentToolName,
      hasActiveThought: hasActiveThought ?? this.hasActiveThought,
    );
  }

  @override
  List<Object?> get props => [
        status,
        message,
        logs,
        isMicMuted,
        isAiSpeaking,
        isUserSpeaking,
        isCameraPermissionGranted,
        isMicPermissionGranted,
        currentThought,
        currentToolName,
        hasActiveThought,
      ];
}
