import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ginly/app/features/video_generate/model/video_generate_pixverse_pollo_request_model.dart';
import 'package:ginly/app/features/video_generate/model/video_generate_pollo_response_model.dart';
import 'package:ginly/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginly/core/core.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:ginly/app/bloc/app_bloc.dart';

@injectable
class TemplateGenerateUsecase {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  TemplateGenerateUsecase({
    required this.firestore,
    required this.auth,
    required this.storage,
  });

  Future<String> uploadUserImage(File imageFile) async {
    final userId = auth.currentUser!.uid;

    try {
      final ref = storage.ref().child(
          "template_uploads/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg");

      final bytes = await imageFile.readAsBytes();
      final uploadTask = await ref.putData(bytes);

      // Dosyayı public yap (Fal AI erişimi için)
      await ref.updateMetadata(SettableMetadata(
        cacheControl: 'public, max-age=3600',
        contentType: 'image/jpeg',
      ));

      final url = await uploadTask.ref.getDownloadURL();
      return url;
      // Daha kısa dosya adı kullan
      // putFile yerine putData kullan - görüntüyü byte olarak oku
    } catch (e) {
      log('uploadUserImage error: $e');
      throw Exception('Error uploading user image: $e');
    }
  }

  Future<VideoGenerateResponseModel?> generateTemplateVideo(
      VideoGeneratePixversePolloRequestInputModel requestModel) async {
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
            "mode": requestModel.mode ?? "normal",
            if (requestModel.image != null) "image": requestModel.image,
            if (requestModel.prompt != null) "prompt": requestModel.prompt,
            if (requestModel.imageTail != null)
              "imageTail": requestModel.imageTail,
            "length": requestModel.length ?? 5,
            if (requestModel.negativePrompt != null)
              "negativePrompt": requestModel.negativePrompt,
            "seed": requestModel.seed ?? 1,
            "resolution": requestModel.resolution ?? "540p",
            "style": requestModel.style ?? "auto",
            if (requestModel.aspectRatio != null)
              "aspectRatio": requestModel.aspectRatio,
          },
          "webhookUrl":
              "https://us-central1-disciplify-26970.cloudfunctions.net/polloWebhook"
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
                // Deduct credits - use direct calculation to preserve data type
                final newCredits = currentCredits - requiredCredits;
                await firestore.collection('users').doc(userId).update({
                  'profile_info.totalCredit': newCredits,
                });

                log('Template credits deducted: $requiredCredits, Remaining: ${currentCredits - requiredCredits}');
              } else {
                log('Insufficient credits for template: Required $requiredCredits, Available $currentCredits');
                throw Exception(
                    'Insufficient credits: Required $requiredCredits, Available $currentCredits');
              }
            }
          }
        } catch (e) {
          log('Error during credit deduction: $e');
          // Continue without credit deduction if there's an error
        }

        // Pollo response'unu VideoGenerateResponseModel formatına dönüştür
        return _convertPixversePolloToVideoGenerateResponse(polloResponse,
            originalRequest: requestModel);
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Bad Request';
        throw Exception('Template API Error (400): $errorMessage');
      } else {
        throw Exception(
            'Template API Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while generating template video: $e');
    }
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
      log('addUserVideo error: $e');
      return EventStatus.failure;
    }
  }

  // Pixverse.ai response'unu VideoGenerateResponseModel formatına dönüştür
  VideoGenerateResponseModel? _convertPixversePolloToVideoGenerateResponse(
      VideoGeneratePolloResponseModel polloResponse,
      {VideoGeneratePixversePolloRequestInputModel? originalRequest}) {
    if (polloResponse.data == null) return null;

    final data = polloResponse.data!;
    String? outputUrl;
    String status = 'processing';

    if (data.generations != null && data.generations!.isNotEmpty) {
      for (final generation in data.generations!) {
        if (generation.url != null && generation.url!.isNotEmpty) {
          outputUrl = generation.url;
          break;
        }
      }
    }

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

    Input? input;
    if (originalRequest != null) {
      input = Input(
        image: originalRequest.image,
        prompt: originalRequest.prompt,
        aspectRatio: originalRequest.aspectRatio,
        motionMode: null,
        seed: originalRequest.seed,
        quality: originalRequest.resolution,
        style: originalRequest.style,
        duration: originalRequest.length ?? 5,
        lastFrameImage: originalRequest.imageTail,
      );
    }

    return VideoGenerateResponseModel(
      id: data.taskId,
      model: 'pixverse-4.5-template',
      version: '4.5',
      input: input,
      status: status,
      output: outputUrl,
      createdAt: DateTime.now().toIso8601String(),
      completedAt: (outputUrl != null || status == 'failed')
          ? DateTime.now().toIso8601String()
          : null,
      fromTemplate: true, // Template'den üretildiğini belirt
      templateName: originalRequest?.templateName,
    );
  }
}
