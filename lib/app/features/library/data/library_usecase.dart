import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ginfit/app/features/text_to_image/model/text_to_image_generation_response_model_for_black_forest_label.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_pollo_response_model.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@injectable
class LibraryUsecase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  LibraryUsecase({required this.firestore, required this.auth});

  Future<List<VideoGenerateResponseModel>> getUserGeneratedVideos() async {
    try {
      final userId = auth.currentUser!.uid;

      final snapshot = await firestore.collection('users').doc(userId).get();
      if (!snapshot.exists) return [];

      final data = snapshot.data();
      final videoList = data?['userGeneratedVideos'] as List<dynamic>? ?? [];

      return videoList
          .where((videoJson) {
            final map = Map<String, dynamic>.from(videoJson);
            return map['isDeleted'] !=
                true; // isDeleted true olmayanları göster
          })
          .map((videoJson) => VideoGenerateResponseModel.fromJson(
              Map<String, dynamic>.from(videoJson)))
          .toList();
    } catch (e) {
      log("getUserGeneratedVideos error: $e");
      return [];
    }
  }

  Future<VideoGenerateResponseModel?> checkPolloStatus(String taskId) async {
    try {
      final response = await http.get(
        Uri.parse('https://pollo.ai/api/platform/generation/$taskId/status'),
        headers: {
          "x-api-key": polloApiKey,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final polloResponse =
            VideoGeneratePolloResponseModel.fromJson(responseData);

        // Status'u kontrol et - generations array'indeki status'u kontrol et
        String status = 'starting';
        String? outputUrl;
        String? failMsg;

        if (polloResponse.data?.generations != null &&
            polloResponse.data!.generations!.isNotEmpty) {
          final generation = polloResponse.data!.generations!.first;

          if (generation.status == 'succeed') {
            status = 'succeeded';
            outputUrl = generation.url;
          } else if (generation.status == 'failed') {
            status = 'failed';
            failMsg = generation.failMsg;
          } else if (generation.status == 'waiting') {
            status = 'starting';
          }
        }

        return VideoGenerateResponseModel(
          id: taskId,
          model: 'pixverse-4.5',
          version: '4.5',
          input: null,
          status: status,
          output: outputUrl,
          error: failMsg, // Hata mesajını ekle
          createdAt: DateTime.now().toIso8601String(),
          completedAt: (outputUrl != null || status == 'failed')
              ? DateTime.now().toIso8601String()
              : null,
          fromTemplate:
              true, // Artık tüm videolar template olarak işaretleniyor
          templateName: 'Custom Video',
        );
      }
      return null;
    } catch (e) {
      log('Error checking Pollo status: $e');
      return null;
    }
  }

  Future<List<TextToImageImageGenerationResponseModelForBlackForestLabel>>
      getUserGeneratedImages() async {
    try {
      final userId = auth.currentUser!.uid;

      final snapshot = await firestore.collection('users').doc(userId).get();
      if (!snapshot.exists) return [];

      final data = snapshot.data();
      final imageList = data?['userGeneratedImages'] as List<dynamic>? ?? [];
      log('Library Images Data: ${imageList.toString()}');

      return imageList
          .where((imageJson) {
            final map = Map<String, dynamic>.from(imageJson);
            return map['isDeleted'] !=
                true; // isDeleted true olmayanları göster
          })
          .map((videoJson) =>
              TextToImageImageGenerationResponseModelForBlackForestLabel
                  .fromJson(Map<String, dynamic>.from(videoJson)))
          .toList();
    } catch (e) {
      log("getUserGeneratedImages error: $e");
      return [];
    }
  }

  Future<List<TextToImageImageGenerationResponseModelForBlackForestLabel>>
      getUserGeneratedRealtimeImages() async {
    try {
      final userId = auth.currentUser!.uid;

      final snapshot = await firestore.collection('users').doc(userId).get();
      if (!snapshot.exists) return [];

      final data = snapshot.data();
      final imageList =
          data?['userGeneratedRealtimeImages'] as List<dynamic>? ?? [];
      log(imageList.toString());

      return imageList
          .where((imageJson) {
            final map = Map<String, dynamic>.from(imageJson);
            return map['isDeleted'] !=
                true; // isDeleted true olmayanları göster
          })
          .map((imageJson) =>
              TextToImageImageGenerationResponseModelForBlackForestLabel
                  .fromJson(Map<String, dynamic>.from(imageJson)))
          .toList();
    } catch (e) {
      log("getUserGeneratedVideos error: $e");
      return [];
    }
  }

  Future<String?> downloadAndUploadVideoToFirebase(
      String replicateVideoUrl, String userId) async {
    try {
      final dio = Dio();
      // Geçici dosya yolu al
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Videoyu indir
      await dio.download(replicateVideoUrl, filePath);

      final file = File(filePath);

      // Firebase Storage referansı oluştur
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_videos/$userId/${file.uri.pathSegments.last}');

      // Yükle
      final fileBytes = await file.readAsBytes();
      await storageRef.putData(fileBytes);

      // Kalıcı URL'yi al
      final downloadUrl = await storageRef.getDownloadURL();

      // İndirilen dosyayı temizle (isteğe bağlı)
      await file.delete();

      return downloadUrl;
    } catch (e) {
      log('Error in downloadAndUploadVideoToFirebase: $e');
      return null;
    }
  }

  Future<EventStatus?> updateOutputById(
      VideoGenerateResponseModel newModel) async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId == null) return EventStatus.failure;

      final docRef = firestore.collection('users').doc(userId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) return EventStatus.failure;

      final data = docSnapshot.data();
      final List<dynamic> videos =
          List.from(data?['userGeneratedVideos'] ?? []);

      // Eski videoyu listeden çıkar
      videos.removeWhere((video) => video['id'] == newModel.id);

      // Yeni modeli listeye ekle (toJson ile JSON Map olarak ekle)
      videos.add(jsonDecode(jsonEncode(newModel.toJson())));

      // Firestore'a tek seferde listeyi güncelle
      await docRef.update({'userGeneratedVideos': videos});

      return EventStatus.success;
    } catch (e) {
      log('Update by ID with full model error: $e');
      return EventStatus.failure;
    }
  }

  Future<EventStatus?> softDeleteUserGeneratedVideo({
    required String videoId,
  }) async {
    try {
      final userId = auth.currentUser!.uid;
      final userDocRef = firestore.collection('users').doc(userId);

      final docSnapshot = await userDocRef.get();
      if (!docSnapshot.exists) return EventStatus.failure;

      final data = docSnapshot.data();
      final List<dynamic> videos = data?['userGeneratedVideos'] ?? [];

      final updatedVideos = videos.map((video) {
        if (video['id'] == videoId) {
          video['isDeleted'] = true;
        }
        return video;
      }).toList();

      await userDocRef.update({
        'userGeneratedVideos': updatedVideos,
      });

      return EventStatus.success;
    } catch (e) {
      log('softDeleteUserGeneratedVideo error: $e');
      return EventStatus.failure;
    }
  }

  Future<EventStatus?> softDeleteImage({
    required String imageId,
  }) async {
    try {
      final userId = auth.currentUser!.uid;
      final userDocRef = firestore.collection('users').doc(userId);

      final docSnapshot = await userDocRef.get();
      if (!docSnapshot.exists) return EventStatus.failure;

      final data = docSnapshot.data();
      final List<dynamic> images = data?['userGeneratedImages'] ?? [];

      final updatedImages = images.map((image) {
        if (image['id'] == imageId) {
          image['isDeleted'] = true;
        }
        return image;
      }).toList();

      await userDocRef.update({
        'userGeneratedImages': updatedImages,
      });

      return EventStatus.success;
    } catch (e) {
      log('softDeleteImage error: $e');
      return EventStatus.failure;
    }
  }

  Future<EventStatus?> softDeleteRealtimeImage({
    required String imageId,
  }) async {
    try {
      print(
          'LibraryUsecase - softDeleteRealtimeImage started for ID: $imageId');
      final userId = auth.currentUser!.uid;
      final userDocRef = firestore.collection('users').doc(userId);

      final docSnapshot = await userDocRef.get();
      if (!docSnapshot.exists) {
        print('LibraryUsecase - User document not found');
        return EventStatus.failure;
      }

      final data = docSnapshot.data();
      final List<dynamic> realtimeImages =
          data?['userGeneratedRealtimeImages'] ?? [];

      print('LibraryUsecase - Found ${realtimeImages.length} realtime images');

      final updatedRealtimeImages = realtimeImages.map((image) {
        if (image['id'] == imageId) {
          print(
              'LibraryUsecase - Found image with ID $imageId, setting isDeleted = true');
          image['isDeleted'] = true;
        }
        return image;
      }).toList();

      await userDocRef.update({
        'userGeneratedRealtimeImages': updatedRealtimeImages,
      });

      print('LibraryUsecase - softDeleteRealtimeImage completed successfully');
      return EventStatus.success;
    } catch (e) {
      print('LibraryUsecase - softDeleteRealtimeImage error: $e');
      log('softDeleteRealtimeImage error: $e');
      return EventStatus.failure;
    }
  }
}
