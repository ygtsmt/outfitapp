import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:comby/app/data/models/app_document_model.dart';
import 'package:comby/app/data/models/feedback_model.dart';
import 'package:injectable/injectable.dart';
import 'package:comby/core/data_sources/local_data_source/secure_data_storage.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

@injectable
class AppUseCase {
  AppUseCase(this._secureDataStorage, {required this.firestore});

  final SecureDataStorage _secureDataStorage;
  final FirebaseFirestore firestore;

  Future<void> setThemeMode(final ThemeMode themeMode) async {
    await _secureDataStorage.saveThemeMode(themeMode);
  }

  Future<void> setAppLanguage(final Locale locale) async {
    await _secureDataStorage.setAppLanguage(locale);
  }

  Future<AppDocumentModel?> getAppDocuments() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('core')
          .doc('appDocs')
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data();
      return AppDocumentModel.fromJson(data!);
    } catch (e) {
      log('getAppDocuments error: $e');
      return null;
    }
  }

  Future<void> submitFeedback(FeedbackModel feedback) async {
    try {
      // Feedbacks collection'ı altında general_feedbacks doc'u
      final feedbacksDocRef =
          firestore.collection('feedbacks').doc('general_feedbacks');

      // User ID ile liste oluştur
      final feedbackData = feedback.toJson();

      // Mevcut user feedbacks'i al
      final docSnapshot = await feedbacksDocRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final Map<String, dynamic> feedbacks =
            Map<String, dynamic>.from(data ?? {});

        // User ID'ye göre feedbacks listesi oluştur veya güncelle
        if (feedbacks.containsKey(feedback.userId)) {
          final List<dynamic> existingFeedbacks =
              List<dynamic>.from(feedbacks[feedback.userId]);
          existingFeedbacks.add(feedbackData);
          feedbacks[feedback.userId] = existingFeedbacks;
        } else {
          feedbacks[feedback.userId] = [feedbackData];
        }

        // Güncellenmiş feedbacks'i kaydet
        await feedbacksDocRef.set(feedbacks);
      } else {
        // İlk feedback ise yeni doc oluştur
        await feedbacksDocRef.set({
          feedback.userId: [feedbackData]
        });
      }
    } catch (e) {
      log('submitFeedback error: $e');
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Future<String> uploadFeedbackImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('feedback_images')
          .child(
              '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}');

      final bytes = await imageFile.readAsBytes();
      final uploadTask = storageRef.putData(bytes);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      log('uploadFeedbackImage error: $e');
      throw Exception('Failed to upload feedback image: $e');
    }
  }

  Future<Locale?> getSavedLanguage() async {
    try {
      final languageCode = await _secureDataStorage.getAppLanguage();
      return languageCode;
    } catch (e) {
      log('getSavedLanguage error: $e');
      return null;
    }
  }
}
