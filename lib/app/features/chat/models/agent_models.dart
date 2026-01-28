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

  /// UI'da gösterilecek özet
  String get summary {
    if (error != null) return '❌ $toolName: $error';

    switch (toolName) {
      case 'get_weather':
        final temp = result['temperature'];
        final desc = result['description'];
        return '✅ Hava durumu: $temp°C, $desc';

      case 'search_wardrobe':
        final count = (result['items'] as List?)?.length ?? 0;
        return '✅ Gardırop: $count parça bulundu';

      case 'check_color_harmony':
        final score = result['harmony_score'];
        return '✅ Renk uyumu: $score/10';

      case 'generate_outfit_visual':
        return '✅ Görsel oluşturuldu';

      default:
        return '✅ $toolName tamamlandı';
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

  const AgentResponse({
    required this.finalAnswer,
    required this.steps,
    this.imageUrl,
    this.visualRequestId,
    this.success = true,
  });

  @override
  List<Object?> get props =>
      [finalAnswer, steps, imageUrl, visualRequestId, success];

  /// Toplam süre
  Duration get totalDuration {
    if (steps.isEmpty) return Duration.zero;
    return steps.last.timestamp.difference(steps.first.timestamp);
  }

  /// Kullanılan tool sayısı
  int get toolCount => steps.length;
}
