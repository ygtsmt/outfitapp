import 'package:flutter/material.dart';

import 'package:ginly/core/core.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VideosLoadingWidget extends StatelessWidget {
  const VideosLoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: AspectRatio(
        aspectRatio: 1.33,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border.all(color: context.borderColor),
              borderRadius: BorderRadius.circular(8)),
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    size: 32,
                    color: context.baseColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
