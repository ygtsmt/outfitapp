import 'dart:convert';
import 'dart:typed_data';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginfit/app/features/text_to_image/bloc/text_to_image_bloc.dart';
import 'package:ginfit/app/features/report/bloc/report_bloc.dart';
import 'package:ginfit/core/ui/widgets/report_dialog.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/app/features/text_to_image/ui/widgets/text_to_image_widgets.dart';

class TextToImageScreen extends StatefulWidget {
  const TextToImageScreen({super.key});

  @override
  State<TextToImageScreen> createState() => _TextToImageScreenState();
}

class _TextToImageScreenState extends State<TextToImageScreen>
    with AutomaticKeepAliveClientMixin {
  int selectedAspectRatioItemId = 0;
  TextEditingController textToImagePromptController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  Uint8List? decodedImageBytes;

  @override
  bool get wantKeepAlive => true;

  void _showReportDialog(BuildContext context, TextToImageState state) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        mediaUrl: decodedImageBytes?.toString() ?? '',
        reportType: 'textToImage',
        prompt: textToImagePromptController.text.trim(),
        isBase64: state.textToImagePhotoIsBase64 ?? false,
        contentId: DateTime.now().millisecondsSinceEpoch.toString(),
        collectionName: 'userGeneratedImages',
        documentId: 'text_to_image_reports',
        onReportSubmitted: (report) {
          getIt<ReportBloc>().add(SubmitReportEvent(report: report));
        },
        reportController: TextEditingController(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocListener<TextToImageBloc, TextToImageState>(
        listener: (context, state) {
          if (state.textToImagePhotoIsBase64 == true &&
              state.textToImagePhotoBase64 != null &&
              state.textToImagePhotoBase64!.isNotEmpty) {
            decodedImageBytes = base64Decode(state.textToImagePhotoBase64!);
          } else {
            decodedImageBytes = null;
          }
        },
        child: BlocBuilder<TextToImageBloc, TextToImageState>(
          builder: (context, state) {
            return Scaffold(
              appBar: TextToImageAppBar(
                state: state,
                promptController: textToImagePromptController,
                decodedImageBytes: decodedImageBytes,
                onReportTap: () {
                  if (state.textToImagePhotoIsBase64 == true ||
                      state.textToImagePhotoUrl != null) {
                    _showReportDialog(context, state);
                  }
                },
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image display or error widget
                  state.textToImagePhotoIsBase64 != null
                      ? TextToImageDisplay(
                          state: state,
                          decodedImageBytes: decodedImageBytes,
                        )
                      : Expanded(
                          child: Center(
                            child: TextToImageErrorWidget(
                              filterErrorMessage: state.filterErrorMessage,
                            ),
                          ),
                        ),
                  // Bottom controls
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 16, left: 16, bottom: 16),
                    child: TextToImageCreditChecker(
                      state: state,
                      promptController: textToImagePromptController,
                      onGenerate: () {},
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
