import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:ginly/app/features/realtime/model/realtime_image_generation_response_model_for_all_flux.dart';
import 'package:ginly/app/features/realtime/model/realtime_image_generation_response_model_for_black_forest_label.dart';
import 'package:ginly/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/app/features/auth/features/profile/bloc/profile_bloc.dart';

@injectable
class RealtimeUsecase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  RealtimeUsecase(this.auth, this.storage, {required this.firestore});

  Future<RealtimeImageGenerationResponseModelForAllFlux?>
      // ignore: body_might_complete_normally_nullable
      generateImageForRealtimeFluxFree(String prompt, {int? seed}) async {
    const String apiKey = togetherAPiKey; // API anahtarını buraya ekleyin

    final Map<String, dynamic> requestBody = {
      "model": "black-forest-labs/FLUX.1-schnell-Free",
      "prompt": prompt,
      "width": 512,
      "height": 720,
      "steps": 4,
      "n": 1,
      "seed": seed ?? Random().nextInt(99999),
      "response_format": "png"
    };

    try {
      final response = await http.post(
        Uri.parse(togetherApiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageGenerationResponse =
            RealtimeImageGenerationResponseModelForAllFlux.fromJson(
                responseData);

        return imageGenerationResponse;
      }
    } catch (e) {
      throw Exception('Error occurred while generating image: $e');
    }
  }

  Future<RealtimeImageGenerationResponseModelForAllFlux?>
      // ignore: body_might_complete_normally_nullable
      generateImageForRealtimeFlux(String prompt, {int? seed}) async {
    const String apiKey = togetherAPiKey;

    final Map<String, dynamic> requestBody = {
      "model": "black-forest-labs/FLUX.1-schnell",
      "prompt": prompt,
      "width": 512,
      "height": 720,
      "steps": 4,
      "n": 1,
      "seed": seed ?? Random().nextInt(99999),
      "response_format": "base64"
    };

    try {
      final response = await http.post(
        Uri.parse(togetherApiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageGenerationResponse =
            RealtimeImageGenerationResponseModelForAllFlux.fromJson(
                responseData);

        if (imageGenerationResponse.base64Image.isNotEmpty) {
          final userId = auth.currentUser!.uid;

          // Get credit requirements from AppBloc safely
          try {
            final appBloc = getIt<AppBloc>();
            final creditRequirements = appBloc.state.generateCreditRequirements;

            if (creditRequirements != null) {
              // Calculate required credits for realtime image
              int requiredCredits =
                  creditRequirements.realtimeImageRequiredCredits;

              // Check if user has enough credits
              final userDoc =
                  await firestore.collection('users').doc(userId).get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final currentCredits =
                    userData?['profile_info']?['totalCredit'] ?? 0;

                if (currentCredits >= requiredCredits) {
                  // Deduct credits - use direct calculation to preserve data type
                  final newCredits = currentCredits - requiredCredits;
                  await firestore.collection('users').doc(userId).update({
                    'profile_info.totalCredit': newCredits,
                  });

                  debugPrint(
                      'Realtime image credits deducted: $requiredCredits, Remaining: ${currentCredits - requiredCredits}');
                } else {
                  debugPrint(
                      'Insufficient credits for realtime image: Required $requiredCredits, Available $currentCredits');
                  throw Exception(
                      'Insufficient credits: Required $requiredCredits, Available $currentCredits');
                }
              }
            }
          } catch (e) {
            debugPrint('Error during credit deduction: $e');
            // Continue without credit deduction if there's an error
          }

          // Storage yükleme ve Firestore kaydını eşzamansız başlat (await yapma)
          uploadBase64ImageToStorage(
            base64Image: imageGenerationResponse.base64Image,
            userId: userId,
          ).then((imageUrl) {
            saveRealtimeImageForFluxToFirebase(
              RealtimeImageGenerationResponseModelForBlackForest(
                createdAt: DateTime.now().toString(),
                id: Random().nextInt(99999).toString() +
                    Random().nextInt(999).toString(),
                model: requestBody['model'],
                input: requestBody,
                output: [imageUrl],
                status: 'success',
                version: '',
                isDeleted: false,
                isRealtimeImage: true,
              ),
            );
          });

          // Ana sonucu hemen dön (base64 veri ile)
          return imageGenerationResponse;
        }
      } else {
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while generating image: $e');
    }
  }

  Future<String> uploadUserImage(File imageFile) async {
    final userId = auth.currentUser!.uid;

    final ref = storage.ref().child(
        "user_uploads/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");

    final bytes = await imageFile.readAsBytes();
    final uploadTask = await ref.putData(bytes);
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }

  Future<EventStatus> saveBlackForestImageToFirebase(
    RealtimeImageGenerationResponseModelForBlackForest imageResponse,
  ) async {
    try {
      final userId = auth.currentUser!.uid;

      final tempUrl = imageResponse.output?.first;
      if (tempUrl == null || tempUrl.isEmpty) {
        throw Exception('Geçersiz geçici URL');
      }

      // Görseli indir
      final response = await http.get(Uri.parse(tempUrl));
      if (response.statusCode != 200) {
        throw Exception('Görsel indirilemedi: ${response.statusCode}');
      }

      // Geçici dosyaya yaz
      final bytes = response.bodyBytes;
      final tempDir = Directory.systemTemp;
      final tempFile =
          File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(bytes);

      // Firebase Storage’a yükle
      final firebaseImageUrl = await uploadUserImage(tempFile);

      // Yeni model oluştur: sadece outpucart URL’sini değiştir
      final updatedModel = imageResponse.copyWith(output: [firebaseImageUrl]);

      // Firestore’a yaz
      final modelMap = jsonDecode(jsonEncode(updatedModel.toJson()));
      await firestore.collection('users').doc(userId).update({
        'userGeneratedRealtimeImages': FieldValue.arrayUnion([modelMap])
      });

      return EventStatus.success;
    } catch (e) {
      return EventStatus.failure;
    }
  }

  Future<EventStatus> saveRealtimeImageForFluxToFirebase(
    RealtimeImageGenerationResponseModelForBlackForest imageResponse,
  ) async {
    try {
      final userId = auth.currentUser!.uid;
      final userDocRef = firestore.collection('users').doc(userId);

      final docSnapshot = await userDocRef.get();

      if (docSnapshot.exists) {
        // Doküman varsa, array'e ekle
        await userDocRef.update({
          'userGeneratedRealtimeImages':
              FieldValue.arrayUnion([imageResponse.toJson()])
        });
      } else {
        // Doküman yoksa, oluştur
        await userDocRef.set({
          'userGeneratedRealtimeImages': [imageResponse.toJson()]
        });
      }

      return EventStatus.success;
    } catch (e) {
      return EventStatus.failure;
    }
  }

  Future<String> uploadBase64ImageToStorage({
    required String base64Image,
    required String userId,
  }) async {
    final bytes = base64Decode(base64Image);
    final storageRef = storage.ref().child(
        'userRealtimeImages/$userId/${DateTime.now().millisecondsSinceEpoch}.png');

    final uploadTask = await storageRef.putData(bytes);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<EventStatus> useCredit({
    required int requiredCredit,
    required int availableCredit,
  }) async {
    if (availableCredit > 0) {
      try {
        final userId = auth.currentUser!.uid;
        final userDocRef = firestore.collection('users').doc(userId);
        // 1. Kredi düş
        await userDocRef.update({
          'profile_info.totalCredit': FieldValue.increment(-requiredCredit),
        });

        return EventStatus.success;
      } catch (e) {
        return EventStatus.failure;
      }
    } else {
      return EventStatus.failure;
    }
  }

  Future<EventStatus> softDeleteUserGeneratedRealtimeImage({
    required String imageId,
  }) async {
    try {
      final userId = auth.currentUser!.uid;
      final userDocRef = firestore.collection('users').doc(userId);

      final docSnapshot = await userDocRef.get();
      if (!docSnapshot.exists) return EventStatus.failure;

      final data = docSnapshot.data();
      final List<dynamic> images = data?['userGeneratedRealtimeImages'] ?? [];

      final updatedImages = images.map((image) {
        if (image['id'] == imageId) {
          image['isDeleted'] = true;
        }
        return image;
      }).toList();

      await userDocRef.update({
        'userGeneratedRealtimeImages': updatedImages,
      });

      return EventStatus.success;
    } catch (e) {
      return EventStatus.failure;
    }
  }
}
