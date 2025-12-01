import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ginly/core/core.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';

class VideoFullScreen extends StatefulWidget {
  final String videoUrl;

  const VideoFullScreen({super.key, required this.videoUrl});

  @override
  State<VideoFullScreen> createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {
  late CachedVideoPlayerPlusController _controller;
  bool _isControlsVisible = true;

  @override
  void initState() {
    super.initState();
    
    // Tam ekran modunu ayarla
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    _controller = CachedVideoPlayerPlusController.network(widget.videoUrl);
    _initializeController();
    
    // 3 saniye sonra kontrolleri gizle
    _hideControlsAfterDelay();
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
      debugPrint('Error initializing fullscreen controller: $e');
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
    
    if (_isControlsVisible) {
      _hideControlsAfterDelay();
    }
  }

  void _exitFullScreen() {
    // Sistem UI'ını geri getir
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    context.router.pop();
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    
    // Sistem UI'ını geri getir
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video Player
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CachedVideoPlayerPlus(_controller),
                    )
                  : const CircularProgressIndicator(),
            ),
            
            // Controls Overlay
            if (_isControlsVisible)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Top Controls
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _exitFullScreen,
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _exitFullScreen,
                              icon: const Icon(
                                Icons.fullscreen_exit,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Center Play/Pause Button
                      if (!_controller.value.isPlaying)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _controller.play();
                            });
                          },
                          icon: Icon(
                            Icons.play_circle_filled,
                            color: context.baseColor,
                            size: 80,
                          ),
                        ),
                      
                      const Spacer(),
                      
                      // Bottom Controls
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_controller.value.isPlaying) {
                                  _controller.pause();
                                } else {
                                  _controller.play();
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _controller.value.position.toFormattedString,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: context.baseColor,
                                  bufferedColor: Colors.white.withOpacity(0.3),
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _controller.value.duration.toFormattedString,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
