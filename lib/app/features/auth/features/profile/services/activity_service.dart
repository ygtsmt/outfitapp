import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@singleton
class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection References
  CollectionReference<Map<String, dynamic>> _getUserActivityCol(String uid) {
    return _firestore.collection('users').doc(uid).collection('activity');
  }

  /// Logs a daily activity and updates streak
  Future<void> logActivity(String type) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final dateKey = "${today.year}-${today.month}-${today.day}";

    // 1. Log Daily Activity (for Heatmap)
    final dailyDocRef = _getUserActivityCol(uid).doc(dateKey);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(dailyDocRef);

        if (!snapshot.exists) {
          transaction.set(dailyDocRef, {
            'date': Timestamp.fromDate(
                today), // Keep as full timestamp for sorting if needed
            type: 1,
            'total_count': 1,
          });
        } else {
          final data = snapshot.data() ?? {};
          final currentTypeCount = (data[type] as int?) ?? 0;
          final currentTotal = (data['total_count'] as int?) ?? 0;

          transaction.update(dailyDocRef, {
            type: currentTypeCount + 1,
            'total_count': currentTotal + 1,
            'date': Timestamp.fromDate(today),
          });
        }
      });

      // 2. Update Global Counts
      await _incrementTotalStat(uid, type);

      // 3. Update Streak (Optimized)
      await _updateStreak(uid, todayNormalized);
    } catch (e) {
      print("Error logging activity: $e");
    }
  }

  /// Updates streak based on activity date
  Future<void> _updateStreak(String uid, DateTime todayNormalized) async {
    final streakRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('activity');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(streakRef);

      int currentStreak = 0;
      DateTime? lastActiveDate;

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          currentStreak = (data['current_streak'] as int?) ?? 0;
          if (data['last_active_date'] != null) {
            lastActiveDate = (data['last_active_date'] as Timestamp).toDate();
          }
        }
      }

      int newStreak = currentStreak;
      DateTime? lastActiveNormalized;

      if (lastActiveDate != null) {
        lastActiveNormalized = DateTime(
            lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);
      }

      // Logic:
      // If already active today -> No change in streak count (just update time)
      // If active yesterday -> Streak++
      // If active before yesterday -> Streak reset to 1

      if (lastActiveNormalized == todayNormalized) {
        // Already active today, do nothing or just update timestamp
        if (currentStreak == 0) newStreak = 1; // Correction if somehow 0
      } else if (lastActiveNormalized != null &&
          todayNormalized.difference(lastActiveNormalized).inDays == 1) {
        // Consecutive day
        newStreak++;
      } else {
        // Missed a day or first time
        newStreak = 1;
      }

      transaction.set(
          streakRef,
          {
            'current_streak': newStreak,
            'last_active_date': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));
    });
  }

  /// Increments a global counter for the user (e.g., total outfits ever created)
  Future<void> _incrementTotalStat(String uid, String type) async {
    final statsRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc('summary');

    await statsRef.set({
      '${type}_total': FieldValue.increment(1),
      'last_updated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Fetches activity for the heatmap (last N days)
  Future<Map<DateTime, int>> getHeatmapData({int days = 30}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    try {
      final snapshot = await _getUserActivityCol(uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      Map<DateTime, int> heatmap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp?;
        final total = (data['total_count'] as int?) ?? 0;

        if (timestamp != null) {
          final date = timestamp.toDate();
          final normalizedDate = DateTime(date.year, date.month, date.day);
          heatmap[normalizedDate] = total;
        }
      }
      return heatmap;
    } catch (e) {
      print("Error fetching heatmap data: $e");
      return {};
    }
  }

  /// Fetches total stats (Outfits Generated, Fit Checks, etc.)
  Future<Map<String, int>> getUserStats() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {'outfit': 0, 'fit_check': 0};

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('stats')
          .doc('summary')
          .get();
      if (!doc.exists) return {'outfit': 0, 'fit_check': 0};

      final data = doc.data() ?? {};
      return {
        'outfit': (data['outfit_generated_total'] as int?) ?? 0,
        'fit_check': (data['fit_check_completed_total'] as int?) ?? 0,
      };
    } catch (e) {
      return {'outfit': 0, 'fit_check': 0};
    }
  }

  /// Calculates current streak (Optimized)
  /// Reads single doc 'stats/activity'
  Future<int> getCurrentStreak() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('stats')
          .doc('activity')
          .get();

      if (!doc.exists) return 0;

      final data = doc.data();
      if (data == null) return 0;

      final currentStreak = (data['current_streak'] as int?) ?? 0;
      final lastActiveTs = data['last_active_date'] as Timestamp?;

      if (lastActiveTs == null) return 0;

      final lastActiveDate = lastActiveTs.toDate();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastActiveNormalized = DateTime(
          lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);

      // If last active was today or yesterday, streak is valid.
      // If older, effective streak is 0 (though stored might be X, user broke the chain).
      final difference = today.difference(lastActiveNormalized).inDays;

      if (difference <= 1) {
        return currentStreak;
      } else {
        return 0;
      }
    } catch (e) {
      print("Error fetching streak: $e");
      return 0;
    }
  }
}
