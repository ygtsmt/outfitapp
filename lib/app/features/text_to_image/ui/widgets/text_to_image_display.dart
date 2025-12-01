import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginly/app/features/text_to_image/bloc/text_to_image_bloc.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/core/constants/layout_constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:typed_data';

class TextToImageDisplay extends StatelessWidget {
  final TextToImageState state;
  final Uint8List? decodedImageBytes;

  const TextToImageDisplay({
    super.key,
    required this.state,
    required this.decodedImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    if (state.textToImagePhotoIsBase64 != null) {
      return Expanded(
        child: state.textToImageStatus != EventStatus.idle
            ? LoadingAnimationWidget.fourRotatingDots(
                size: MediaQuery.of(context).size.height / 16,
                color: context.baseColor,
              )
            : InteractiveViewer(
                child: state.textToImagePhotoIsBase64 == true
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: decodedImageBytes != null
                                ? Image(
                                    image: MemoryImage(decodedImageBytes!),
                                    fit: BoxFit.fitHeight,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(16),
                          child: Image.network(
                            state.textToImagePhotoUrl ?? errorImageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
