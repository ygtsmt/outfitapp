import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

class WardrobeStats {
  final int totalItems;
  final Map<String, int> categoryCount;
  final Map<String, int> colorDistribution;

  WardrobeStats({
    required this.totalItems,
    required this.categoryCount,
    required this.colorDistribution,
  });
}

@singleton
class WardrobeAnalysisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<WardrobeStats> getWardrobeStats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return WardrobeStats(
          totalItems: 0, categoryCount: {}, colorDistribution: {});
    }

    try {
      // Corrected: Read from user document, not subcollection
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('closet')
          .get();

      int total = snapshot.docs.length;
      Map<String, int> categories = {};
      Map<String, int> colors = {};

      for (var doc in snapshot.docs) {
        final itemMap = doc.data();

        // Category Count
        final category = itemMap['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories[category] = (categories[category] ?? 0) + 1;
        }

        // Color Distribution
        final color = itemMap['color'] as String?;
        if (color != null && color.isNotEmpty) {
          // Clean up color string (e.g. "Dark Blue" -> "Blue") if needed
          final mainColor = color.split(' ').last;
          colors[mainColor] = (colors[mainColor] ?? 0) + 1;
        }
      }

      return WardrobeStats(
        totalItems: total,
        categoryCount: categories,
        colorDistribution: colors,
      );
    } catch (e) {
      print('Error fetching closet stats: $e');
      return WardrobeStats(
          totalItems: 0, categoryCount: {}, colorDistribution: {});
    }
  }
}
