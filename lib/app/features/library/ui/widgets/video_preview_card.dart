// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/library/ui/widgets/video_loading_widget.dart';
import 'package:ginly/app/features/video_generate/model/video_generate_response_model.dart';
import 'package:ginly/core/core.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class VideoPreviewCard extends StatefulWidget {
  final VideoGenerateResponseModel video;
  const VideoPreviewCard({super.key, required this.video});

  @override
  State<VideoPreviewCard> createState() => _VideoPreviewCardState();
}

class _VideoPreviewCardState extends State<VideoPreviewCard>
    with AutomaticKeepAliveClientMixin {
  CachedVideoPlayerPlusController? _controller;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    final url = widget.video.output;
    if (url != null && url.isNotEmpty) {
      try {
        _controller = CachedVideoPlayerPlusController.network(url);
        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } catch (e) {
        log('Video initialization error: $e');
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isInitialized || _controller == null) {
      return const VideosLoadingWidget();
    }

    return GestureDetector(
      onTap: () {
        context.router.push(VideoDetailScreenRoute(
          video: widget.video,
        ));
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: CachedVideoPlayerPlus(_controller!),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black45, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Center(
                child: Icon(Icons.play_circle_fill,
                    size: 24.h, color: context.borderColor),
              ),
              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.9],
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Text(
                    widget.video.fromTemplate == true
                        ? (widget.video.templateName ?? '')
                        : widget.video.input?.toString() ?? '',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.white,
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
