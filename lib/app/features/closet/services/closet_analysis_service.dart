import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

class WardrobeStats {
  final int totalItems;
  final Map<String, int> categoryCount;
  final Map<String, int> colorDistribution;
  final int capsuleScore;

  WardrobeStats({
    required this.totalItems,
    required this.categoryCount,
    required this.colorDistribution,
    this.capsuleScore = 0,
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

      // Calculate Capsule Score
      final capsuleScore = _calculateCapsuleScore(total, categories, colors);

      return WardrobeStats(
        totalItems: total,
        categoryCount: categories,
        colorDistribution: colors,
        capsuleScore: capsuleScore,
      );
    } catch (e) {
      print('Error fetching closet stats: $e');
      return WardrobeStats(
          totalItems: 0,
          categoryCount: {},
          colorDistribution: {},
          capsuleScore: 0);
    }
  }

  int _calculateCapsuleScore(
      int totalItems, Map<String, int> categories, Map<String, int> colors) {
    if (totalItems == 0) return 0;

    double score = 0;

    // 1. Quantity Score (30%)
    // Ideal capsule wardrobe is often cited as 30-50 items per season.
    // >10 and <80 is a "manageable" range.
    if (totalItems >= 20 && totalItems <= 60) {
      score += 30;
    } else if (totalItems > 10 && totalItems <= 100) {
      score += 15;
    }

    // 2. Balance Score (40%)
    // We want a mix, not just 100% one category.
    // Ideal: ~40% Tops, ~30% Bottoms, ~15% Shoes, ~15% Outerwear
    int tops = categories['top'] ?? categories['Top'] ?? 0;
    int bottoms = categories['bottom'] ?? categories['Bottom'] ?? 0;

    // Check basic ratio: Bottoms should be at least half of tops (1:2 ratio minimum)
    if (tops > 0 && bottoms > 0) {
      double ratio = bottoms / tops;
      if (ratio >= 0.4 && ratio <= 1.5) {
        score += 40; // Great balance
      } else if (ratio > 0.1) {
        score += 20; // Needs work
      }
    }

    // 3. Neutrality/Cohesion Score (30%)
    // Check for neutral colors (Black, White, Grey, Beige, Navy, Blue)
    final neutrals = [
      'black',
      'white',
      'grey',
      'gray',
      'beige',
      'navy',
      'blue',
      'brown'
    ];
    int neutralCount = 0;
    colors.forEach((key, value) {
      if (neutrals.contains(key.toLowerCase())) {
        neutralCount += value;
      }
    });

    double neutralRatio = neutralCount / totalItems;
    if (neutralRatio >= 0.5) {
      score += 30; // Highly cohesive
    } else if (neutralRatio >= 0.3) {
      score += 15;
    }

    return score.round().clamp(0, 100);
  }
}
