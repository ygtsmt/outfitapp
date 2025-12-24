import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ginly/app/features/video_generate/model/video_generate_pixverse_pollo_request_model.dart';
import 'package:ginly/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginly/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:ginly/app/bloc/app_bloc.dart';

@injectable
class FalAiUsecase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  // 🔑 Cached API key from Firebase
  String? _cachedFalAiApiKey;
  DateTime? _keyLastFetched;

  FalAiUsecase({
    required this.firestore,
    required this.auth,
    required this.storage,
  });

  /// 🔑 Get Fal AI API Key from Firebase (with 5-minute cache)
  /// Firebase path: keys/fal_ai/falAiApiKey
  Future<String> getFalAiApiKey() async {
    try {
      // Cache kontrolü - 5 dakika geçerli
      final now = DateTime.now();
      if (_cachedFalAiApiKey != null &&
          _keyLastFetched != null &&
          now.difference(_keyLastFetched!).inMinutes < 5) {
        log('🔑 Using cached Fal AI API key');
        return _cachedFalAiApiKey!;
      }

      log('🔥 Fetching Fal AI API key from Firebase...');
      final docSnapshot =
          await firestore.collection('keys').doc('fal_ai').get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final apiKey = data?['falAiApiKey'] as String?;

        if (apiKey != null && apiKey.isNotEmpty) {
          _cachedFalAiApiKey = apiKey;
          _keyLastFetched = now;
          log('✅ Fal AI API key loaded from Firebase: ${apiKey.substring(0, 10)}...');
          return apiKey;
        }
      }

      // Fallback: Firebase'de yoksa hardcoded key kullan
      log('⚠️ Firebase key not found, using fallback hardcoded key');
      return falAiApiKey;
    } catch (e) {
      log('❌ Error fetching Fal AI API key from Firebase: $e');
      // Error durumunda fallback key kullan
      return falAiApiKey;
    }
  }

  Future<String> uploadUserImage(File imageFile) async {
    final userId = auth.currentUser!.uid;

    try {
      final ref = storage.ref().child(
          "fal_ai_uploads/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");

      final bytes = await imageFile.readAsBytes();
      final uploadTask = await ref.putData(bytes);

      // Dosyayı public yap (Fal AI erişimi için)
      await ref.updateMetadata(SettableMetadata(
        cacheControl: 'public, max-age=3600',
        contentType: 'image/jpeg',
      ));

      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      log('Fal AI uploadUserImage error: $e');
      throw Exception('Error uploading user image: $e');
    }
  }

  Future<VideoGenerateResponseModel?> generateFalAiVideo(
      VideoGeneratePixversePolloRequestInputModel requestModel) async {
    try {
      // Webhook URL'i query parameter olarak ekle
      final webhookUrl =
          "https://us-central1-disciplify-26970.cloudfunctions.net/falWebhook";
      final uri =
          Uri.parse('https://queue.fal.run/fal-ai/pixverse/v4.5/effects')
              .replace(queryParameters: {'fal_webhook': webhookUrl});

      final apiKey = await getFalAiApiKey();
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Key $apiKey",
          "Content-Type": "application/json",
        },
        body: () {
          final requestBody = {
            "effect": requestModel.effect, // Effect root level'da olmalı
            "image_url": requestModel.image, // Doğru field adı
            "resolution": _mapResolution(requestModel.resolution ?? "540p"),
            "duration": _mapDuration(requestModel.length ?? 5),
            if (requestModel.negativePrompt != null &&
                requestModel.negativePrompt!.isNotEmpty)
              "negative_prompt": requestModel.negativePrompt, // Doğru field adı
            // webhookUrl body'den kaldırıldı, query parameter olarak gönderiliyor
          };
          final jsonBody = jsonEncode(requestBody);
          log('Fal AI Request URL: $uri');
          log('Fal AI Request Body: $jsonBody');
          return jsonBody;
        }(),
      );

      log('Fal AI Response Status: ${response.statusCode}');
      log('Fal AI Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final requestId = responseData['request_id'];

        if (requestId != null) {
          // Get credit requirements from AppBloc safely
          try {
            final appBloc = getIt<AppBloc>();
            final creditRequirements = appBloc.state.generateCreditRequirements;

            if (creditRequirements != null) {
              // Calculate required credits for template video
              int requiredCredits =
                  creditRequirements.videoTemplateRequiredCredits;

              // Check if user has enough credits
              final userId = auth.currentUser!.uid;
              final userDoc =
                  await firestore.collection('users').doc(userId).get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final currentCredits =
                    userData?['profile_info']?['totalCredit'] ?? 0;

                if (currentCredits >= requiredCredits) {
                  // Deduct credits
                  final newCredits = currentCredits - requiredCredits;
                  await firestore.collection('users').doc(userId).update({
                    'profile_info.totalCredit': newCredits,
                  });

                  log('Fal AI credits deducted: $requiredCredits, Remaining: $newCredits');
                } else {
                  log('Insufficient credits for Fal AI: Required $requiredCredits, Available $currentCredits');
                  throw Exception(
                      'Insufficient credits: Required $requiredCredits, Available $currentCredits');
                }
              }
            }
          } catch (e) {
            log('Error during Fal AI credit deduction: $e');
            // Continue without credit deduction if there's an error
          }

          // Create response model for Fal AI
          return VideoGenerateResponseModel(
            id: requestId,
            model: 'fal-pixverse-v4.5',
            version: '4.5',
            input: Input(
              image: requestModel.image,
              prompt: requestModel.prompt,
              aspectRatio: requestModel.aspectRatio,
              motionMode: null,
              seed: requestModel.seed,
              quality: requestModel.resolution,
              style: requestModel.style,
              duration: requestModel.length ?? 5,
              lastFrameImage: requestModel.imageTail,
            ),
            status: 'processing',
            output: null,
            createdAt: DateTime.now().toIso8601String(),
            completedAt: null,
            fromTemplate: true,
            templateName: requestModel.templateName,
          );
        }
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Bad Request';
        log('Fal AI 400 Error: $errorMessage');
        throw Exception('Fal AI Error (400): $errorMessage');
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Validation Error';
        final errorDetails = errorBody['detail'] ?? 'No details provided';
        log('Fal AI 422 Error: $errorMessage');
        log('Fal AI 422 Details: $errorDetails');
        throw Exception(
            'Fal AI Validation Error (422): $errorMessage - $errorDetails');
      } else {
        log('Fal AI Unexpected Error (${response.statusCode}): ${response.body}');
        throw Exception(
            'Fal AI Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while generating Fal AI video: $e');
    }
    return null;
  }

  Future<VideoGenerateResponseModel?> generateFalAiImageToVideo(
      VideoGeneratePixversePolloRequestInputModel requestModel,
      {bool fromTemplate = false}) async {
    try {
      // Webhook URL'i query parameter olarak ekle
      final webhookUrl =
          "https://us-central1-disciplify-26970.cloudfunctions.net/falWebhook";
      final uri =
          Uri.parse('https://queue.fal.run/fal-ai/pixverse/v4.5/image-to-video')
              .replace(queryParameters: {'fal_webhook': webhookUrl});

      final apiKey = await getFalAiApiKey();
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Key $apiKey",
          "Content-Type": "application/json",
        },
        body: () {
          final requestBody = {
            "prompt": requestModel.prompt ?? "",
            "aspect_ratio": _mapAspectRatio(requestModel.aspectRatio ?? "1:1"),
            "resolution": _mapResolution(requestModel.resolution ?? "720p"),
            "duration": _mapDuration(requestModel.length ?? 5),
            if (requestModel.negativePrompt != null &&
                requestModel.negativePrompt!.isNotEmpty)
              "negative_prompt": requestModel.negativePrompt,
            if (requestModel.image != null) "image_url": requestModel.image,
          };
          final jsonBody = jsonEncode(requestBody);
          log('Fal AI Image-to-Video Request URL: $uri');
          log('Fal AI Image-to-Video Request Body: $jsonBody');
          return jsonBody;
        }(),
      );

      log('Fal AI Image-to-Video Response Status: ${response.statusCode}');
      log('Fal AI Image-to-Video Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final requestId = responseData['request_id'];

        if (requestId != null) {
          // Get credit requirements from AppBloc safely
          try {
            final appBloc = getIt<AppBloc>();
            final creditRequirements = appBloc.state.generateCreditRequirements;

            if (creditRequirements != null) {
              // Calculate required credits for custom video
              int requiredCredits = creditRequirements.videoRequiredCredits;

              // Check if user has enough credits
              final userId = auth.currentUser!.uid;
              final userDoc =
                  await firestore.collection('users').doc(userId).get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final currentCredits =
                    userData?['profile_info']?['totalCredit'] ?? 0;

                if (currentCredits >= requiredCredits) {
                  // Deduct credits
                  final newCredits = currentCredits - requiredCredits;
                  await firestore.collection('users').doc(userId).update({
                    'profile_info.totalCredit': newCredits,
                  });

                  log('Fal AI Image-to-Video credits deducted: $requiredCredits, Remaining: $newCredits');
                } else {
                  log('Insufficient credits for Fal AI Image-to-Video: Required $requiredCredits, Available $currentCredits');
                  throw Exception(
                      'Insufficient credits: Required $requiredCredits, Available $currentCredits');
                }
              }
            }
          } catch (e) {
            log('Error during Fal AI Image-to-Video credit deduction: $e');
            // Continue without credit deduction if there's an error
          }

          // Create response model for Fal AI Image-to-Video
          return VideoGenerateResponseModel(
            id: requestId,
            model: 'fal-pixverse-image-to-video-v4.5',
            version: '4.5',
            input: Input(
              image: requestModel.image,
              prompt: requestModel.prompt,
              aspectRatio: requestModel.aspectRatio,
              motionMode: null,
              seed: requestModel.seed,
              quality: requestModel.resolution,
              style: requestModel.style,
              duration: requestModel.length ?? 5,
              lastFrameImage: requestModel.imageTail,
            ),
            status: 'processing',
            output: null,
            createdAt: DateTime.now().toIso8601String(),
            completedAt: null,
            fromTemplate: fromTemplate,
            templateName: fromTemplate ? requestModel.templateName : null,
          );
        }
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Bad Request';
        log('Fal AI Image-to-Video 400 Error: $errorMessage');
        throw Exception('Fal AI Image-to-Video Error (400): $errorMessage');
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Validation Error';
        final errorDetails = errorBody['detail'] ?? 'No details provided';
        log('Fal AI Image-to-Video 422 Error: $errorMessage');
        log('Fal AI Image-to-Video 422 Details: $errorDetails');
        throw Exception(
            'Fal AI Image-to-Video Validation Error (422): $errorMessage - $errorDetails');
      } else {
        log('Fal AI Image-to-Video Unexpected Error (${response.statusCode}): ${response.body}');
        throw Exception(
            'Fal AI Image-to-Video Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(
          'Error occurred while generating Fal AI Image-to-Video: $e');
    }
    return null;
  }

  Future<EventStatus?> addUserVideo(
      VideoGenerateResponseModel userVideo) async {
    try {
      final userId = auth.currentUser!.uid;

      final videoData = jsonDecode(jsonEncode(userVideo.toJson()));

      await firestore.collection('users').doc(userId).update({
        'userGeneratedVideos': FieldValue.arrayUnion([videoData]),
        'hasPendingVideos': true // Pending video var
      });

      return EventStatus.success;
    } catch (e) {
      log('Fal AI addUserVideo error: $e');
      return EventStatus.failure;
    }
  }

  // Resolution mapping function
  String _mapResolution(String resolution) {
    switch (resolution.toLowerCase()) {
      case '360p':
        return '360p';
      case '540p':
        return '540p';
      case '720p':
        return '720p';
      case '1080p':
        return '1080p';
      default:
        return '720p';
    }
  }

  // Duration mapping function
  String _mapDuration(int duration) {
    switch (duration) {
      case 5:
        return '5';
      case 8:
        return '8';
      default:
        return '5';
    }
  }

  // Aspect ratio mapping function
  String _mapAspectRatio(String aspectRatio) {
    switch (aspectRatio) {
      case '1:1':
        return '1:1';
      case '16:9':
        return '16:9';
      case '9:16':
        return '9:16';
      case '4:3':
        return '4:3';
      case '3:4':
        return '3:4';
      default:
        return '1:1';
    }
  }

  // Hailuo Image-to-Video generation
  Future<VideoGenerateResponseModel?> generateFalAiHailuoImageToVideo(
      VideoGeneratePixversePolloRequestInputModel requestModel,
      {bool fromTemplate = false}) async {
    try {
      // Webhook URL'i query parameter olarak ekle
      final webhookUrl =
          "https://us-central1-disciplify-26970.cloudfunctions.net/falWebhook";
      final uri = Uri.parse(
              'https://queue.fal.run/fal-ai/minimax/hailuo-02-fast/image-to-video')
          .replace(queryParameters: {'fal_webhook': webhookUrl});

      final apiKey = await getFalAiApiKey();
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Key $apiKey",
          "Content-Type": "application/json",
        },
        body: () {
          final requestBody = {
            "prompt": requestModel.prompt ?? "",
            "image_url": requestModel.image,
            "duration": _mapHailuoDuration(requestModel.length ?? 6),
            "prompt_optimizer": true,
            "resolution":
                _mapHailuoResolution(requestModel.resolution ?? "768p"),
          };
          final jsonBody = jsonEncode(requestBody);
          log('Fal AI Hailuo Image-to-Video Request URL: $uri');
          log('Fal AI Hailuo Image-to-Video Request Body: $jsonBody');
          return jsonBody;
        }(),
      );

      log('Fal AI Hailuo Response Status: ${response.statusCode}');
      log('Fal AI Hailuo Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final requestId = responseData['request_id'];

        if (requestId != null) {
          // Get credit requirements from AppBloc safely
          try {
            final appBloc = getIt<AppBloc>();
            final creditRequirements = appBloc.state.generateCreditRequirements;

            if (creditRequirements != null) {
              // Calculate required credits for template video
              int requiredCredits =
                  creditRequirements.videoTemplateRequiredCredits;

              // Check if user has enough credits
              final userId = auth.currentUser!.uid;
              final userDoc =
                  await firestore.collection('users').doc(userId).get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final currentCredits =
                    userData?['profile_info']?['totalCredit'] ?? 0;

                if (currentCredits >= requiredCredits) {
                  // Deduct credits
                  final newCredits = currentCredits - requiredCredits;
                  await firestore.collection('users').doc(userId).update({
                    'profile_info.totalCredit': newCredits,
                  });

                  log('Fal AI Hailuo credits deducted: $requiredCredits, Remaining: $newCredits');
                } else {
                  log('Insufficient credits for Fal AI Hailuo: Required $requiredCredits, Available $currentCredits');
                  throw Exception(
                      'Insufficient credits: Required $requiredCredits, Available $currentCredits');
                }
              }
            }
          } catch (e) {
            log('Error during Fal AI Hailuo credit deduction: $e');
            // Continue without credit deduction if there's an error
          }

          // Create response model for Fal AI Hailuo
          return VideoGenerateResponseModel(
            id: requestId,
            model: 'fal-hailuo-02',
            version: '02',
            input: Input(
              image: requestModel.image,
              prompt: requestModel.prompt,
              aspectRatio: requestModel.aspectRatio,
              motionMode: null,
              seed: requestModel.seed,
              quality: requestModel.resolution,
              style: requestModel.style,
              duration: requestModel.length ?? 5,
              lastFrameImage: requestModel.imageTail,
            ),
            status: 'processing',
            output: null,
            createdAt: DateTime.now().toIso8601String(),
            completedAt: null,
            fromTemplate: true,
            templateName: requestModel.templateName,
          );
        }
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Bad Request';
        log('Fal AI Hailuo 400 Error: $errorMessage');
        throw Exception('Fal AI Hailuo Error (400): $errorMessage');
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Validation Error';
        final errorDetails = errorBody['detail'] ?? 'No details provided';
        log('Fal AI Hailuo 422 Error: $errorMessage');
        log('Fal AI Hailuo 422 Details: $errorDetails');
        throw Exception(
            'Fal AI Hailuo Validation Error (422): $errorMessage - $errorDetails');
      } else {
        log('Fal AI Hailuo Unexpected Error (${response.statusCode}): ${response.body}');
        throw Exception(
            'Fal AI Hailuo Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(
          'Error occurred while generating Fal AI Hailuo video: $e');
    }
    return null;
  }

  // Hailuo Text-to-Video
  Future<VideoGenerateResponseModel?> generateFalAiHailuoTextToVideo(
      VideoGeneratePixversePolloRequestInputModel requestModel) async {
    try {
      // Webhook URL'i query parameter olarak ekle
      final webhookUrl =
          "https://us-central1-disciplify-26970.cloudfunctions.net/falWebhook";
      final uri = Uri.parse(
              'https://queue.fal.run/fal-ai/minimax/hailuo-02-fast/text-to-video')
          .replace(queryParameters: {'fal_webhook': webhookUrl});

      final apiKey = await getFalAiApiKey();
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Key $apiKey",
          "Content-Type": "application/json",
        },
        body: () {
          final requestBody = {
            "prompt": requestModel.prompt ?? "",
            "duration": _mapHailuoDuration(requestModel.length ?? 6),
            "prompt_optimizer": false,
            // NOT: Text-to-video'da resolution yok!
          };
          final jsonBody = jsonEncode(requestBody);
          log('Fal AI Hailuo Text-to-Video Request URL: $uri');
          log('Fal AI Hailuo Text-to-Video Request Body: $jsonBody');
          return jsonBody;
        }(),
      );

      log('Fal AI Hailuo Text-to-Video Response Status: ${response.statusCode}');
      log('Fal AI Hailuo Text-to-Video Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final requestId = responseData['request_id'];

        if (requestId != null) {
          // Get credit requirements from AppBloc safely
          try {
            final appBloc = getIt<AppBloc>();
            final creditRequirements = appBloc.state.generateCreditRequirements;

            if (creditRequirements != null) {
              // Calculate required credits for text-to-video
              int requiredCredits = creditRequirements.videoRequiredCredits;

              // Check if user has enough credits
              final userId = auth.currentUser!.uid;
              final userDoc =
                  await firestore.collection('users').doc(userId).get();
              if (userDoc.exists) {
                final userData = userDoc.data();
                final currentCredits =
                    userData?['profile_info']?['totalCredit'] ?? 0;

                if (currentCredits >= requiredCredits) {
                  // Deduct credits
                  final newCredits = currentCredits - requiredCredits;
                  await firestore.collection('users').doc(userId).update({
                    'profile_info.totalCredit': newCredits,
                  });

                  log('Fal AI Hailuo Text-to-Video credits deducted: $requiredCredits, Remaining: $newCredits');
                } else {
                  log('Insufficient credits for Fal AI Hailuo Text-to-Video: Required $requiredCredits, Available $currentCredits');
                  throw Exception(
                      'Insufficient credits: Required $requiredCredits, Available $currentCredits');
                }
              }
            }
          } catch (e) {
            log('Error during Fal AI Hailuo Text-to-Video credit deduction: $e');
            // Continue without credit deduction if there's an error
          }

          // Create response model for Fal AI Hailuo Text-to-Video
          return VideoGenerateResponseModel(
            id: requestId,
            model: 'hailuo-text-to-video',
            version: '02',
            input: Input(
              prompt: requestModel.prompt,
              aspectRatio: requestModel.aspectRatio,
              seed: requestModel.seed,
              quality: requestModel.resolution,
              style: requestModel.style,
              duration: requestModel.length ?? 5,
            ),
            status: 'starting',
            output: null,
            createdAt: DateTime.now().toIso8601String(),
            completedAt: null,
            fromTemplate:
                true, // Artık tüm videolar template olarak işaretleniyor
            templateName: requestModel.templateName ?? 'Custom Video',
          );
        }
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Bad Request';
        log('Fal AI Hailuo Text-to-Video 400 Error: $errorMessage');
        throw Exception(
            'Fal AI Hailuo Text-to-Video Error (400): $errorMessage');
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Validation Error';
        final errorDetails = errorBody['detail'] ?? 'No details provided';
        log('Fal AI Hailuo Text-to-Video 422 Error: $errorMessage');
        log('Fal AI Hailuo Text-to-Video 422 Details: $errorDetails');
        throw Exception(
            'Fal AI Hailuo Text-to-Video Validation Error (422): $errorMessage - $errorDetails');
      } else {
        log('Fal AI Hailuo Text-to-Video Unexpected Error (${response.statusCode}): ${response.body}');
        throw Exception(
            'Fal AI Hailuo Text-to-Video Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(
          'Error occurred while generating Fal AI Hailuo Text-to-Video: $e');
    }
    return null;
  }

  // Hailuo Duration mapping function (returns string)
  String _mapHailuoDuration(int duration) {
    switch (duration) {
      case 6:
        return '6';
      case 10:
        return '10';
      default:
        return '6'; // Default: 6 seconds
    }
  }

  // Hailuo Resolution mapping function
  String _mapHailuoResolution(String resolution) {
    switch (resolution.toLowerCase()) {
      case '512p':
        return '512P';
      case '768p':
        return '768P';
      default:
        return '768P'; // Default: 768P
    }
  }

  /// Gemini 2.5 Flash Image Edit
  /// Generates edited images based on prompt and input images
  Future<Map<String, dynamic>?> generateGeminiImageEdit({
    required List<String> imageUrls,
    required String prompt,
  }) async {
    try {
      // Webhook URL'i query parameter olarak ekle
      final webhookUrl =
          "https://us-central1-disciplify-26970.cloudfunctions.net/falWebhook";
      final uri =
          Uri.parse('https://queue.fal.run/fal-ai/gemini-25-flash-image/edit')
              .replace(queryParameters: {'fal_webhook': webhookUrl});

      final apiKey = await getFalAiApiKey();
      final response = await http.post(
        uri,
        headers: {
          "Authorization": "Key $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "prompt": 'Kıyafetleri kadına giydir',
          "image_urls": imageUrls,
        }),
      );

      log('Gemini Image Edit Response Status: ${response.statusCode}');
      log('Gemini Image Edit Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final requestId = responseData['request_id'];

        if (requestId != null) {
          // Create image data for Firestore
          final imageData = {
            'id': requestId,
            'prompt': prompt,
            'inputImages': imageUrls,
            'output': null, // Will be filled by webhook
            'status': 'processing',
            'createdAt': DateTime.now().toIso8601String(),
            'completedAt': null,
            'model': 'gemini-2.5-flash-image-edit',
          };

          // Add to user's Firestore document
          final userId = auth.currentUser!.uid;
          await firestore.collection('users').doc(userId).update({
            'userGeneratedImages': FieldValue.arrayUnion([imageData]),
          });

          log('✅ Gemini Image Edit request created: $requestId');
          return imageData;
        }
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Bad Request';
        log('Gemini Image Edit 400 Error: $errorMessage');
        throw Exception('Gemini Image Edit Error (400): $errorMessage');
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Validation Error';
        final errorDetails = errorBody['detail'] ?? 'No details provided';
        log('Gemini Image Edit 422 Error: $errorMessage');
        log('Gemini Image Edit 422 Details: $errorDetails');
        throw Exception(
            'Gemini Image Edit Validation Error (422): $errorMessage - $errorDetails');
      } else {
        log('Gemini Image Edit Unexpected Error (${response.statusCode}): ${response.body}');
        throw Exception(
            'Gemini Image Edit Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      log('Error occurred while generating Gemini Image Edit: $e');
      throw Exception('Error occurred while generating Gemini Image Edit: $e');
    }
    return null;
  }
}
