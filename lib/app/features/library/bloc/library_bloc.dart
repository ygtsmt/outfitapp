import 'dart:developer';
import 'package:ginfit/app/features/library/data/library_usecase.dart';
import 'package:ginfit/app/features/text_to_image/model/text_to_image_generation_response_model_for_black_forest_label.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginfit/app/features/video_generate/model/pixverse_original_video_result_model.dart';
import 'package:ginfit/core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ginfit/app/features/video_generate/data/video_generate_usecase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'library_event.dart';
part 'library_state.dart';

@singleton
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryUsecase generateUseCase;
  final VideoGenerateUsecase videoGenerateUsecase;

  LibraryBloc({
    required this.generateUseCase,
    required this.videoGenerateUsecase,
  }) : super(const LibraryState()) {
    on<GetUserGeneratedVideosEvent>((event, emit) async {
      emit(state.copyWith(gettingVideoStatus: EventStatus.processing));
      try {
        final result = await generateUseCase.getUserGeneratedVideos();

        // complete_at'e göre sıralama (yeniden eskiye)
        result.sort((a, b) {
          final dateA = DateTime.parse(
              a.completedAt ?? a.createdAt ?? DateTime.now().toString());
          final dateB = DateTime.parse(
              (b.completedAt) ?? b.createdAt ?? DateTime.now().toString());
          return dateB.compareTo(dateA); // büyük tarih önce gelsin
        });

        emit(state.copyWith(
          gettingVideoStatus: EventStatus.success,
          userGeneratedVideos: result,
        ));
      } catch (e) {
        log(e.toString());
        emit(state.copyWith(gettingVideoStatus: EventStatus.failure));
      }
      emit(state.copyWith(gettingVideoStatus: EventStatus.idle));
    });
    on<GetUserGeneratedImagesEvent>((event, emit) async {
      emit(state.copyWith(gettingImagesStatus: EventStatus.processing));
      try {
        final result = await generateUseCase.getUserGeneratedImages();

        // complete_at'e göre sıralama (yeniden eskiye)
        result.sort((a, b) {
          final dateA =
              DateTime.parse(a.createdAt ?? DateTime.now().toString());
          final dateB =
              DateTime.parse(b.createdAt ?? DateTime.now().toString());
          return dateB.compareTo(dateA); // büyük tarih önce gelsin
        });

        emit(state.copyWith(
          gettingImagesStatus: EventStatus.success,
          userGeneratedImages: result,
        ));
      } catch (e) {
        log(e.toString());
        emit(state.copyWith(gettingImagesStatus: EventStatus.failure));
      }
      emit(state.copyWith(gettingImagesStatus: EventStatus.idle));
    });
    on<GetUserGeneratedRealtimeImagesEvent>((event, emit) async {
      emit(state.copyWith(gettingRealtimeImagesStatus: EventStatus.processing));
      try {
        final result = await generateUseCase.getUserGeneratedRealtimeImages();

        // complete_at'e göre sıralama (yeniden eskiye)
        result.sort((a, b) {
          final dateA =
              DateTime.parse(a.createdAt ?? DateTime.now().toString());
          final dateB =
              DateTime.parse(b.createdAt ?? DateTime.now().toString());
          return dateB.compareTo(dateA); // büyük tarih önce gelsin
        });

        emit(state.copyWith(
          gettingRealtimeImagesStatus: EventStatus.success,
          userGeneratedRealtimeImages: result,
        ));
      } catch (e) {
        log(e.toString());
        emit(state.copyWith(gettingRealtimeImagesStatus: EventStatus.failure));
      }
      emit(state.copyWith(gettingRealtimeImagesStatus: EventStatus.idle));
    });

    on<UpdateUserVideoOutputEvent>((event, emit) async {
      emit(state.copyWith(videoForUpdateStatus: EventStatus.processing));
      final result = await generateUseCase.updateOutputById(
        event.newModel,
      );

      // ignore: prefer_is_empty
      if (result == EventStatus.success) {
        emit(state.copyWith(videoForUpdateStatus: EventStatus.success));
      } else {
        emit(state.copyWith(
          videoForUpdateStatus: EventStatus.failure,
        ));
      }
      emit(state.copyWith(videoForUpdateStatus: EventStatus.idle));
    });

    on<SoftDeleteUserGeneratedVideoEvent>((event, emit) async {
      emit(state.copyWith(videoSoftDeleteStatus: EventStatus.processing));
      try {
        final result = await generateUseCase.softDeleteUserGeneratedVideo(
          videoId: event.videoId,
        );

        if (result == EventStatus.success) {
          emit(state.copyWith(videoSoftDeleteStatus: EventStatus.success));
          // Video listesini yeniden çek
          getIt<LibraryBloc>().add(const GetUserGeneratedVideosEvent());
        } else {
          emit(state.copyWith(videoSoftDeleteStatus: EventStatus.failure));
        }
      } catch (e) {
        emit(state.copyWith(videoSoftDeleteStatus: EventStatus.failure));
      }
      emit(state.copyWith(videoSoftDeleteStatus: EventStatus.idle));
    });

    on<SoftDeleteImageEvent>((event, emit) async {
      emit(state.copyWith(imageSoftDeleteStatus: EventStatus.processing));
      try {
        final result = await generateUseCase.softDeleteImage(
          imageId: event.imageId,
        );

        if (result == EventStatus.success) {
          emit(state.copyWith(imageSoftDeleteStatus: EventStatus.success));
          // Image listesini yeniden çek
          getIt<LibraryBloc>().add(const GetUserGeneratedImagesEvent());
        } else {
          emit(state.copyWith(imageSoftDeleteStatus: EventStatus.failure));
        }
      } catch (e) {
        emit(state.copyWith(imageSoftDeleteStatus: EventStatus.failure));
      }
      emit(state.copyWith(imageSoftDeleteStatus: EventStatus.idle));
    });

    on<SoftDeleteRealtimeImageEvent>((event, emit) async {
      print(
          'LibraryBloc - SoftDeleteRealtimeImageEvent started for ID: ${event.imageId}');
      emit(state.copyWith(
          realtimeImageSoftDeleteStatus: EventStatus.processing));
      try {
        final result = await generateUseCase.softDeleteRealtimeImage(
          imageId: event.imageId,
        );

        print('LibraryBloc - SoftDeleteRealtimeImageEvent result: $result');

        if (result == EventStatus.success) {
          print(
              'LibraryBloc - SoftDeleteRealtimeImageEvent success, emitting success state');
          emit(state.copyWith(
              realtimeImageSoftDeleteStatus: EventStatus.success));
          // Realtime image listesini yeniden çek
          getIt<LibraryBloc>().add(const GetUserGeneratedRealtimeImagesEvent());
        } else {
          print(
              'LibraryBloc - SoftDeleteRealtimeImageEvent failed, emitting failure state');
          emit(state.copyWith(
              realtimeImageSoftDeleteStatus: EventStatus.failure));
        }
      } catch (e) {
        print('LibraryBloc - SoftDeleteRealtimeImageEvent error: $e');
        emit(
            state.copyWith(realtimeImageSoftDeleteStatus: EventStatus.failure));
      }
      emit(state.copyWith(realtimeImageSoftDeleteStatus: EventStatus.idle));
    });

    on<RefreshUserVideosEvent>((event, emit) async {
      emit(state.copyWith(gettingVideoStatus: EventStatus.processing));
      try {
        final result = await generateUseCase.getUserGeneratedVideos();

        // complete_at'e göre sıralama (yeniden eskiye)
        result.sort((a, b) {
          final dateA = DateTime.parse(
              a.completedAt ?? a.createdAt ?? DateTime.now().toString());
          final dateB = DateTime.parse(
              (b.completedAt) ?? b.createdAt ?? DateTime.now().toString());
          return dateB.compareTo(dateA); // büyük tarih önce gelsin
        });

        emit(state.copyWith(
          gettingVideoStatus: EventStatus.success,
          userGeneratedVideos: result,
        ));
      } catch (e) {
        log(e.toString());
        emit(state.copyWith(gettingVideoStatus: EventStatus.failure));
      }
      emit(state.copyWith(gettingVideoStatus: EventStatus.idle));
    });

    on<CheckVideoStatusesEvent>((event, emit) async {
      try {
        emit(state.copyWith(checkVideoStatusesStatus: EventStatus.processing));

        // Library'deki starting status'lu ve output boş olan videoları bul
        final startingVideos = state.userGeneratedVideos
                ?.where((video) =>
                    video?.status == 'starting' &&
                    (video?.output == null || video?.output?.length == 0))
                .toList() ??
            [];

        if (startingVideos.isEmpty) {
          print('No starting videos with empty output found');
          emit(state.copyWith(checkVideoStatusesStatus: EventStatus.success));
          return;
        }

        print('Found ${startingVideos.length} starting videos to check status');

        // Her video için Pollo.ai'ya status check yap
        for (final video in startingVideos) {
          try {
            if (video?.id == null) continue;

            print('Checking status for video ID: ${video?.id}');

            // Pollo.ai API'den status check yap
            final statusResponse =
                await generateUseCase.checkPolloStatus(video?.id ?? '');

            if (statusResponse != null) {
              print(
                  'Status response for ${video?.id}: ${statusResponse.status}');

              // Eğer video completed veya failed olduysa, Firebase'i güncelle
              if (statusResponse.status == 'completed' ||
                  statusResponse.status == 'failed') {
                // Bu durumda webhook zaten tetiklenmiş olmalı, sadece log
                print(
                    'Video ${video?.id} status: ${statusResponse.status} - webhook should handle this');

                // Eğer status failed ise, Firebase'deki modeli güncelle
                if (statusResponse.status == 'failed') {
                  try {
                    print(
                        'Updating Firebase model status to failed for video: ${video?.id}');

                    // Firebase'deki userGeneratedVideos array'inde video'yu bul ve status'u güncelle
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId != null) {
                      final db = FirebaseFirestore.instance;
                      final userDoc =
                          await db.collection('users').doc(userId).get();

                      if (userDoc.exists) {
                        final userData = userDoc.data();
                        final userGeneratedVideos =
                            userData?['userGeneratedVideos']
                                    as List<dynamic>? ??
                                [];

                        // Video'yu bul ve status'u güncelle
                        final updatedVideos = userGeneratedVideos.map((v) {
                          if (v['id'] == video?.id) {
                            return {
                              ...v,
                              'status': 'failed',
                              'error': statusResponse.error ??
                                  'Video generation failed', // Hata mesajını ekle
                              'completedAt': DateTime.now().toIso8601String(),
                            };
                          }
                          return v;
                        }).toList();

                        // Firebase'i güncelle
                        await db.collection('users').doc(userId).update({
                          'userGeneratedVideos': updatedVideos,
                          'lastVideoUpdate': DateTime.now().toIso8601String(),
                        });

                        print(
                            '✅ Successfully updated video status to failed in Firebase for video: ${video?.id}');
                      }
                    }
                  } catch (updateError) {
                    print(
                        '❌ Error updating Firebase model status: $updateError');
                  }
                }
              }
            }
          } catch (e) {
            print('Error checking status for video ${video?.id}: $e');
          }
        }

        emit(state.copyWith(checkVideoStatusesStatus: EventStatus.success));
      } catch (e) {
        print('Error in _onCheckVideoStatuses: $e');
        emit(state.copyWith(
          checkVideoStatusesStatus: EventStatus.failure,
          errorMessage: e.toString(),
        ));
      }
    });

    on<CheckPendingPixverseOriginalVideosEvent>((event, emit) async {
      try {
        log('🔍 Checking pending Pixverse Original videos...');

        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          log('❌ User not logged in');
          return;
        }

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (!userDoc.exists) {
          log('❌ User document not found');
          return;
        }

        final userData = userDoc.data();
        final videos =
            userData?['userGeneratedVideos'] as List<dynamic>? ?? [];

        // Processing statusündeki Pixverse Original videoları filtrele
        final pendingVideos = videos.where((video) {
          return video['status'] == 'processing' &&
              video['model'] == 'pixverse-original-4.5' &&
              (video['output'] == null || video['output'] == '') &&
              video['id'] != null &&
              video['traceId'] != null;
        }).toList();

        if (pendingVideos.isEmpty) {
          log('✅ No pending Pixverse Original videos');
          return;
        }

        log('📋 Found ${pendingVideos.length} pending Pixverse Original videos');

        // Her pending video için status check (BİR KEZ, POLLING DEĞİL!)
        for (final videoData in pendingVideos) {
          final videoId = videoData['id'] as String;
          final traceId = videoData['traceId'] as String;

          try {
            log('🔍 Checking video ID: $videoId');

            // Tek seferlik status check
            final response = await videoGenerateUsecase
                .checkPixverseOriginalVideoStatusOnce(
              videoId: videoId,
              traceId: traceId,
            );

            if (response != null) {
              log('📥 Status response for $videoId: ${response.status}');

              // Video tamamlanmışsa Firebase'i güncelle
              if (response.status == 'succeeded' && response.output != null) {
                log('✅ Video $videoId completed! Updating Firebase...');
                await _updateVideoInFirebase(
                  userId: userId,
                  videoId: videoId,
                  status: 'succeeded',
                  output: response.output,
                  completedAt: response.completedAt ?? DateTime.now().toIso8601String(),
                );
              } else if (response.status == 'failed') {
                log('❌ Video $videoId failed! Updating Firebase...');
                await _updateVideoInFirebase(
                  userId: userId,
                  videoId: videoId,
                  status: 'failed',
                  output: null,
                  completedAt: response.completedAt ?? DateTime.now().toIso8601String(),
                );
              } else {
                log('⏳ Video $videoId still processing (status: ${response.status})');
              }
            }
          } catch (e) {
            log('⚠️ Error checking video $videoId: $e');
            // Continue with next video
          }
        }

        log('✅ Pending videos check completed');

        // Video listesini yenile
        getIt<LibraryBloc>().add(const RefreshUserVideosEvent());
      } catch (e) {
        log('❌ Error in CheckPendingPixverseOriginalVideosEvent: $e');
      }
    });
  }

  Future<void> _updateVideoInFirebase({
    required String userId,
    required String videoId,
    required String status,
    required String? output,
    required String completedAt,
  }) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      final userData = userDoc.data();
      final videos = userData?['userGeneratedVideos'] as List<dynamic>? ?? [];

      final updatedVideos = videos.map((video) {
        if (video['id'] == videoId) {
          return {
            ...video,
            'status': status,
            if (output != null) 'output': output,
            'completedAt': completedAt,
          };
        }
        return video;
      }).toList();

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'userGeneratedVideos': updatedVideos,
      });

      log('💾 Video $videoId updated in Firebase (status: $status)');
    } catch (e) {
      log('❌ Error updating Firebase: $e');
      rethrow;
    }
  }
}
