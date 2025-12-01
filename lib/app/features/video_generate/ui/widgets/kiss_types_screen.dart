import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginly/core/core.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

class KissTypeScreen extends StatefulWidget {
  const KissTypeScreen({
    super.key,
    required this.kissType,
    required this.kissTypeUrls,
  });

  final List<String> kissType;
  final List<String> kissTypeUrls;

  @override
  State<KissTypeScreen> createState() => _KissTypeScreenState();
}

class _KissTypeScreenState extends State<KissTypeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoGenerateBloc, VideoGenerateState>(
      builder: (context, state) {
        return GridView.builder(
          padding: const EdgeInsets.all(0), // Ek olarak padding'i sıfırlayın

          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: widget.kissType.length,
          itemBuilder: (context, index) {
            return KissTypePreviewCard(
              kissType: widget.kissType[index],
              kissTypeUrl: widget.kissTypeUrls[index],
              isSelected: state.kissType == widget.kissType[index],
              onTap: () {
                getIt<VideoGenerateBloc>()
                    .add(SetKissTypeEvent(kissType: widget.kissType[index]));
              },
            );
          },
        );
      },
    );
  }
}

// ignore_for_file: deprecated_member_use
class KissTypePreviewCard extends StatefulWidget {
  final String kissType;
  final String kissTypeUrl;
  final bool isSelected;
  final VoidCallback? onTap;

  const KissTypePreviewCard({
    super.key,
    required this.kissType,
    required this.kissTypeUrl,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<KissTypePreviewCard> createState() => _KissTypePreviewCardState();
}

class _KissTypePreviewCardState extends State<KissTypePreviewCard> {
  VideoPlayerController? _controller;

  Future<void> _initializeController(String url) async {
    final exists = await _checkIfVideoExists(url);
    if (exists) {
      _controller?.dispose();
      _controller = VideoPlayerController.network(url);
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.play();
      setState(() {});
    } else {
      log("Video URL geçersiz: $url");
    }
  }

  Future<bool> _checkIfVideoExists(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeController(widget.kissTypeUrl);
  }

  @override
  void didUpdateWidget(covariant KissTypePreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.kissTypeUrl != widget.kissTypeUrl) {
      _initializeController(widget.kissTypeUrl);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    double aspect = _controller!.value.aspectRatio;
    aspect = aspect.clamp(0.8, 1.2); // Minimum 0.8, maksimum 1.2

    return GestureDetector(
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: aspect,
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isSelected ? context.baseColor : null,
              border: widget.isSelected
                  ? null
                  : Border.all(
                      color: context.borderColor,
                    ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: VideoPlayer(_controller!),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.kissType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: widget.isSelected
                            ? context.white
                            : context.baseColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
