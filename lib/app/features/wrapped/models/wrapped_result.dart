/// Models for Style Wrapped feature results
class WrappedResult {
  final YearInNumbers yearInNumbers;
  final StyleEvolution styleEvolution;
  final List<PowerPiece> topPowerPieces;
  final ColorStory colorStory;
  final AIInsights aiInsights;
  final FuturePredict futurePredict;
  final GeminiPowered geminiPowered;

  WrappedResult({
    required this.yearInNumbers,
    required this.styleEvolution,
    required this.topPowerPieces,
    required this.colorStory,
    required this.aiInsights,
    required this.futurePredict,
    required this.geminiPowered,
  });

  factory WrappedResult.fromJson(Map<String, dynamic> json) {
    return WrappedResult(
      yearInNumbers: YearInNumbers.fromJson(json['yearInNumbers'] ?? {}),
      styleEvolution: StyleEvolution.fromJson(json['styleEvolution'] ?? {}),
      topPowerPieces: (json['topPowerPieces'] as List? ?? [])
          .map((e) => PowerPiece.fromJson(e as Map<String, dynamic>))
          .toList(),
      colorStory: ColorStory.fromJson(json['colorStory'] ?? {}),
      aiInsights: AIInsights.fromJson(json['aiInsights'] ?? {}),
      futurePredict: FuturePredict.fromJson(json['futurePredict'] ?? {}),
      geminiPowered: GeminiPowered.fromJson(json['geminiPowered'] ?? {}),
    );
  }
}

class YearInNumbers {
  final int totalItems;
  final int totalOutfits;
  final double totalValue;
  final int daysActive;
  final String headline;

  YearInNumbers({
    required this.totalItems,
    required this.totalOutfits,
    required this.totalValue,
    required this.daysActive,
    required this.headline,
  });

  factory YearInNumbers.fromJson(Map<String, dynamic> json) {
    return YearInNumbers(
      totalItems: _toInt(json['totalItems']),
      totalOutfits: _toInt(json['totalOutfits']),
      totalValue: _toDouble(json['totalValue']),
      daysActive: _toInt(json['daysActive']),
      headline:
          json['headline'] as String? ?? 'Your Fashion Journey in Numbers',
    );
  }
}

class StyleEvolution {
  final String title;
  final String description;
  final List<String> keyMoments;

  StyleEvolution({
    required this.title,
    required this.description,
    required this.keyMoments,
  });

  factory StyleEvolution.fromJson(Map<String, dynamic> json) {
    return StyleEvolution(
      title: json['title'] as String? ?? 'Style Evolution',
      description: json['description'] as String? ?? '',
      keyMoments: List<String>.from(json['keyMoments'] ?? []),
    );
  }
}

class PowerPiece {
  final String id;
  final String name;
  final String reason;
  final String icon;

  PowerPiece({
    required this.id,
    required this.name,
    required this.reason,
    required this.icon,
  });

  factory PowerPiece.fromJson(Map<String, dynamic> json) {
    return PowerPiece(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Mystery Piece',
      reason: json['reason'] as String? ?? 'A staple in your collection.',
      icon: json['icon'] as String? ?? '✨',
    );
  }
}

class ColorStory {
  final List<String> dominantColors;
  final String colorPersonality;
  final List<String> hexCodes;

  ColorStory({
    required this.dominantColors,
    required this.colorPersonality,
    required this.hexCodes,
  });

  factory ColorStory.fromJson(Map<String, dynamic> json) {
    return ColorStory(
      dominantColors: List<String>.from(json['dominantColors'] ?? []),
      colorPersonality:
          json['colorPersonality'] as String? ?? 'Color Enthusiast',
      hexCodes: List<String>.from(json['hexCodes'] ?? []),
    );
  }
}

class AIInsights {
  final String title;
  final List<String> discoveries;

  AIInsights({
    required this.title,
    required this.discoveries,
  });

  factory AIInsights.fromJson(Map<String, dynamic> json) {
    return AIInsights(
      title: json['title'] as String? ?? 'AI Discoveries',
      discoveries: List<String>.from(json['discoveries'] ?? []),
    );
  }
}

class FuturePredict {
  final String title;
  final List<String> predictions;

  FuturePredict({
    required this.title,
    required this.predictions,
  });

  factory FuturePredict.fromJson(Map<String, dynamic> json) {
    return FuturePredict(
      title:
          json['title'] as String? ?? '${DateTime.now().year + 1} Predictions',
      predictions: List<String>.from(json['predictions'] ?? []),
    );
  }
}

class GeminiPowered {
  final String model;
  final int tokensProcessed;
  final String contextWindow;

  GeminiPowered({
    required this.model,
    required this.tokensProcessed,
    required this.contextWindow,
  });

  factory GeminiPowered.fromJson(Map<String, dynamic> json) {
    return GeminiPowered(
      model: json['model'] as String? ?? 'Gemini 3 Flash',
      tokensProcessed: _toInt(json['tokensProcessed']),
      contextWindow: json['contextWindow'] as String? ?? '1M Tokens',
    );
  }
}

// Helper methods for robust type parsing
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
