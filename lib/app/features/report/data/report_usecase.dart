import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ginly/app/features/auth/features/profile/data/models/report_model.dart';
import 'package:ginly/core/core.dart';
import 'package:injectable/injectable.dart';

@injectable
class ReportUsecase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ReportUsecase(this.auth, {required this.firestore});

  Future<EventStatus> submitReport(ReportModel report) async {
    try {
      final userId = auth.currentUser!.uid;
      debugPrint('Submitting report for user: $userId');
      debugPrint('Report type: ${report.type}');
      debugPrint('Report data: ${report.toJson()}');

      // Report type'a göre collection ve document belirle
      String collectionName;
      String documentId;

      switch (report.type) {
        case 'video':
          collectionName = 'reports';
          documentId = 'video_reports';
          break;
        case 'image':
        case 'textToImage':
          collectionName = 'reports';
          documentId = 'image_reports';
          break;
        case 'realtimeImage':
          collectionName = 'reports';
          documentId = 'realtime_image_reports';
          break;
        default:
          collectionName = 'reports';
          documentId = 'general_reports';
      }

      final reportDocRef = firestore.collection(collectionName).doc(documentId);

      // Report'a ek bilgiler ekle
      final enhancedReport = report.copyWith(
        userId: userId,
        createdAt: DateTime.now().toIso8601String(),
      );

      // Mevcut user reports'ı al
      final docSnapshot = await reportDocRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final Map<String, dynamic> userReports =
            Map<String, dynamic>.from(data ?? {});

        // User ID'ye göre reports listesi oluştur veya güncelle
        if (userReports.containsKey(userId)) {
          final List<dynamic> existingReports =
              List<dynamic>.from(userReports[userId]);
          existingReports.add(enhancedReport.toJson());
          userReports[userId] = existingReports;
        } else {
          userReports[userId] = [enhancedReport.toJson()];
        }

        // Güncellenmiş reports'ı kaydet
        await reportDocRef.set(userReports);
      } else {
        // İlk report ise yeni doc oluştur
        await reportDocRef.set({
          userId: [enhancedReport.toJson()]
        });
      }

      debugPrint('Report successfully saved to Firebase!');
      return EventStatus.success;
    } catch (e) {
      debugPrint('Error saving report: $e');
      return EventStatus.failure;
    }
  }
}
