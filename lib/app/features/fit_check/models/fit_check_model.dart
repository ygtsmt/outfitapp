import 'package:cloud_firestore/cloud_firestore.dart';

class FitCheckLog {
  final String id;
  final String imageUrl;
  final DateTime createdAt;

  // AI Generated Metadata (for Analytics)
  final Map<String, double>? colorPalette; // e.g. {'black': 0.8, 'white': 0.2}
  final String? overallStyle; // e.g. 'Casual', 'Formal'
  final List<String>? detectedItems; // e.g. ['t-shirt', 'jeans', 'sneakers']
  final String? aiDescription; // Short summary
  final List<String>? suggestions; // Style tips/improvements
  final bool isPublic; // For future social features

  FitCheckLog({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
    this.colorPalette,
    this.overallStyle,
    this.detectedItems,
    this.aiDescription,
    this.suggestions,
    this.isPublic = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'colorPalette': colorPalette,
      'overallStyle': overallStyle,
      'detectedItems': detectedItems,
      'aiDescription': aiDescription,
      'suggestions': suggestions,
      'isPublic': isPublic,
    };
  }

  factory FitCheckLog.fromMap(Map<String, dynamic> map) {
    return FitCheckLog(
      id: map['id'] as String,
      imageUrl: map['imageUrl'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      colorPalette: map['colorPalette'] != null
          ? Map<String, double>.from(map['colorPalette'])
          : null,
      overallStyle: map['overallStyle'] as String?,
      detectedItems: map['detectedItems'] != null
          ? List<String>.from(map['detectedItems'])
          : null,
      aiDescription: map['aiDescription'] as String?,
      suggestions: map['suggestions'] != null
          ? List<String>.from(map['suggestions'])
          : null,
      isPublic: map['isPublic'] as bool? ?? false,
    );
  }
}
