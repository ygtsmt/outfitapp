import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ginly/app/features/text_to_image/bloc/text_to_image_bloc.dart';
import 'package:ginly/app/features/text_to_image/model/text_to_image_flux_request_model.dart';
import 'package:ginly/app/features/text_to_image/model/text_to_image_generation_response_model_for_all_flux.dart';
import 'package:ginly/app/features/text_to_image/model/text_to_image_generation_response_model_for_black_forest_label.dart';
import 'package:ginly/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/app/features/auth/features/profile/bloc/profile_bloc.dart';

@injectable
class TextToImageUsecase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  TextToImageUsecase(this.auth, this.storage, {required this.firestore});

  Future<TextToImageImageGenerationResponseModelForAllFlux?>
      // ignore: body_might_complete_normally_nullable
      generateImageForTextToImageFluxFree(String prompt, Size size) async {
    try {
      final response = await http.post(
        Uri.parse(togetherApiUrl),
        headers: {
          "Authorization": "Bearer $togetherAPiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(TextToImageFluxRequestModel(
            model: "black-forest-labs/FLUX.1-schnell-Free",
            prompt: prompt,
            width: ((size.width > 1440 ? 1440 : size.width.toInt()) ~/ 16) * 16,
            height:
                ((size.height > 1440 ? 1440 : size.height.toInt()) ~/ 16) * 16,
            steps: 12,
            n: 1,
            seed: Random().nextInt(1000),
            responseFormat: "png")),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageGenerationResponse =
            TextToImageImageGenerationResponseModelForAllFlux.fromJson(
                responseData);

        return imageGenerationResponse;
      } else if (response.statusCode == 429) {
        getIt<TextToImageBloc>()
            .add(GenerateImageForTextToImageFlux(prompt: prompt, size: size));
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while generating image: $e');
    }
  }

  Future<TextToImageImageGenerationResponseModelForAllFlux?>
      generateImageForTextToImageFlux(
    String prompt,
    Size size,
  ) async {
    const String apiKey = togetherAPiKey; // API anahtarını buraya ekleyin

    try {
      final response = await http.post(
        Uri.parse(togetherApiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(TextToImageFluxRequestModel(
            model: "black-forest-labs/FLUX.1-schnell",
            prompt: prompt,
            width: ((size.width > 1440 ? 1440 : size.width.toInt()) ~/ 16) * 16,
            height:
                ((size.height > 1440 ? 1440 : size.height.toInt()) ~/ 16) * 16,
            steps: 12,
            n: 1,
            seed: Random().nextInt(1000),
            responseFormat: "png")),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final imageGenerationResponse =
            TextToImageImageGenerationResponseModelForAllFlux.fromJson(
                responseData);

        // Check credits BEFORE making API call
        try {
          final appBloc = getIt<AppBloc>();
          final creditRequirements = appBloc.state.generateCreditRequirements;

          if (creditRequirements != null) {
            // Calculate required credits for image
            int requiredCredits = creditRequirements.imageRequiredCredits;

            // Check if user has enough credits BEFORE API call
            final userId = auth.currentUser!.uid;
            final userDoc =
                await firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              final currentCredits =
                  userData?['profile_info']?['totalCredit'] ?? 0;

              if (currentCredits < requiredCredits) {
                debugPrint(
                    '❌ Insufficient credits for image: Required $requiredCredits, Available $currentCredits');
                throw Exception(
                    'Insufficient credits: Required $requiredCredits, Available $currentCredits');
              }

              // Credits are sufficient, proceed with API call
              debugPrint(
                  '✅ Credits sufficient: $currentCredits >= $requiredCredits');
            }
          }
        } catch (e) {
          debugPrint('❌ Credit check failed: $e');
          rethrow; // Re-throw to stop the process
        }

        // API call successful, now deduct credits
        try {
          final appBloc = getIt<AppBloc>();
          final creditRequirements = appBloc.state.generateCreditRequirements;

          if (creditRequirements != null) {
            int requiredCredits = creditRequirements.imageRequiredCredits;
            final userId = auth.currentUser!.uid;

            // Use transaction to atomically check and deduct credits
            await firestore.runTransaction((transaction) async {
              final userDoc = await transaction
                  .get(firestore.collection('users').doc(userId));
              if (userDoc.exists) {
                final userData = userDoc.data();
                final currentCredits =
                    userData?['profile_info']?['totalCredit'] ?? 0;

                if (currentCredits >= requiredCredits) {
                  // Atomically deduct credits
                  transaction.update(userDoc.reference, {
                    'profile_info.totalCredit':
                        currentCredits - requiredCredits,
                  });
                  debugPrint(
                      '✅ Credits deducted atomically: $requiredCredits, Remaining: ${currentCredits - requiredCredits}');
                } else {
                  throw Exception(
                      'Insufficient credits during transaction: Required $requiredCredits, Available $currentCredits');
                }
              }
            });
          }
        } catch (e) {
          debugPrint('❌ Error deducting credits after API call: $e');
          // Don't rethrow here, image was generated successfully
        }

        return imageGenerationResponse;
      } else if (response.statusCode == 422) {
        // Content filter error - return special response
        return null; // Will be handled in bloc
      } else {
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while generating image: $e');
    }
  }

/* 
  Future<EventStatus?> addUserImageForBlackForestLabel(
    TextToImageImageGenerationResponseModelForBlackForestLabel imageResponse,
  ) async {
    try {
      final userId = auth.currentUser!.uid;

      // Saf JSON map elde et
      final imageData = jsonDecode(jsonEncode(imageResponse.toJson()));

      await firestore.collection('users').doc(userId).update({
        'userGeneratedImages': FieldValue.arrayUnion([imageData])
      });

      return EventStatus.success;
    } catch (e) {
      return EventStatus.failure;
    }
  }
 */
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
    TextToImageImageGenerationResponseModelForBlackForestLabel imageResponse,
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

      // Firebase Storage'a yükle
      final firebaseImageUrl = await uploadUserImage(tempFile);

      // Yeni model oluştur: sadece output URL'sini değiştir
      final updatedModel = imageResponse.copyWith(output: [firebaseImageUrl]);

      // Firestore'a yaz
      final modelMap = jsonDecode(jsonEncode(updatedModel.toJson()));
      await firestore.collection('users').doc(userId).update({
        'userGeneratedImages': FieldValue.arrayUnion([modelMap])
      });

      return EventStatus.success;
    } catch (e) {
      debugPrint('🔥 Firebase kayıt hatası: $e');
      return EventStatus.failure;
    }
  }

  Future<EventStatus> saveTextToImageToFirebase(
    TextToImageImageGenerationResponseModelForAllFlux imageResponse,
    String prompt,
  ) async {
    try {
      final userId = auth.currentUser!.uid;

      // Base64 image'ı Firebase Storage'a yükle
      final base64Image = imageResponse.base64Image;
      if (base64Image.isEmpty) {
        throw Exception('Base64 image boş');
      }

      // Base64'ü bytes'a çevir
      final bytes = base64Decode(base64Image);

      // Geçici dosyaya yaz
      final tempDir = Directory.systemTemp;
      final tempFile =
          File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(bytes);

      // Firebase Storage'a yükle
      final firebaseImageUrl = await uploadUserImage(tempFile);

      // Yeni model oluştur: BlackForestLabel model'ine uygun hale getir
      final modelMap = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'output': [firebaseImageUrl],
        'prompt': prompt,
        'createdAt': DateTime.now().toIso8601String(),
        'isDeleted': false,
      };

      // Firestore'a yaz
      await firestore.collection('users').doc(userId).update({
        'userGeneratedImages': FieldValue.arrayUnion([modelMap])
      });

      // Geçici dosyayı temizle
      await tempFile.delete();

      return EventStatus.success;
    } catch (e) {
      debugPrint('🔥 Text-to-Image Firebase kayıt hatası: $e');
      return EventStatus.failure;
    }
  }
}
