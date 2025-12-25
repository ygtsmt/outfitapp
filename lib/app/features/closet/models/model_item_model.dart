import 'package:cloud_firestore/cloud_firestore.dart';

class ModelItem {
  final String id;
  final String imageUrl;
  final String? name;
  final int? personCount;
  final String? bodyPart;
  final String? gender;
  final String? bodyType;
  final String? pose;
  final String? skinTone;
  final String? aiPrompt; // AI-generated description for outfit generation
  final DateTime createdAt;

  ModelItem({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
    this.name,
    this.personCount,
    this.bodyPart,
    this.gender,
    this.bodyType,
    this.pose,
    this.skinTone,
    this.aiPrompt,
  });

  /// Check if this model has multiple people
  bool get isMultiplePeople => (personCount ?? 1) > 1;

  factory ModelItem.fromMap(Map<String, dynamic> map) {
    String id = map['id'] as String? ??
        DateTime.now().millisecondsSinceEpoch.toString();

    DateTime createdAt;
    if (map['createdAt'] == null) {
      createdAt = DateTime.now();
    } else if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdAt = DateTime.parse(map['createdAt'] as String);
    } else {
      createdAt = DateTime.now();
    }

    return ModelItem(
      id: id,
      imageUrl: map['imageUrl'] as String? ?? '',
      name: map['name'] as String?,
      personCount: map['personCount'] as int?,
      bodyPart: map['bodyPart'] as String?,
      gender: map['gender'] as String?,
      bodyType: map['bodyType'] as String?,
      pose: map['pose'] as String?,
      skinTone: map['skinTone'] as String?,
      aiPrompt: map['aiPrompt'] as String?,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'personCount': personCount,
      'bodyPart': bodyPart,
      'gender': gender,
      'bodyType': bodyType,
      'pose': pose,
      'skinTone': skinTone,
      'aiPrompt': aiPrompt,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ModelItem copyWith({
    String? id,
    String? imageUrl,
    String? name,
    int? personCount,
    String? bodyPart,
    String? gender,
    String? bodyType,
    String? pose,
    String? skinTone,
    String? aiPrompt,
    DateTime? createdAt,
  }) {
    return ModelItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      personCount: personCount ?? this.personCount,
      bodyPart: bodyPart ?? this.bodyPart,
      gender: gender ?? this.gender,
      bodyType: bodyType ?? this.bodyType,
      pose: pose ?? this.pose,
      skinTone: skinTone ?? this.skinTone,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
