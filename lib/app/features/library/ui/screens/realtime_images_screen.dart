// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/realtime/bloc/realtime_bloc.dart';
import 'package:ginly/app/features/library/ui/widgets/image_details_text_widget.dart';
import 'package:ginly/app/features/text_to_image/model/text_to_image_generation_response_model_for_black_forest_label.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/core/utils.dart';
import 'package:ginly/generated/l10n.dart';
import 'package:http/http.dart' as http;

class RealtimeImageDetailScreen extends StatefulWidget {
  final TextToImageImageGenerationResponseModelForBlackForestLabel image;
  final bool isBase64;
  const RealtimeImageDetailScreen({
    Key? key,
    required this.image,
    required this.isBase64,
  }) : super(key: key);

  @override
  State<RealtimeImageDetailScreen> createState() =>
      _RealtimeImageDetailScreenState();
}

class _RealtimeImageDetailScreenState extends State<RealtimeImageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).imageDetails),
          actions: [
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
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            spacing: 8.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.image.output != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(8.h),
                      child: widget.image.output!.first.contains('http')
                          ? Image.network(widget.image.output?.first ?? '')
                          : Image.memory(
                              base64Decode(widget.image.output?.first ?? ''),
                            ),
                    ),
                    Positioned(
                        right: 8.h,
                        top: 8.h,
                        child: GestureDetector(
                          onTap: () {
                            getIt<RealtimeBloc>().add(
                                SoftDeleteRealtimeImageEvent(
                                    imageId: widget.image.id ?? ''));
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ))
                  ],
                ),
              Column(
                spacing: 8.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.image.input?['prompt'] != null)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                            text: widget.image.input?['prompt']!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Prompt  ${AppLocalizations.of(context).copied}!')),
                        );
                      },
                      child: ImageDetailsTextWidget(
                        title: AppLocalizations.of(context).promptLabel,
                        value: widget.image.input?['prompt'] ?? '',
                      ),
                    ),
                  if (widget.image.input?['aspect_ratio'] != null)
                    ImageDetailsTextWidget(
                      title: '${AppLocalizations.of(context).aspectRatio}: ',
                      value:
                          widget.image.input?['aspect_ratio'].toString() ?? '',
                    ),
                  if (widget.image.createdAt != null)
                    ImageDetailsTextWidget(
                      title: '${AppLocalizations.of(context).createdAt}: ',
                      value:
                          widget.image.createdAt.toString().toShortDateTimeTR,
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
        )));
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
}
