import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ginly/app/features/library/bloc/library_bloc.dart';
import 'package:ginly/app/features/library/ui/widgets/video_details_text_widget.dart';
import 'package:ginly/app/features/library/ui/widgets/video_player_widget.dart';
import 'package:ginly/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginly/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginly/app/features/video_generate/data/video_generate_usecase.dart';
import 'package:ginly/app/features/video_generate/model/video_generate_pixverse_pollo_request_model.dart';
import 'package:ginly/app/features/template_generate/data/template_generate_usecase.dart';
import 'package:ginly/app/features/report/bloc/report_bloc.dart';
import 'package:ginly/app/ui/widgets/native_ad_widget.dart';
import 'package:ginly/core/ui/widgets/report_dialog.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/core/utils.dart';
import 'package:ginly/generated/l10n.dart';
import 'package:http/http.dart' as http;
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class VideoDetailScreen extends StatefulWidget {
  final VideoGenerateResponseModel video;
  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late CachedVideoPlayerPlusController _controller;
  final TextEditingController reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller =
        CachedVideoPlayerPlusController.network(widget.video.output ?? '');
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize();
      _controller.play();
      _controller.setLooping(true);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing controller: $e');
    }
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        mediaUrl: widget.video.output ?? '',
        reportType: 'video',
        contentUrlOrBase64: widget.video.output ?? '',
        contentId: widget.video.id,
        collectionName: 'userGeneratedVideos',
        documentId: 'video_reports',
        onReportSubmitted: (report) {
          // Yeni ReportBloc'a report event'i gönder
          getIt<ReportBloc>().add(SubmitReportEvent(report: report));
        },
        reportController: reportController,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteVideo),
        content: Text(AppLocalizations.of(context).deleteVideoConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              getIt<LibraryBloc>().add(
                SoftDeleteUserGeneratedVideoEvent(
                    videoId: widget.video.id ?? ''),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.pause();
    reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoGenerateBloc, VideoGenerateState>(
      builder: (context, state) {
        return BlocConsumer<LibraryBloc, LibraryState>(
          listener: (context, libraryState) {
            if (libraryState.videoSoftDeleteStatus == EventStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context).videoDeletedSuccessfully),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
              // Go back to previous screen
              context.router.pop();
            }
          },
          builder: (context, libraryState) {
            return Scaffold(
              appBar: AppBar(
                forceMaterialTransparency: true,
                centerTitle: true,
                title: Text(widget.video.templateName ?? ''),
                actions: [
                  GestureDetector(
                    onTap: () => _showReportDialog(context),
                    child: Icon(
                      Icons.report_problem,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(context),
                    child: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () async {
                      final bytes =
                          await downloadVideoAsBytes(widget.video.output ?? '');
                      if (bytes != null) {
                        Utils.shareVideo(bytes, context);
                      } else {
                        debugPrint('Video bytes could not be loaded.');
                      }
                    },
                    child: Icon(
                      Icons.share,
                      color: context.baseColor,
                    ),
                  ),
                ],
                actionsPadding: EdgeInsets.only(right: 8.h),
              ),
              body: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VideoPlayerWidget(
                            controller: _controller,
                            video: widget.video,
                          ),
                          Column(
                            spacing: 8.h,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Input Image'i en üste alalım
                              if (widget.video.input?.image != null &&
                                  widget.video.input!.image!.isNotEmpty)
                                Column(
                                  spacing: 8.h,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    NativeAdWidget(),
                                    Text(
                                        '${AppLocalizations.of(context).inputImage}:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                    Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Image.network(
                                                widget.video.input!.image!),
                                          ),
                                          Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  final imageUrl = widget
                                                      .video.input!.image!;
                                                  final bytes =
                                                      await downloadImageAsBytes(
                                                          imageUrl);
                                                  if (bytes != null) {
                                                    Utils.shareImage(
                                                        bytes, context);
                                                  } else {
                                                    debugPrint(
                                                        'Image could not be downloaded.');
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(4.h),
                                                  decoration: BoxDecoration(
                                                    color: context.baseColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                  ),
                                                  child: Icon(
                                                    Icons.share,
                                                    color: context.baseColor,
                                                  ),
                                                ),
                                              ))
                                        ])
                                  ],
                                ),
                              VideoDetailsTextWidget(
                                title:
                                    '${AppLocalizations.of(context).quality}: ',
                                value:
                                    widget.video.input?.quality?.toString() ??
                                        '',
                              ),
                              VideoDetailsTextWidget(
                                title:
                                    '${AppLocalizations.of(context).style}: ',
                                value:
                                    widget.video.input?.style?.toString() ?? '',
                              ),
                              VideoDetailsTextWidget(
                                title:
                                    '${AppLocalizations.of(context).aspectRatio}: ',
                                value: widget.video.input?.aspectRatio
                                        ?.toString() ??
                                    '',
                              ),
                              VideoDetailsTextWidget(
                                title:
                                    AppLocalizations.of(context).durationLabel,
                                value:
                                    widget.video.input?.duration?.toString() ??
                                        '',
                              ),
                              VideoDetailsTextWidget(
                                title:
                                    '${AppLocalizations.of(context).createdAt}: ',
                                value: widget.video.createdAt
                                        ?.toString()
                                        .toShortDateTimeTR ??
                                    '',
                              ),
                              if (widget.video.startedAt != null)
                                VideoDetailsTextWidget(
                                  title: AppLocalizations.of(context)
                                      .startedAtLabel,
                                  value: widget.video.startedAt!
                                      .toString()
                                      .toShortDateTimeTR,
                                ),
                              if (widget.video.completedAt != null)
                                VideoDetailsTextWidget(
                                  title: AppLocalizations.of(context)
                                      .completedAtLabel,
                                  value: widget.video.completedAt!
                                      .toString()
                                      .toShortDateTimeTR,
                                ),
                              if (widget.video.error != null &&
                                  widget.video.error!.isNotEmpty)
                                VideoDetailsTextWidget(
                                  title:
                                      AppLocalizations.of(context).errorLabel,
                                  value: widget.video.error!,
                                ),
/*                           // Failed durumunda refund credit UI'ını göster
                          if (widget.video.status == 'failed')
                            _buildRefundCreditSection(), */
                              if (widget.video.urls != null)
                                Column(
                                  spacing: 8.h,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Video URLs:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                    if (widget.video.urls!.web != null &&
                                        widget.video.urls!.web!.isNotEmpty)
                                      VideoDetailsTextWidget(
                                        title: AppLocalizations.of(context)
                                            .webLabel,
                                        value: widget.video.urls!.web!,
                                      ),
                                    if (widget.video.urls!.stream != null &&
                                        widget.video.urls!.stream!.isNotEmpty)
                                      VideoDetailsTextWidget(
                                        title: AppLocalizations.of(context)
                                            .streamLabel,
                                        value: widget.video.urls!.stream!,
                                      ),
                                    if (widget.video.urls!.get != null &&
                                        widget.video.urls!.get!.isNotEmpty)
                                      VideoDetailsTextWidget(
                                        title: AppLocalizations.of(context)
                                            .getLabel,
                                        value: widget.video.urls!.get!,
                                      ),
                                  ],
                                ),
                              GestureDetector(
                                onTap: () {
                                  if (widget.video.id != null &&
                                      widget.video.id!.isNotEmpty) {
                                    Clipboard.setData(
                                        ClipboardData(text: widget.video.id!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Video ID  ${AppLocalizations.of(context).copied}!')),
                                    );
                                  }
                                },
                                child: VideoDetailsTextWidget(
                                  title: AppLocalizations.of(context).idLabel,
                                  value: widget.video.id ?? '',
                                ),
                              ),
                              if (widget.video.input?.lastFrameImage != null &&
                                  widget
                                      .video.input!.lastFrameImage!.isNotEmpty)
                                Column(
                                  spacing: 8.h,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Last Frame Image:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadiusGeometry
                                                        .circular(16),
                                                child: Image.network(widget
                                                    .video
                                                    .input!
                                                    .lastFrameImage!)))
                                      ],
                                    ),
                                  ],
                                ),
                              if (widget.video.logs != null &&
                                  widget.video.logs!.isNotEmpty)
                                VideoDetailsTextWidget(
                                  title: AppLocalizations.of(context).logsLabel,
                                  value: widget.video.logs!,
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 64.h,
                          )
                        ],
                      ),
                    ),
                  ),
                  // Regenerate button'ı Stack'in üzerine ekle
                  /*   Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: CustomGradientButton(
                      requiredCredit: '10',
                      leading: Icon(
                        Icons.replay_outlined,
                        color: context.white,
                      ),
                      title: AppLocalizations.of(context).regenerateButton,
                      onTap: () => _handleRegenerate(),
                      isFilled: true,
                    ),
                  ), */
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Uint8List?> downloadVideoAsBytes(String videoUrl) async {
    try {
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('Failed to download video: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error downloading video: $e');
      return null;
    }
  }

  Future<Uint8List?> downloadImageAsBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('Image download failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return null;
    }
  }

  // Failed durumunda refund credit UI'ını oluştur
  Widget _buildRefundCreditSection() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade50,
            Colors.red.shade100,
          ],
        ),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 24.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Video Generation Failed',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Your video could not be generated due to content policy violations. You can request a credit refund.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade700,
                ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Kredi geri alma işlemi
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Credit refund requested',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 18.w,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Request Credit Refund',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Regenerate button'ını oluştur

  // Regenerate işlemini handle et
  void _handleRegenerate() async {
    try {
      // Random seed oluştur (1-999999 arasında)
      final randomSeed = Random().nextInt(9999);

      // Template'den üretildiyse generateTemplateVideo, değilse videoGeneratePixversePollo kullan
      if (widget.video.fromTemplate == true) {
        // Template regenerate logic
        print('Regenerating from template with seed: $randomSeed');

        // Template regenerate için gerekli parametreleri al
        final input = widget.video.input;
        if (input != null) {
          // VideoGeneratePixversePolloRequestInputModel oluştur
          final requestModel = VideoGeneratePixversePolloRequestInputModel(
            mode: input.motionMode ?? 'normal',
            image: input.image,
            prompt: input.prompt,
            imageTail: input.lastFrameImage,
            resolution: input.quality ?? '540p',
            length: input.duration ?? 5,
            aspectRatio: input.aspectRatio ?? '1:1',
            style: input.style ?? 'auto',
            seed: randomSeed, // Random seed kullan
          );

          // Template regenerate et
          final result = await getIt<TemplateGenerateUsecase>()
              .generateTemplateVideo(requestModel);

          if (result != null) {
            // Firebase'e kaydet
            await getIt<TemplateGenerateUsecase>().addUserVideo(result);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)
                    .templateRegenerationStarted(randomSeed)),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    AppLocalizations.of(context).failedToRegenerateTemplate),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)
                  .noInputDataForTemplateRegeneration),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Custom video regenerate
        print('Regenerating custom video with seed: $randomSeed');

        // Orijinal video'dan input'ları al
        final input = widget.video.input;
        if (input != null) {
          // VideoGeneratePixversePolloRequestInputModel oluştur
          final requestModel = VideoGeneratePixversePolloRequestInputModel(
            mode: input.motionMode ?? 'normal',
            image: input.image,
            prompt: input.prompt,
            imageTail: input.lastFrameImage,
            resolution: input.quality ?? '540p',
            length: input.duration ?? 5,
            aspectRatio: input.aspectRatio ?? '1:1',
            style: input.style ?? 'auto',
            seed: randomSeed, // Random seed kullan
          );

          // Video generate et
          final result = await getIt<VideoGenerateUsecase>()
              .videoGeneratePixversePollo(requestModel);

          if (result != null) {
            // Firebase'e kaydet
            await getIt<VideoGenerateUsecase>().addUserVideoPollo(result);

            // Başarılı
            Utils.showToastMessage(
                context: context,
                content: AppLocalizations.of(context).videoRegenerationStarted);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(AppLocalizations.of(context).failedToRegenerateVideo),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context).noInputDataForRegeneration),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      // Library'ye git
      context.router.pop();
    } catch (e) {
      print('Error in regenerate: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).errorOccurred(e.toString())),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
