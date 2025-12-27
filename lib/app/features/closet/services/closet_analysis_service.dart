import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

class ClosetStats {
  final int totalItems;
  final Map<String, int> categoryCount;
  final Map<String, int> colorDistribution;

  ClosetStats({
    required this.totalItems,
    required this.categoryCount,
    required this.colorDistribution,
  });
}

@singleton
class ClosetAnalysisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ClosetStats> getClosetStats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return ClosetStats(
          totalItems: 0, categoryCount: {}, colorDistribution: {});
    }

    try {
      // Corrected: Read from user document, not subcollection
      final docSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (!docSnapshot.exists) {
        return ClosetStats(
            totalItems: 0, categoryCount: {}, colorDistribution: {});
      }

      final data = docSnapshot.data();
      final List<dynamic> closetList = data?['closet'] ?? [];

      int total = closetList.length;
      Map<String, int> categories = {};
      Map<String, int> colors = {};

      for (var item in closetList) {
        final itemMap = Map<String, dynamic>.from(item);

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

      return ClosetStats(
        totalItems: total,
        categoryCount: categories,
        colorDistribution: colors,
      );
    } catch (e) {
      print('Error fetching closet stats: $e');
      return ClosetStats(
          totalItems: 0, categoryCount: {}, colorDistribution: {});
    }
  }
}
