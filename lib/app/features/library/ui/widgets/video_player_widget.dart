import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ginfit/app/features/library/ui/screens/video_full_screen.dart';
import 'package:ginfit/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/core/constants/layout_constants.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoGenerateResponseModel video;
  final CachedVideoPlayerPlusController controller;
  const VideoPlayerWidget(
      {super.key, required this.video, required this.controller});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.controller.value.isPlaying) {
                        setState(() {
                          widget.controller.pause();
                        });
                      } else {
                        setState(() {
                          widget.controller.play();
                        });
                      }
                    },
                    child: CachedVideoPlayerPlus(widget.controller),
                  ),
                  if (!widget.controller.value.isPlaying)
                    IconButton(
                      icon: Icon(Icons.play_circle_filled,
                          size: 56, color: context.baseColor),
                      onPressed: () {
                        setState(() {
                          widget.controller.play();
                        });
                      },
                    ),

                  // Sağ alt köşeye ikon ekliyoruz:
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        // Tam ekran moduna geç
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VideoFullScreen(
                              videoUrl: widget.video.output ?? '',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.fullscreen_outlined,
                          color: context.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        LayoutConstants.centralEmptyHeight,
      ],
    );
  }
}
