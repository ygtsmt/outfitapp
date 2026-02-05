import 'package:equatable/equatable.dart';

/// Agent tool modeli
class AgentTool {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;

  const AgentTool({
    required this.name,
    required this.description,
    required this.parameters,
  });
}

/// Agent'ın attığı her adım
class AgentStep extends Equatable {
  final String toolName;
  final Map<String, dynamic> arguments;
  final Map<String, dynamic> result;
  final DateTime timestamp;
  final String? error;

  AgentStep({
    required this.toolName,
    required this.arguments,
    required this.result,
    this.error,
  }) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [toolName, arguments, result, timestamp, error];

  // Serialization
  Map<String, dynamic> toMap() {
    return {
      'toolName': toolName,
      'arguments': arguments,
      'result': result,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'error': error,
    };
  }

  factory AgentStep.fromMap(Map<String, dynamic> map) {
    return AgentStep(
      toolName: map['toolName'] as String,
      arguments: Map<String, dynamic>.from(map['arguments'] ?? {}),
      result: Map<String, dynamic>.from(map['result'] ?? {}),
      error: map['error'] as String?,
    ); // timestamp is set to now() in constructor, or we can add a named param if precise restoration is needed.
    // To keep it simple and consistent with constructor, we let it be now or add a copyWith/param.
    // However, for history display, the exact timestamp of the step might not be critical, but let's be precise if possible.
    // Modified constructor call if we want to support timestamp, but `timestamp` is final and initialized in initializer list.
    // For now, simple restoration is enough.
  }

  /// UI'da gösterilecek özet
  String get summary {
    if (error != null) return '❌ $toolName: $error';

    switch (toolName) {
      case 'get_weather':
        final temp = result['temperature'];
        final desc = result['description'];
        return '✅ Weather: $temp°C, $desc';

      case 'search_wardrobe':
        final count = (result['items'] as List?)?.length ?? 0;
        return '✅ Wardrobe: $count items found';

      case 'check_color_harmony':
        final score = result['harmony_score'];
        return '✅ Color harmony: $score/10';

      case 'generate_outfit_visual':
        return '✅ Visual created';

      default:
        return '✅ $toolName completed';
    }
  }
}

/// Agent'ın final cevabı
class AgentResponse extends Equatable {
  final String finalAnswer;
  final List<AgentStep> steps;
  final String? imageUrl;
  final String? visualRequestId; // NEW: Pending visual request ID
  final bool success;
  final bool requestsLocation; // 📍 Konum izni talebi

  const AgentResponse({
    required this.finalAnswer,
    required this.steps,
    this.imageUrl,
    this.visualRequestId,
    this.success = true,
    this.requestsLocation = false,
  });

  @override
  List<Object?> get props => [
        finalAnswer,
        steps,
        imageUrl,
        visualRequestId,
        success,
        requestsLocation
      ];

  /// Toplam süre
  Duration get totalDuration {
    if (steps.isEmpty) return Duration.zero;
    return steps.last.timestamp.difference(steps.first.timestamp);
  }

  /// Kullanılan tool sayısı
  int get toolCount => steps.length;
}
