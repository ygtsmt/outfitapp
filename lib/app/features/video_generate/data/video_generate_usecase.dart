import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:ginfit/app/features/video_generate/model/video_generate_pollo_request_model.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_pollo_response_model.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_pixverse_pollo_request_model.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginfit/app/features/video_generate/model/pixverse_original_image_upload_model.dart';
import 'package:ginfit/app/features/video_generate/model/pixverse_original_video_generate_model.dart';
import 'package:ginfit/app/features/video_generate/model/pixverse_original_video_result_model.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/core/constants/webhook_constants.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:ginfit/app/bloc/app_bloc.dart';
import 'dart:io';
import 'dart:async';
import 'package:uuid/uuid.dart';

@injectable
class VideoGenerateUsecase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  // 🔑 Cached API key from Firebase
  String? _cachedPixverseApiKey;
  DateTime? _keyLastFetched;

  VideoGenerateUsecase({
    required this.firestore,
    required this.auth,
    required this.storage,
  });

  /// 🔑 Get PixVerse API Key from Firebase (with 5-minute cache)
  /// Firebase path: keys/original_pixverse/originalPixverseApiKey
  Future<String> getPixverseApiKey() async {
    try {
      // Cache kontrolü - 5 dakika geçerli
      final now = DateTime.now();
      if (_cachedPixverseApiKey != null && 
          _keyLastFetched != null && 
          now.difference(_keyLastFetched!).inMinutes < 5) {
        log('🔑 Using cached PixVerse API key');
        return _cachedPixverseApiKey!;
      }

      log('🔥 Fetching PixVerse API key from Firebase...');
      final docSnapshot = await firestore
          .collection('keys')
          .doc('original_pixverse')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final apiKey = data?['originalPixverseApiKey'] as String?;
        
        if (apiKey != null && apiKey.isNotEmpty) {
          _cachedPixverseApiKey = apiKey;
          _keyLastFetched = now;
          log('✅ PixVerse API key loaded from Firebase: ${apiKey.substring(0, 10)}...');
          return apiKey;
        }
      }

      // Fallback: Firebase'de yoksa hardcoded key kullan
      log('⚠️ Firebase key not found, using fallback hardcoded key');
      return pixverseOriginalApiKey;
    } catch (e) {
      log('❌ Error fetching PixVerse API key from Firebase: $e');
      // Error durumunda fallback key kullan
      return pixverseOriginalApiKey;
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

  // Pixverse URL'den videoyu indir ve Firebase Storage'a yükle
  Future<String?> uploadPixverseVideoToFirebase({
    required String pixverseUrl,
    required String videoId,
  }) async {
    try {
      final userId = auth.currentUser!.uid;
      log('📥 Downloading video from Pixverse: $pixverseUrl');

      // Videoyu indir
      final response = await http.get(Uri.parse(pixverseUrl));

      if (response.statusCode != 200) {
        log('❌ Failed to download video: ${response.statusCode}');
        return null;
      }

      final videoBytes = response.bodyBytes;
      log('✅ Video downloaded, size: ${videoBytes.length} bytes');

      // Firebase Storage'a yükle
      final fileName =
          'pixverse_videos/$userId/${videoId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final ref = storage.ref().child(fileName);

      final uploadTask = await ref.putData(
        videoBytes,
        SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'userId': userId,
            'videoId': videoId,
            'source': 'pixverse-original',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final firebaseUrl = await uploadTask.ref.getDownloadURL();
      log('✅ Video uploaded to Firebase Storage: $firebaseUrl');

      return firebaseUrl;
    } catch (e) {
      log('❌ Error uploading video to Firebase Storage: $e');
      return null;
    }
  }

  Future<VideoGenerateResponseModel?> videoGeneratePollo(
      VideoGeneratePolloRequestInputModel
          videoGeneratePolloRequestInputModel) async {
    try {
      final response = await http.post(
        Uri.parse('https://pollo.ai/api/platform/generation/pollo/pollo-v1-6'),
        headers: {
          "x-api-key": polloApiKey,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "input": {
            "image": videoGeneratePolloRequestInputModel.image,
            if (videoGeneratePolloRequestInputModel.imageTail != null)
              "imageTail": videoGeneratePolloRequestInputModel.imageTail,
            "prompt": videoGeneratePolloRequestInputModel.prompt,
            "resolution": videoGeneratePolloRequestInputModel.quality,
            "length": videoGeneratePolloRequestInputModel.lenght,
            "seed": videoGeneratePolloRequestInputModel.seed,
          },
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final polloResponse =
            VideoGeneratePolloResponseModel.fromJson(responseData);

        // Get credit requirements from AppBloc safely
        try {
          final appBloc = getIt<AppBloc>();
          final creditRequirements = appBloc.state.generateCreditRequirements;

          log('🔍 Video Generate Debug:');
          log('AppBloc state: ${appBloc.state}');
          log('Credit requirements: $creditRequirements');

          if (creditRequirements != null) {
            // Calculate required credits for video
            int requiredCredits = creditRequirements.videoRequiredCredits;
            log('Required credits: $requiredCredits');

            // Check if user has enough credits
            final userId = auth.currentUser!.uid;
            log('User ID: $userId');

            final userDoc =
                await firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              log('User data keys: ${userData?.keys.toList()}');
              log('Profile info: ${userData?['profile_info']}');

              // Try different possible credit field locations
              dynamic currentCredits = userData?['profile_info']
                      ?['totalCredit'] ??
                  userData?['totalCredit'] ??
                  userData?['profile_info']?['credits'] ??
                  userData?['credits'] ??
                  0;

              log('Current credits: $currentCredits (type: ${currentCredits.runtimeType})');

              if (currentCredits >= requiredCredits) {
                // Determine the correct field path for credits
                String creditFieldPath = 'profile_info.totalCredit';
                if (userData?['totalCredit'] != null) {
                  creditFieldPath = 'totalCredit';
                } else if (userData?['profile_info']?['credits'] != null) {
                  creditFieldPath = 'profile_info.credits';
                } else if (userData?['credits'] != null) {
                  creditFieldPath = 'credits';
                }

                log('Using credit field path: $creditFieldPath');

                // Deduct credits - use direct calculation to preserve data type
                final newCredits = currentCredits - requiredCredits;
                await firestore.collection('users').doc(userId).update({
                  creditFieldPath: newCredits,
                });

                log('✅ Video credits deducted: $requiredCredits, Remaining: ${currentCredits - requiredCredits}');
              } else {
                log('❌ Insufficient credits for video: Required $requiredCredits, Available $currentCredits');
                throw Exception(
                    'Insufficient credits: Required $requiredCredits, Available $currentCredits');
              }
            } else {
              log('❌ User document does not exist');
            }
          } else {
            log('❌ Credit requirements is null');
          }
        } catch (e) {
          log('❌ Error during credit deduction: $e');
          log('Stack trace: ${StackTrace.current}');
          // Continue without credit deduction if there's an error
        }

        // Pollo response'unu VideoGenerateResponseModel formatına dönüştür
        return _convertPolloToVideoGenerateResponse(polloResponse,
            originalRequest: videoGeneratePolloRequestInputModel);
      }
      return null;
    } catch (e) {
      throw Exception('Error occurred while generating video with Pollo: $e');
    }
  }

  Future<VideoGenerateResponseModel?> videoGeneratePixversePollo(
      VideoGeneratePixversePolloRequestInputModel
          videoGeneratePixversePolloRequestInputModel) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://pollo.ai/api/platform/generation/pixverse/pixverse-v4-5'),
        headers: {
          "x-api-key": polloApiKey,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "input": {
            "mode":
                videoGeneratePixversePolloRequestInputModel.mode ?? "normal",
            if (videoGeneratePixversePolloRequestInputModel.image != null)
              "image": videoGeneratePixversePolloRequestInputModel.image,
            if (videoGeneratePixversePolloRequestInputModel.prompt != null)
              "prompt": videoGeneratePixversePolloRequestInputModel.prompt,
            if (videoGeneratePixversePolloRequestInputModel.imageTail != null)
              "imageTail":
                  videoGeneratePixversePolloRequestInputModel.imageTail,
            "length": videoGeneratePixversePolloRequestInputModel.length ?? 5,
            if (videoGeneratePixversePolloRequestInputModel.negativePrompt !=
                null)
              "negativePrompt":
                  videoGeneratePixversePolloRequestInputModel.negativePrompt,
            "seed": videoGeneratePixversePolloRequestInputModel.seed ?? 1,
            "resolution":
                videoGeneratePixversePolloRequestInputModel.resolution ??
                    "540p",
            "style":
                videoGeneratePixversePolloRequestInputModel.style ?? "auto",
            if (videoGeneratePixversePolloRequestInputModel.aspectRatio != null)
              "aspectRatio":
                  videoGeneratePixversePolloRequestInputModel.aspectRatio,
          },
          "webhookUrl": WebhookConstants.webhookUrl,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final polloResponse =
            VideoGeneratePolloResponseModel.fromJson(responseData);

        // Get credit requirements from AppBloc safely
        try {
          final appBloc = getIt<AppBloc>();
          final creditRequirements = appBloc.state.generateCreditRequirements;

          log('🔍 Pixverse Video Generate Debug:');
          log('AppBloc state: ${appBloc.state}');
          log('Credit requirements: $creditRequirements');

          if (creditRequirements != null) {
            // Calculate required credits for video
            int requiredCredits = creditRequirements.videoRequiredCredits;
            log('Required credits: $requiredCredits');

            // Check if user has enough credits
            final userId = auth.currentUser!.uid;
            log('User ID: $userId');

            final userDoc =
                await firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              log('User data keys: ${userData?.keys.toList()}');
              log('Profile info: ${userData?['profile_info']}');

              // Try different possible credit field locations
              dynamic currentCredits = userData?['profile_info']
                      ?['totalCredit'] ??
                  userData?['totalCredit'] ??
                  userData?['profile_info']?['credits'] ??
                  userData?['credits'] ??
                  0;

              log('Current credits: $currentCredits (type: ${currentCredits.runtimeType})');

              if (currentCredits >= requiredCredits) {
                // Determine the correct field path for credits
                String creditFieldPath = 'profile_info.totalCredit';
                if (userData?['totalCredit'] != null) {
                  creditFieldPath = 'totalCredit';
                } else if (userData?['profile_info']?['credits'] != null) {
                  creditFieldPath = 'profile_info.credits';
                } else if (userData?['credits'] != null) {
                  creditFieldPath = 'credits';
                }

                log('Using credit field path: $creditFieldPath');

                // Deduct credits - use direct calculation to preserve data type
                final newCredits = currentCredits - requiredCredits;
                await firestore.collection('users').doc(userId).update({
                  creditFieldPath: newCredits,
                });

                log('✅ Pixverse video credits deducted: $requiredCredits, Remaining: ${currentCredits - requiredCredits}');
              } else {
                log('❌ Insufficient credits for pixverse video: Required $requiredCredits, Available $currentCredits');
                throw Exception(
                    'Insufficient credits: Required $requiredCredits, Available $currentCredits');
              }
            } else {
              log('❌ User document does not exist');
            }
          } else {
            log('❌ Credit requirements is null');
          }
        } catch (e) {
          log('❌ Error during credit deduction: $e');
          log('Stack trace: ${StackTrace.current}');
          // Continue without credit deduction if there's an error
        }

        // Pollo response'unu VideoGenerateResponseModel formatına dönüştür
        return _convertPixversePolloToVideoGenerateResponse(polloResponse,
            originalRequest: videoGeneratePixversePolloRequestInputModel);
      } else if (response.statusCode == 400) {
        // HTTP 400 hatası durumunda daha detaylı hata mesajı
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Bad Request';
        throw Exception('Pixverse API Error (400): $errorMessage');
      } else {
        // Diğer HTTP hataları
        throw Exception(
            'Pixverse API Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(
          'Error occurred while generating video with Pixverse: $e');
    }
  }

  // checkPolloStatus method'u kaldırıldı - artık webhook kullanılıyor

  // Pollo.ai response'unu VideoGenerateResponseModel formatına dönüştür
  VideoGenerateResponseModel? _convertPolloToVideoGenerateResponse(
      VideoGeneratePolloResponseModel polloResponse,
      {VideoGeneratePolloRequestInputModel? originalRequest}) {
    if (polloResponse.data == null) return null;

    final data = polloResponse.data!;
    String? outputUrl;
    String status = 'processing';

    // Video URL'ini al
    if (data.generations != null && data.generations!.isNotEmpty) {
      for (final generation in data.generations!) {
        if (generation.url != null && generation.url!.isNotEmpty) {
          outputUrl = generation.url;
          break;
        }
      }
    }

    // Status'u belirle - generations array'indeki status'u da kontrol et
    bool isFailed = false;
    if (data.generations != null && data.generations!.isNotEmpty) {
      for (final generation in data.generations!) {
        if (generation.status == 'failed') {
          isFailed = true;
          break;
        }
      }
    }

    if (isFailed || data.status == 'failed') {
      status = 'failed';
    } else if (data.status == 'succeed' || outputUrl != null) {
      status = 'succeeded';
    } else if (data.status == 'waiting') {
      status = 'starting';
    }

    // Input bilgilerini oluştur
    Input? input;
    if (originalRequest != null) {
      input = Input(
        image: originalRequest.image,
        prompt: originalRequest.prompt,
        aspectRatio: originalRequest.aspectRatio,
        motionMode: originalRequest.motion,
        seed: originalRequest.seed,
        quality: originalRequest.quality,
        style: originalRequest.style,
        duration: originalRequest.numFrames,
        lastFrameImage: originalRequest.imageTail,
      );
    }

    return VideoGenerateResponseModel(
      id: data.taskId,
      model: 'pollo-1.6',
      version: '1.6',
      input: input,
      status: status,
      output: outputUrl,
      createdAt: DateTime.now().toIso8601String(),
      completedAt: (outputUrl != null || status == 'failed')
          ? DateTime.now().toIso8601String()
          : null,
      fromTemplate: true, // Artık tüm videolar template olarak işaretleniyor
      templateName: 'Custom Video',
    );
  }

  // Pixverse.ai response'unu VideoGenerateResponseModel formatına dönüştür
  VideoGenerateResponseModel? _convertPixversePolloToVideoGenerateResponse(
      VideoGeneratePolloResponseModel polloResponse,
      {VideoGeneratePixversePolloRequestInputModel? originalRequest}) {
    if (polloResponse.data == null) return null;

    final data = polloResponse.data!;
    String? outputUrl;
    String status = 'processing';

    // Video URL'ini al
    if (data.generations != null && data.generations!.isNotEmpty) {
      for (final generation in data.generations!) {
        if (generation.url != null && generation.url!.isNotEmpty) {
          outputUrl = generation.url;
          break;
        }
      }
    }

    // Status'u belirle - generations array'indeki status'u da kontrol et
    bool isFailed = false;
    if (data.generations != null && data.generations!.isNotEmpty) {
      for (final generation in data.generations!) {
        if (generation.status == 'failed') {
          isFailed = true;
          break;
        }
      }
    }

    if (isFailed || data.status == 'failed') {
      status = 'failed';
    } else if (data.status == 'succeed' || outputUrl != null) {
      status = 'succeeded';
    } else if (data.status == 'waiting') {
      status = 'starting';
    }

    // Input bilgilerini oluştur
    Input? input;
    if (originalRequest != null) {
      input = Input(
        image: originalRequest.image,
        prompt: originalRequest.prompt,
        aspectRatio:
            originalRequest.aspectRatio, // Pixverse'de aspect ratio var
        motionMode: null, // Pixverse'de motion mode yok
        seed: originalRequest.seed,
        quality: originalRequest.resolution,
        style: originalRequest.style,
        duration: originalRequest.length ?? 5,
        lastFrameImage: originalRequest.imageTail,
      );
    }

    return VideoGenerateResponseModel(
      id: data.taskId,
      model: 'pixverse-4.5',
      version: '4.5',
      input: input,
      status: status,
      output: outputUrl,
      createdAt: DateTime.now().toIso8601String(),
      completedAt: (outputUrl != null || status == 'failed')
          ? DateTime.now().toIso8601String()
          : null,
      fromTemplate: true, // Artık tüm videolar template olarak işaretleniyor
      templateName: 'Custom Video',
    );
  }

  Future<EventStatus?> addUserVideoPollo(
    VideoGenerateResponseModel userVideo,
  ) async {
    try {
      final userId = auth.currentUser!.uid;

      // Saf JSON map elde et
      final videoData = jsonDecode(jsonEncode(userVideo.toJson()));

      await firestore.collection('users').doc(userId).update({
        'userGeneratedVideos': FieldValue.arrayUnion([videoData]),
        'hasPendingVideos': true // Pending video var
      });

      return EventStatus.success;
    } catch (e) {
      log('addUserVideoPollo error: $e');
      return EventStatus.failure;
    }
  }

  // updatePolloTaskStatus method'u kaldırıldı - artık Firebase Functions webhook kullanılıyor

  // downloadAndUploadPolloVideoToFirebase method'u kaldırıldı - artık Firebase Functions webhook kullanılıyor

  /// ========== PIXVERSE ORIGINAL API METHODS ==========

  /// 1. Upload image to Pixverse Original API
  Future<PixverseOriginalImageUploadResponse?> uploadImageToPixverseOriginal(
      String imageUrl) async {
    try {
      final traceId = const Uuid().v4();
      final apiKey = await getPixverseApiKey(); // 🔑 Dynamic from Firebase

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://app-api.pixverse.ai/openapi/v2/image/upload'),
      );

      request.headers.addAll({
        'API-KEY': apiKey,
        'Ai-trace-id': traceId,
      });

      request.fields['image_url'] = imageUrl;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final uploadResponse =
            PixverseOriginalImageUploadResponse.fromJson(responseData);

        if (uploadResponse.errCode == 0) {
          log('✅ Pixverse Original image uploaded successfully: ${uploadResponse.resp?.imgId}');
          return uploadResponse;
        } else {
          log('❌ Pixverse Original image upload error: ${uploadResponse.errMsg}');
          throw Exception('Image upload error: ${uploadResponse.errMsg}');
        }
      } else {
        log('❌ Pixverse Original image upload HTTP error: ${response.statusCode}');
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error uploading image to Pixverse Original: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  /// 2. Generate video with Pixverse Original API
  Future<VideoGenerateResponseModel?> generateVideoPixverseOriginal({
    required int imgId,
    required int templateId,
    required String prompt,
    int duration = 5,
    String quality = '540p',
    String motionMode = 'normal',
    int seed = 0,
    String? templateName,
  }) async {
    try {
      final traceId = const Uuid().v4();
      final apiKey = await getPixverseApiKey(); // 🔑 Dynamic from Firebase

      final response = await http.post(
        Uri.parse('https://app-api.pixverse.ai/openapi/v2/video/img/generate'),
        headers: {
          'API-KEY': apiKey,
          'Ai-trace-id': traceId,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'duration': duration,
          'img_id': imgId,
          'model': 'v4.5',
          'motion_mode': motionMode,
          'prompt': prompt,
          'quality': quality,
          'template_id': templateId,
          'seed': seed,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log('📥 Generate Response RAW: $responseData');

        final generateResponse =
            PixverseOriginalVideoGenerateResponse.fromJson(responseData);

        log('📦 Parsed Response - ErrCode: ${generateResponse.errCode}');
        log('📦 Parsed Response - Resp: ${generateResponse.resp}');
        log('📦 Parsed Response - Video ID: ${generateResponse.resp?.videoId}');
        log('📦 Parsed Response - Credits: ${generateResponse.resp?.credits}');

        if (generateResponse.errCode == 0 &&
            generateResponse.resp?.videoId != null) {
          log('✅ Pixverse Original video generation started: ${generateResponse.resp!.videoId}');

          // Get credit requirements from AppBloc safely
          try {
            final appBloc = getIt<AppBloc>();
            final creditRequirements = appBloc.state.generateCreditRequirements;

            if (creditRequirements != null) {
              int requiredCredits =
                  creditRequirements.videoTemplateRequiredCredits;
              log('Required credits: $requiredCredits');

              final userId = auth.currentUser!.uid;
              final userDoc =
                  await firestore.collection('users').doc(userId).get();

              if (userDoc.exists) {
                final userData = userDoc.data();
                dynamic currentCredits = userData?['profile_info']
                        ?['totalCredit'] ??
                    userData?['totalCredit'] ??
                    userData?['profile_info']?['credits'] ??
                    userData?['credits'] ??
                    0;

                log('Current credits: $currentCredits');

                if (currentCredits >= requiredCredits) {
                  String creditFieldPath = 'profile_info.totalCredit';
                  if (userData?['totalCredit'] != null) {
                    creditFieldPath = 'totalCredit';
                  } else if (userData?['profile_info']?['credits'] != null) {
                    creditFieldPath = 'profile_info.credits';
                  } else if (userData?['credits'] != null) {
                    creditFieldPath = 'credits';
                  }

                  final newCredits = currentCredits - requiredCredits;
                  await firestore.collection('users').doc(userId).update({
                    creditFieldPath: newCredits,
                  });

                  log('✅ Pixverse Original credits deducted: $requiredCredits, Remaining: ${currentCredits - requiredCredits}');
                } else {
                  log('❌ Insufficient credits: Required $requiredCredits, Available $currentCredits');
                  throw Exception(
                      'Insufficient credits: Required $requiredCredits, Available $currentCredits');
                }
              }
            }
          } catch (e) {
            log('❌ Error during credit deduction: $e');
            // Continue without credit deduction if there's an error
          }

          // Convert to VideoGenerateResponseModel
          final videoId = generateResponse.resp!.videoId.toString();
          log('🎯 Creating VideoGenerateResponseModel with ID: $videoId');
          log('💳 Credits used: ${generateResponse.resp!.credits}');
          log('🆔 Template ID: $templateId');
          log('🎬 Video ID: ${generateResponse.resp!.videoId}');

          return VideoGenerateResponseModel(
            id: videoId,
            model: 'pixverse-original-4.5',
            version: '4.5',
            status: 'processing',
            createdAt: DateTime.now().toIso8601String(),
            fromTemplate: true,
            traceId: traceId,
            templateId: templateId,
            videoId: generateResponse.resp!.videoId,
            templateName: templateName,
            input: Input(
              prompt: prompt,
              quality: quality,
              duration: duration,
              seed: seed,
            ),
          );
        } else {
          log('❌ Pixverse Original video generation error: ${generateResponse.errMsg}');
          throw Exception(
              'Video generation error: ${generateResponse.errMsg ?? "Unknown error"}');
        }
      } else {
        log('❌ Pixverse Original video generation HTTP error: ${response.statusCode}');
        log('Response body: ${response.body}');
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error generating video with Pixverse Original: $e');
      throw Exception('Error generating video: $e');
    }
  }

  /// 3a. Check video status ONCE (for app resume)
  Future<VideoGenerateResponseModel?> checkPixverseOriginalVideoStatusOnce({
    required String videoId,
    required String traceId,
  }) async {
    try {
      log('🔍 Checking Pixverse Original video status once: $videoId');
      final apiKey = await getPixverseApiKey(); // 🔑 Dynamic from Firebase

      final response = await http.get(
        Uri.parse(
            'https://app-api.pixverse.ai/openapi/v2/video/result/$videoId'),
        headers: {
          'API-KEY': apiKey,
          'Ai-trace-id': traceId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final resultResponse =
            PixverseOriginalVideoResultResponse.fromJson(responseData);

        if (resultResponse.errCode == 0 && resultResponse.resp != null) {
          final resp = resultResponse.resp!;

          // Status: 0 = processing, 1 = succeeded, 2 = failed
          if (resp.status == 1 && resp.url != null) {
            log('✅ Video completed! Pixverse URL: ${resp.url}');

            // Pixverse URL'den videoyu Firebase Storage'a yükle
            String? firebaseUrl;
            try {
              firebaseUrl = await uploadPixverseVideoToFirebase(
                pixverseUrl: resp.url!,
                videoId: videoId,
              );

              if (firebaseUrl != null) {
                log('✅ Video uploaded to Firebase Storage: $firebaseUrl');
              } else {
                log('⚠️ Failed to upload to Firebase Storage, using Pixverse URL');
                firebaseUrl = resp.url; // Fallback to Pixverse URL
              }
            } catch (uploadError) {
              log('⚠️ Error uploading to Firebase Storage: $uploadError');
              firebaseUrl = resp.url; // Fallback to Pixverse URL
            }

            return VideoGenerateResponseModel(
              id: resp.id.toString(),
              model: 'pixverse-original-4.5',
              version: '4.5',
              status: 'succeeded',
              output: firebaseUrl,
              createdAt: resp.createTime,
              completedAt: resp.modifyTime,
              fromTemplate: true,
              traceId: traceId,
              videoId: resp.id,
              input: Input(
                prompt: resp.prompt,
                seed: resp.seed,
              ),
            );
          } else if (resp.status == 2) {
            log('❌ Video failed');

            return VideoGenerateResponseModel(
              id: resp.id.toString(),
              model: 'pixverse-original-4.5',
              version: '4.5',
              status: 'failed',
              error: 'Video generation failed',
              createdAt: resp.createTime,
              completedAt: resp.modifyTime,
              fromTemplate: true,
              traceId: traceId,
              videoId: resp.id,
            );
          } else {
            // Still processing
            log('⏳ Video still processing (status: ${resp.status})');
            return VideoGenerateResponseModel(
              id: resp.id.toString(),
              model: 'pixverse-original-4.5',
              version: '4.5',
              status: 'processing',
              createdAt: resp.createTime,
              fromTemplate: true,
              traceId: traceId,
              videoId: resp.id,
            );
          }
        }
      }

      return null;
    } catch (e) {
      log('⚠️ Error checking video status: $e');
      return null;
    }
  }

  /// 3b. Poll video status from Pixverse Original API
  Future<VideoGenerateResponseModel?> pollPixverseOriginalVideoStatus({
    required String videoId,
    required String traceId,
    int maxAttempts = 60, // 60 attempts = 5 minutes with 5 second intervals
    Duration pollInterval = const Duration(seconds: 5),
  }) async {
    int attempt = 0;
    final apiKey = await getPixverseApiKey(); // 🔑 Get once before loop

    while (attempt < maxAttempts) {
      try {
        attempt++;
        log('🔄 Polling Pixverse Original video status (Attempt $attempt/$maxAttempts): $videoId');

        final response = await http.get(
          Uri.parse(
              'https://app-api.pixverse.ai/openapi/v2/video/result/$videoId'),
          headers: {
            'API-KEY': apiKey,
            'Ai-trace-id': traceId,
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final resultResponse =
              PixverseOriginalVideoResultResponse.fromJson(responseData);

          if (resultResponse.errCode == 0 && resultResponse.resp != null) {
            final resp = resultResponse.resp!;

            // Status: 0 = processing, 1 = succeeded, 2 = failed
            if (resp.status == 1 && resp.url != null) {
              log('✅ Pixverse Original video completed: ${resp.url}');

              return VideoGenerateResponseModel(
                id: resp.id.toString(),
                model: 'pixverse-original-4.5',
                version: '4.5',
                status: 'succeeded',
                output: resp.url,
                createdAt: resp.createTime,
                completedAt: resp.modifyTime,
                fromTemplate: true,
                traceId: traceId,
                videoId: resp.id,
                input: Input(
                  prompt: resp.prompt,
                  seed: resp.seed,
                ),
              );
            } else if (resp.status == 2) {
              log('❌ Pixverse Original video failed');

              return VideoGenerateResponseModel(
                id: resp.id.toString(),
                model: 'pixverse-original-4.5',
                version: '4.5',
                status: 'failed',
                error: 'Video generation failed',
                createdAt: resp.createTime,
                completedAt: resp.modifyTime,
                fromTemplate: true,
                traceId: traceId,
                videoId: resp.id,
              );
            } else {
              // Still processing, continue polling
              log('⏳ Video still processing... (status: ${resp.status})');
            }
          } else {
            log('⚠️ Unexpected response: ${resultResponse.errMsg}');
          }
        } else {
          log('⚠️ HTTP error during polling: ${response.statusCode}');
        }

        // Wait before next poll
        if (attempt < maxAttempts) {
          await Future.delayed(pollInterval);
        }
      } catch (e) {
        log('⚠️ Error during polling (attempt $attempt): $e');

        // Wait before retry
        if (attempt < maxAttempts) {
          await Future.delayed(pollInterval);
        }
      }
    }

    // Max attempts reached
    log('❌ Pixverse Original polling timeout after $maxAttempts attempts');
    return VideoGenerateResponseModel(
      id: videoId,
      model: 'pixverse-original-4.5',
      version: '4.5',
      status: 'failed',
      error: 'Polling timeout',
      createdAt: DateTime.now().toIso8601String(),
      fromTemplate: true,
      traceId: traceId,
    );
  }
}
