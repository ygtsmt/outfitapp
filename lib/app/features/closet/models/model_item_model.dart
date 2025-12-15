import 'package:cloud_firestore/cloud_firestore.dart';

class ModelItem {
  final String id;
  final String imageUrl;
  final String? name;
  final DateTime createdAt;

  ModelItem({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
    this.name,
  });

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
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ModelItem copyWith({
    String? id,
    String? imageUrl,
    String? name,
    DateTime? createdAt,
  }) {
    return ModelItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
