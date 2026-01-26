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
          // Use full color name with normalization
          final normalizedColor = color.toLowerCase().trim();
          final count = colors[normalizedColor] ?? 0;
          colors[normalizedColor] =
              isAdd ? count + 1 : (count > 0 ? count - 1 : 0);
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
          // Use full color name with normalization
          final normalizedColor = color.toLowerCase().trim();
          colors[normalizedColor] = (colors[normalizedColor] ?? 0) + 1;
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

  /// Calculate capsule wardrobe score (0-100)
  /// Components:
  /// 1. Quantity Score (25%)
  /// 2. Balance Score (20%)
  /// 3. Color Harmony (20%)
  /// 4. Versatility Score (25%)
  /// 5. Essential Items (10%)
  int _calculateCapsuleScore(
      int totalItems, Map<String, int> categories, Map<String, int> colors) {
    if (totalItems == 0) return 0;

    double score = 0;

    // 1. Quantity Score (25%) - STRICTER
    score += _calculateQuantityScore(totalItems);

    // 2. Balance Score (20%)
    score += _calculateBalanceScore(categories);

    // 3. Color Harmony (20%) - NEW
    score += _calculateColorHarmony(totalItems, colors);

    // 4. Versatility Score (25%) - NEW (simplified for now)
    score += _calculateVersatilityScore(totalItems, colors);

    // 5. Essential Items (10%) - NEW
    score += _checkEssentialItems(categories, colors);

    return score.round().clamp(0, 100);
  }

  /// 1. Quantity Score (25%)
  double _calculateQuantityScore(int total) {
    if (total >= 30 && total <= 50) return 25.0; // Sweet spot
    if (total >= 20 && total < 30) return 15.0; // Getting there
    if (total >= 51 && total <= 70) return 15.0;
    if (total >= 15 && total < 20) return 8.0; // Too small
    if (total >= 71 && total <= 100) return 8.0;
    return 0.0; // Too small (<15) or too large (>100)
  }

  /// 2. Balance Score (20%)
  double _calculateBalanceScore(Map<String, int> categories) {
    double score = 0;

    // Top/Bottom balance (10pts)
    int tops = (categories['top'] ?? 0) + (categories['Top'] ?? 0);
    int bottoms = (categories['bottom'] ?? 0) + (categories['Bottom'] ?? 0);

    if (tops > 0 && bottoms > 0) {
      double ratio = bottoms / tops;
      if (ratio >= 0.5 && ratio <= 1.5) {
        score += 10.0;
      } else if (ratio >= 0.3 && ratio <= 2.0) {
        score += 5.0;
      }
    }

    // Category diversity (10pts)
    int shoes = (categories['shoes'] ?? 0) + (categories['Shoes'] ?? 0);
    int outerwear =
        (categories['outerwear'] ?? 0) + (categories['Outerwear'] ?? 0);

    if (shoes > 0) score += 5.0;
    if (outerwear > 0) score += 5.0;

    return score;
  }

  /// 3. Color Harmony (20%) - NEW
  double _calculateColorHarmony(int totalItems, Map<String, int> colors) {
    double score = 0;

    // Count neutrals
    final neutrals = [
      'black',
      'white',
      'grey',
      'gray',
      'beige',
      'navy',
      'blue',
      'brown',
      'cream'
    ];

    int neutralCount = 0;
    colors.forEach((key, value) {
      if (neutrals.any((n) => key.toLowerCase().contains(n))) {
        neutralCount += value;
      }
    });

    double neutralRatio = neutralCount / totalItems;
    int colorCount = colors.length;

    // Ideal: 60%+ neutrals, <=5 colors
    if (neutralRatio >= 0.6 && colorCount <= 5) {
      score = 20.0;
    }
    // Good: 50%+ neutrals, <=7 colors
    else if (neutralRatio >= 0.5 && colorCount <= 7) {
      score = 15.0;
    }
    // OK: 40%+ neutrals, <=10 colors
    else if (neutralRatio >= 0.4 && colorCount <= 10) {
      score = 10.0;
    }
    // Needs work
    else if (neutralRatio >= 0.3) {
      score = 5.0;
    }

    return score;
  }

  /// 4. Versatility Score (25%) - NEW
  /// Simplified: Based on color cohesion and neutral base
  double _calculateVersatilityScore(int totalItems, Map<String, int> colors) {
    double score = 0;

    // More neutrals = higher versatility (items match better)
    final neutrals = [
      'black',
      'white',
      'grey',
      'gray',
      'beige',
      'navy',
      'blue',
      'brown',
      'cream'
    ];

    int neutralCount = 0;
    colors.forEach((key, value) {
      if (neutrals.any((n) => key.toLowerCase().contains(n))) {
        neutralCount += value;
      }
    });

    double neutralRatio = neutralCount / totalItems;

    // High versatility: 70%+ neutral
    if (neutralRatio >= 0.7) {
      score = 25.0;
    }
    // Good: 60%+ neutral
    else if (neutralRatio >= 0.6) {
      score = 20.0;
    }
    // Medium: 50%+ neutral
    else if (neutralRatio >= 0.5) {
      score = 15.0;
    }
    // Low: 40%+ neutral
    else if (neutralRatio >= 0.4) {
      score = 10.0;
    }
    // Very low: <40%
    else {
      score = 5.0;
    }

    return score;
  }

  /// 5. Essential Items Check (10%) - NEW
  double _checkEssentialItems(
      Map<String, int> categories, Map<String, int> colors) {
    double score = 0;
    int found = 0;

    // 1. Has tops (required)
    int tops = (categories['top'] ?? 0) + (categories['Top'] ?? 0);
    if (tops > 0) found++;

    // 2. Has bottoms (required)
    int bottoms = (categories['bottom'] ?? 0) + (categories['Bottom'] ?? 0);
    if (bottoms > 0) found++;

    // 3. Has shoes (required)
    int shoes = (categories['shoes'] ?? 0) + (categories['Shoes'] ?? 0);
    if (shoes > 0) found++;

    // 4. Has neutral colors (required)
    bool hasNeutral = colors.keys.any((color) {
      final lower = color.toLowerCase();
      return lower.contains('black') ||
          lower.contains('white') ||
          lower.contains('grey') ||
          lower.contains('gray') ||
          lower.contains('beige') ||
          lower.contains('navy');
    });
    if (hasNeutral) found++;

    // Score: 2.5 points per essential
    score = (found / 4) * 10.0;

    return score;
  }
}
