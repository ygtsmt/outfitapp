// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ginfit/app/features/library/bloc/library_bloc.dart';
import 'package:ginfit/app/features/library/ui/widgets/image_details_text_widget.dart';
import 'package:ginfit/app/features/report/bloc/report_bloc.dart';
import 'package:ginfit/core/ui/widgets/report_dialog.dart';

import 'package:ginfit/app/features/text_to_image/model/text_to_image_generation_response_model_for_black_forest_label.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/core/utils.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ImageDetailScreen extends StatefulWidget {
  final TextToImageImageGenerationResponseModelForBlackForestLabel image;
  final bool isBase64;
  final String imageType; // 'text_to_image' veya 'realtime'

  const ImageDetailScreen({
    Key? key,
    required this.image,
    required this.isBase64,
    required this.imageType,
  }) : super(key: key);

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state.submitReportStatus == EventStatus.processing) {
          Utils.showToastMessage(
              context: context,
              content: AppLocalizations.of(context).reportSending);
        }

        if (state.submitReportStatus == EventStatus.success) {
          Utils.showToastMessage(
              context: context,
              content: AppLocalizations.of(context).reportSentSuccessfully);
          debugPrint('Report başarıyla Firebase\'e kaydedildi!');
        }

        if (state.submitReportStatus == EventStatus.failure) {
          Utils.showToastMessage(
              context: context,
              content: AppLocalizations.of(context).reportFailedToSend,
              color: Colors.red);
        }
      },
      builder: (context, state) {
        return BlocBuilder<LibraryBloc, LibraryState>(
          builder: (context, libraryState) {
            return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(AppLocalizations.of(context).imageDetails),
                  actions: [
                    GestureDetector(
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => ReportDialog(
                            mediaUrl: widget.image.output?.first ?? '',
                            reportType: widget.imageType == 'realtime'
                                ? 'realtimeImage'
                                : 'image',
                            isBase64: true,
                            prompt: widget.imageType == 'realtime'
                                ? (widget.image.prompt ??
                                    widget.image.input?['prompt']?.toString() ??
                                    'Realtime image prompt bulunamadı')
                                : (widget.image.prompt ??
                                    widget.image.input?['prompt']?.toString() ??
                                    'Prompt bulunamadı'),
                            contentId: widget.image.id,
                            collectionName: 'userGeneratedImages',
                            documentId: 'image_reports',
                            onReportSubmitted: (report) {
                              // Report'a ek bilgiler ekle
                              final enhancedReport = report.copyWith(
                                prompt: widget.imageType == 'realtime'
                                    ? (widget.image.prompt ??
                                        widget.image.input?['prompt']
                                            ?.toString() ??
                                        'Realtime image prompt bulunamadı')
                                    : (widget.image.prompt ??
                                        widget.image.input?['prompt']
                                            ?.toString() ??
                                        'Prompt bulunamadı'),
                                createdAt: DateTime.now().toIso8601String(),
                              );

                              // Yeni ReportBloc'a report event'i gönder
                              getIt<ReportBloc>().add(
                                  SubmitReportEvent(report: enhancedReport));
                            },
                          ),
                        );
                      },
                      child: Icon(
                        Icons.report_problem,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        _showDeleteDialog(context);
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                    /*  GestureDetector(
                      onTap: () => _showDeleteDialog(context),
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ), */
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final response = await http
                              .get(Uri.parse(widget.image.output?.first ?? ''));
                          if (response.statusCode == 200) {
                            Uint8List imageBytes = response.bodyBytes;
                            await Utils.shareImage(imageBytes, context);
                          } else {
                            debugPrint(
                                'Image download failed with status: ${response.statusCode}');
                          }
                        } catch (e) {
                          debugPrint('Error downloading or sharing image: $e');
                        }
                      },
                      child: const Icon(Icons.share),
                    ),
                  ],
                  actionsPadding: EdgeInsets.only(right: 8.h),
                ),
                body: BlocListener<LibraryBloc, LibraryState>(
                  listener: (context, state) {
                    // Debug: State'leri logla
                    print(
                        'ImageDetailScreen - imageSoftDeleteStatus: ${state.imageSoftDeleteStatus}');
                    print(
                        'ImageDetailScreen - realtimeImageSoftDeleteStatus: ${state.realtimeImageSoftDeleteStatus}');

                    if (state.imageSoftDeleteStatus == EventStatus.success ||
                        state.realtimeImageSoftDeleteStatus ==
                            EventStatus.success) {
                      print('ImageDetailScreen - Delete success detected!');
                      context.router.pop();
                      Utils.showToastMessage(
                          context: context,
                          content: AppLocalizations.of(context)
                              .imageDeletedSuccessfully);
                    }
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        spacing: 8.h,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.image.output != null)
                            ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(8.h),
                              child: widget.image.output!.first.contains('http')
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          widget.image.output?.first ?? '',
                                      placeholder: (context, url) => Center(
                                        child: LoadingAnimationWidget
                                            .fourRotatingDots(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 12.h,
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => const Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.grey),
                                      ),
                                    )
                                  : Image.memory(
                                      base64Decode(
                                          widget.image.output?.first ?? ''),
                                    ),
                            ),
                          Column(
                            spacing: 8.h,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.image.prompt != null ||
                                  widget.image.input?['prompt'] != null)
                                GestureDetector(
                                  onTap: () {
                                    final promptText = widget.image.prompt ??
                                        widget.image.input?['prompt'] ??
                                        '';
                                    Clipboard.setData(
                                        ClipboardData(text: promptText));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Prompt ${AppLocalizations.of(context).copied}')),
                                    );
                                  },
                                  child: ImageDetailsTextWidget(
                                    title: AppLocalizations.of(context)
                                        .promptLabel,
                                    value: widget.image.prompt ??
                                        widget.image.input?['prompt'] ??
                                        '',
                                  ),
                                ),
                              if (widget.image.input?['aspect_ratio'] != null)
                                ImageDetailsTextWidget(
                                  title:
                                      '${AppLocalizations.of(context).aspectRatio}: ',
                                  value: widget.image.input?['aspect_ratio']
                                          .toString() ??
                                      '',
                                ),
                              if (widget.image.createdAt != null ||
                                  widget.image.createdAtDirect != null)
                                ImageDetailsTextWidget(
                                  title:
                                      '${AppLocalizations.of(context).createdAt}: ',
                                  value: (widget.image.createdAt ??
                                          widget.image.createdAtDirect ??
                                          '')
                                      .toString()
                                      .toShortDateTimeTR,
                                ),
                              if (widget.image.id != null)
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: widget.image.id!));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Video ID  ${AppLocalizations.of(context).copied}!')),
                                    );
                                  },
                                  child: ImageDetailsTextWidget(
                                    title: AppLocalizations.of(context).idLabel,
                                    value: widget.image.id ?? '',
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ));
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteImage),
          content: Text(AppLocalizations.of(context).deleteImageConfirmation),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).cancel),
              onPressed: () {
                context.router.pop();
              },
            ),
            ElevatedButton(
              child: Text(AppLocalizations.of(context).delete),
              onPressed: () async {
                if (widget.imageType == 'realtime') {
                  getIt<LibraryBloc>().add(
                    SoftDeleteRealtimeImageEvent(
                      imageId: widget.image.id ?? '',
                    ),
                  );
                } else {
                  getIt<LibraryBloc>().add(
                    SoftDeleteImageEvent(
                      imageId: widget.image.id ?? '',
                    ),
                  );
                }
                // Sadece dialog'u kapat, ImageDetailScreen'i BlocListener'da kapat
                context.router.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ],
        );
      },
    );
  }
}
