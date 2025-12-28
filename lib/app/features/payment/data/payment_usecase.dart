import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ginfit/core/core.dart';
import 'package:injectable/injectable.dart';

@injectable
class PaymentUsecase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  PaymentUsecase(this.auth, this.storage, {required this.firestore});

  Future<EventStatus> addCreditForRewardedAd({
    required int addingCredit,
  }) async {
    try {
      final userId = auth.currentUser!.uid;
      final userDocRef = firestore.collection('users').doc(userId);
      
      // Günlük limit kontrolü: Maksimum 60 kredi (3 reklam)
      final userDoc = await userDocRef.get();
      final currentDailyAds = userDoc.data()?['profile_info']?['dailyAdsWatched'] ?? 0;
      
      if (currentDailyAds >= 60) {
        debugPrint('⚠️ Daily ad limit reached: $currentDailyAds/60');
        return EventStatus.failure;
      }
      
      // Günlük krediyi artır (maksimum 60'a kadar)
      final newTotal = currentDailyAds + addingCredit;
      final creditToAdd = newTotal > 60 ? (60 - currentDailyAds) : addingCredit;
      
      await userDocRef.update({
        'profile_info.dailyAdsWatched': FieldValue.increment(creditToAdd),
      });

      return EventStatus.success;
    } catch (e) {
      debugPrint('Error use credit: $e');

      return EventStatus.failure;
    }
  }

  Future<EventStatus> claimCreditForRewardedAd() async {
    try {
      final userId = auth.currentUser!.uid;
      final userDocRef = firestore.collection('users').doc(userId);
      // 1. Kredi ekle ve totalAdsWatched artır
      await userDocRef.update({
        'profile_info.totalCredit':
            FieldValue.increment(60), // 30'dan 60'a çıkarıldı
        'profile_info.dailyAdsWatched': FieldValue.increment(
            -60), // 3 reklam (60 kredi) izlendiğinde claim yapılabilir
        'profile_info.totalAdsWatched':
            FieldValue.increment(1), // Toplam claim sayısını artır
        'profile_info.lastClaimTimestamp': Timestamp.now(),
      });

      return EventStatus.success;
    } catch (e) {
      debugPrint('Error use credit: $e');

      return EventStatus.failure;
    }
  }
}
