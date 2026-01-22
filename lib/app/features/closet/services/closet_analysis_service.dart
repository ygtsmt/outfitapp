import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:comby/app/features/closet/models/wardrobe_item_model.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'totalItems': totalItems,
      'categoryCount': categoryCount,
      'colorDistribution': colorDistribution,
      'capsuleScore': capsuleScore,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  factory WardrobeStats.fromMap(Map<String, dynamic> map) {
    return WardrobeStats(
      totalItems: map['totalItems'] as int? ?? 0,
      categoryCount: Map<String, int>.from(map['categoryCount'] ?? {}),
      colorDistribution: Map<String, int>.from(map['colorDistribution'] ?? {}),
      capsuleScore: map['capsuleScore'] as int? ?? 0,
    );
  }
}

@singleton
class WardrobeAnalysisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // READ (Optimized)
  Future<WardrobeStats> getWardrobeStats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return WardrobeStats(
          totalItems: 0, categoryCount: {}, colorDistribution: {});
    }

    try {
      // 1. Try to read aggregated stats
      final statsDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('wardrobe')
          .get();

      if (statsDoc.exists && statsDoc.data() != null) {
        return WardrobeStats.fromMap(statsDoc.data()!);
      }

      // 2. Fallback: Calculate from scratch and save
      return await recalculateAndSaveStats(userId);
    } catch (e) {
      print('Error fetching closet stats: $e');
      return WardrobeStats(
          totalItems: 0,
          categoryCount: {},
          colorDistribution: {},
          capsuleScore: 0);
    }
  }

  // WRITE (Incremental Update)
  Future<void> updateAggregatedStats(String userId, WardrobeItem item,
      {bool isAdd = true}) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('wardrobe');

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        WardrobeStats currentStats;
        if (snapshot.exists && snapshot.data() != null) {
          currentStats = WardrobeStats.fromMap(snapshot.data()!);
        } else {
          // If doc doesn't exist, we can't reliably increment.
          // Better to trigger a full recalculation in background or just ignore (lazy load will fix it).
          // But let's try to handle it gracefully by not processing.
          return;
        }

        // Update counts
        int newTotal = currentStats.totalItems + (isAdd ? 1 : -1);
        if (newTotal < 0) newTotal = 0;

        final categories = Map<String, int>.from(currentStats.categoryCount);
        final category = item.category;
        if (category != null && category.isNotEmpty) {
          final count = categories[category] ?? 0;
          categories[category] =
              isAdd ? count + 1 : (count > 0 ? count - 1 : 0);
        }

        final colors = Map<String, int>.from(currentStats.colorDistribution);
        final color = item.color;
        if (color != null && color.isNotEmpty) {
          final mainColor = color.split(' ').last;
          final count = colors[mainColor] ?? 0;
          colors[mainColor] = isAdd ? count + 1 : (count > 0 ? count - 1 : 0);
        }

        // Recalculate score with new numbers
        final newScore = _calculateCapsuleScore(newTotal, categories, colors);

        final newStats = WardrobeStats(
          totalItems: newTotal,
          categoryCount: categories,
          colorDistribution: colors,
          capsuleScore: newScore,
        );

        transaction.set(docRef, newStats.toMap());
      });
    } catch (e) {
      print("Error updating aggregated stats: $e");
      // On error, invalidated cache could be a strategy, but for now we just log.
    }
  }

  // WRITE (Full Recalculation)
  Future<WardrobeStats> recalculateAndSaveStats(String userId) async {
    try {
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
          final mainColor = color.split(' ').last;
          colors[mainColor] = (colors[mainColor] ?? 0) + 1;
        }
      }

      final capsuleScore = _calculateCapsuleScore(total, categories, colors);

      final stats = WardrobeStats(
        totalItems: total,
        categoryCount: categories,
        colorDistribution: colors,
        capsuleScore: capsuleScore,
      );

      // Save to stats doc
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('wardrobe')
          .set(stats.toMap());

      return stats;
    } catch (e) {
      print("Error recalculating stats: $e");
      throw e;
    }
  }

  int _calculateCapsuleScore(
      int totalItems, Map<String, int> categories, Map<String, int> colors) {
    if (totalItems == 0) return 0;

    double score = 0;

    // 1. Quantity Score (30%)
    if (totalItems >= 20 && totalItems <= 60) {
      score += 30;
    } else if (totalItems > 10 && totalItems <= 100) {
      score += 15;
    }

    // 2. Balance Score (40%)
    int tops = categories['top'] ?? categories['Top'] ?? 0;
    int bottoms = categories['bottom'] ?? categories['Bottom'] ?? 0;

    if (tops > 0 && bottoms > 0) {
      double ratio = bottoms / tops;
      if (ratio >= 0.4 && ratio <= 1.5) {
        score += 40;
      } else if (ratio > 0.1) {
        score += 20;
      }
    }

    // 3. Neutrality/Cohesion Score (30%)
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
      score += 30;
    } else if (neutralRatio >= 0.3) {
      score += 15;
    }

    return score.round().clamp(0, 100);
  }
}
