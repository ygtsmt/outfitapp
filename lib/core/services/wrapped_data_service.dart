import 'package:injectable/injectable.dart';
import 'package:comby/app/features/closet/data/closet_usecase.dart';
import 'package:comby/app/features/chat/data/chat_repository.dart';
import 'package:comby/app/features/auth/features/profile/services/activity_service.dart';
import 'package:comby/app/features/closet/services/closet_analysis_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to collect comprehensive user data for Style Wrapped analysis.
/// Leverages existing application services to ensure high-quality data.
@injectable
class WrappedDataService {
  final ClosetUseCase _closetUseCase;
  final ChatRepository _chatRepository;
  final ActivityService _activityService;
  final WardrobeAnalysisService _wardrobeAnalysisService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  WrappedDataService(
    this._closetUseCase,
    this._chatRepository,
    this._activityService,
    this._wardrobeAnalysisService,
  );

  /// Collect all user data using professional service patterns.
  Future<Map<String, dynamic>> collectUserData() async {
    print('📊 Starting comprehensive data collection for Style Wrapped...');

    // Collect data in parallel for performance
    final results = await Future.wait([
      _closetUseCase.getUserClosetItems(),
      _closetUseCase.getUserModelItems(),
      _chatRepository.getSessions(),
      _activityService.getUserStats(),
      _activityService.getCurrentStreak(),
      _activityService.getHeatmapData(days: 365), // Full year heatmap
      _wardrobeAnalysisService.getWardrobeStats(),
    ]);

    final closetItems = results[0] as List;
    final modelItems = results[1] as List;
    final chatSessions = results[2] as List;
    final userStats = results[3] as Map<String, int>;
    final currentStreak = results[4] as int;
    final heatmapData = results[5] as Map<DateTime, int>;
    final wardrobeStats = results[6] as WardrobeStats;

    // Build rich data structure
    final Map<String, dynamic> fullData = {
      'metadata': {
        'collectedAt': DateTime.now().toIso8601String(),
        'userId': _closetUseCase.auth.currentUser?.uid,
      },
      'wardrobe': {
        'totalItems': closetItems.length,
        'items': closetItems.map((item) => item.toMap()).toList(),
        'analyzedStats': {
          'categoryCount': wardrobeStats.categoryCount,
          'colorDistribution': wardrobeStats.colorDistribution,
          'capsuleScore': wardrobeStats.capsuleScore,
        },
      },
      'models': {
        'totalModels': modelItems.length,
        'models': modelItems.map((model) => model.toMap()).toList(),
      },
      'activity': {
        'overallStats': userStats,
        'currentStreak': currentStreak,
        'activityHeatmap':
            heatmapData.map((k, v) => MapEntry(k.toIso8601String(), v)),
      },
      'interactions': {
        'totalChatSessions': chatSessions.length,
        'sessions': chatSessions.map((session) => session.toMap()).toList(),
      },
    };

    // Estimate tokens
    final totalTokens = _estimateTokens(fullData);
    fullData['estimatedTokens'] = totalTokens;

    print('✅ Data collection complete. Final estimated tokens: $totalTokens');
    return fullData;
  }

  int _estimateTokens(Map<String, dynamic> data) {
    // 1M token context allows for very rich data, but we still track it.
    final jsonString = data.toString();
    return (jsonString.length / 4).round();
  }

  /// Save the generated wrapped result to Firestore
  Future<void> saveWrappedResult(Map<String, dynamic> result, int year) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('wrapped')
          .doc(year.toString())
          .set({
        ...result,
        'createdAt': FieldValue.serverTimestamp(),
        'year': year,
      });
      print('✅ Wrapped result saved for year $year');
    } catch (e) {
      print('❌ Error saving wrapped result: $e');
    }
  }

  /// Check if wrapped exists for a specific year
  Future<bool> hasWrappedForYear(int year) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('wrapped')
          .doc(year.toString())
          .get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking wrapped existence: $e');
      return false;
    }
  }

  /// Get the wrapped result for a specific year
  Future<Map<String, dynamic>?> getWrappedResult(int year) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('wrapped')
          .doc(year.toString())
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting wrapped result: $e');
      return null;
    }
  }
}
