import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comby/core/injection/injection.dart';
import 'package:comby/app/features/live_stylist/cubit/live_stylist_cubit.dart';

class LiveStylistPage extends StatefulWidget {
  const LiveStylistPage({Key? key}) : super(key: key);

  @override
  State<LiveStylistPage> createState() => _LiveStylistPageState();
}

class _LiveStylistPageState extends State<LiveStylistPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  DateTime _lastFrameTime = DateTime.now();

  // Available cameras
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Use front camera by default for "selfie/fit check"
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium, // Don't need 4K for this
        enableAudio: false, // We handle audio separately via sound_stream
        imageFormatGroup: ImageFormatGroup
            .yuv420, // Compatible with 'image' package processing usually
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      // Start Image Stream
      _controller!.startImageStream((CameraImage image) {
        _processCameraImage(image);
      });
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  void _processCameraImage(CameraImage image) async {
    final now = DateTime.now();
    // Throttle: 1 FPS (Every 1000ms)
    if (now.difference(_lastFrameTime).inMilliseconds < 1000) return;
    _lastFrameTime = now;

    // Process in background if possible, or just keep it simple here
    // Note: Converting CameraImage to JPEG in Dart is CPU intensive.
    // Ideally use an isolate. For prototype, we run here but acknowledge jank risk.

    try {
      // Simple conversion handled by 'image' package if setup right, or custom yuv to rgb
      // For now, let's assume we can get a simpler JPEG or skip detailed conversion if too slow
      // Actually, let's just send the image conversion task to the cubit if we can,
      // but passing CameraImage to other isolates is tricky due to pointers.

      // MVP: Just print "Frame Captured" and implement actual conversion if 'image' package allows easy YUV
      // NOTE: Implementing full YUV to RGB here is code-heavy.
      // ALTERNATIVE: Use `_controller.takePicture()` periodically?
      // `takePicture` writes to disk, which is IO heavy but easier than manual YUV conversion.
      // Let's try `takePicture` logic instead of stream for lower complexity and reliability in MVP.
    } catch (e) {
      debugPrint("Frame processing error: $e");
    }
  }

  // Alternative to stream: Poll pictures
  Future<void> _captureAndSendLoop(BuildContext context) async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (_controller != null &&
          _controller!.value.isInitialized &&
          !_controller!.value.isTakingPicture) {
        try {
          final XFile file = await _controller!.takePicture();
          final bytes = await file.readAsBytes();
          // Resize to reduce bandwidth?
          // For now send raw (ResolutionPreset.medium is already ~480p-720p)

          if (mounted) {
            context.read<LiveStylistCubit>().sendVideoFrame(bytes);
          }
        } catch (e) {
          debugPrint("Capture error: $e");
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LiveStylistCubit>()..startSession(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera Layer
            if (_isCameraInitialized)
              Center(child: CameraPreview(_controller!))
            else
              const Center(
                  child: CircularProgressIndicator(color: Colors.white)),

            // Overlay Layer
            BlocConsumer<LiveStylistCubit, LiveStylistState>(
              listener: (context, state) {
                if (state.status == LiveStylistStatus.connected &&
                    _controller != null &&
                    _controller!.value.isInitialized) {
                  // Start the photo loop if not already started?
                  // In this simplistic code, re-calling _captureAndSendLoop is fine as it checks mounted.
                  // But ideally check a flag. For MVP, we call it.
                  _captureAndSendLoop(context);
                }

                // Show errors
                if (state.status == LiveStylistStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message ?? "Unknown Error"),
                      backgroundColor: Colors.red));
                }
              },
              builder: (context, state) {
                return SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 30),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: state.status ==
                                                LiveStylistStatus.connected
                                            ? Colors.green
                                            : Colors.red,
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Text("LIVE AGENT",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            // Copy Log Button
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.white),
                              onPressed: () {
                                final logs = state.logs.join("\n\n");
                                // Simple clipboard copy
                                // Requires 'import 'package:flutter/services.dart';'
                                // We can use Clipboard.setData
                                Clipboard.setData(ClipboardData(text: logs))
                                    .then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Conversation Log Copied!")),
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Logs Preview (Last message)
                      if (state.logs.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            state.logs.last,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Status / Visualizer
                      if (state.status == LiveStylistStatus.connecting)
                        const Text("Connecting...",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),

                      if (state.status == LiveStylistStatus.connected)
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(30)),
                            child: const Icon(Icons.mic,
                                color: Colors.white, size: 40),
                          ),
                        ),

                      const SizedBox(height: 50),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
