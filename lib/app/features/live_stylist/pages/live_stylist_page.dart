import 'dart:async';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comby/core/injection/injection.dart';
import 'package:comby/app/features/live_stylist/cubit/live_stylist_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LiveStylistPage extends StatefulWidget {
  const LiveStylistPage({Key? key}) : super(key: key);

  @override
  State<LiveStylistPage> createState() => _LiveStylistPageState();
}

class _LiveStylistPageState extends State<LiveStylistPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  DateTime _lastFrameTime = DateTime.now();

  // Animation Controllers
  late AnimationController _pulseController;

  // Available cameras
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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

  void _processCameraImage(CameraImage image) {
    final now = DateTime.now();
    // Throttle: 1 FPS (Every 1000ms)
    if (now.difference(_lastFrameTime).inMilliseconds < 1000) return;
    _lastFrameTime = now;
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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LiveStylistCubit>()..startSession(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Camera Layer (Full Screen)
            if (_isCameraInitialized)
              Transform.scale(
                scale: 1.0, // Aspect ratio fix logic can go here if needed
                child: Center(
                  child: CameraPreview(_controller!),
                ),
              )
            else
              Container(
                color: const Color(0xFF1A1A1A),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            // 2. Gradient Overlay for readability
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.2, 0.7, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // 3. Main UI Layer
            BlocConsumer<LiveStylistCubit, LiveStylistState>(
              listener: (context, state) {
                if (state.status == LiveStylistStatus.connected &&
                    _controller != null &&
                    _controller!.value.isInitialized) {
                  _captureAndSendLoop(context);
                }

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
                      // --- TOP BAR ---
                      _buildTopBar(context, state),

                      const Spacer(),

                      // --- CENTER FEEDBACK ---
                      if (state.status == LiveStylistStatus.connecting) ...[
                        const CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16.h),
                        Text(
                          "Connecting to Stylist...",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (state.status == LiveStylistStatus.connected)
                        _buildPulseVisualizer(),

                      const Spacer(),

                      // --- LOGS PREVIEW ---
                      if (state.logs.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 16.h),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Text(
                                  state.logs.last,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // --- BOTTOM CONTROLS ---
                      _buildBottomControls(context, state),
                      SizedBox(height: 20.h),
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

  Widget _buildTopBar(BuildContext context, LiveStylistState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Minimize / Back
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),

          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: state.status == LiveStylistStatus.connected
                        ? const Color(0xFF00E676) // Bright Green
                        : const Color(0xFFFF3D00), // Deep Orange
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: state.status == LiveStylistStatus.connected
                            ? const Color(0xFF00E676).withOpacity(0.6)
                            : Colors.transparent,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  "LIVE AGENT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Action: Copy Logs or Help
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.sticky_note_2_outlined,
                      color: Colors.white, size: 22),
                  onPressed: () {
                    final logs = state.logs.join("\n\n");
                    Clipboard.setData(ClipboardData(text: logs)).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Conversation Log Copied!"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseVisualizer() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3), // Glow
                blurRadius: 20 + (_pulseController.value * 20),
                spreadRadius: 5 + (_pulseController.value * 10),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.graphic_eq_rounded,
              color: Colors.white,
              size: 48.sp,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(BuildContext context, LiveStylistState state) {
    return Container(
      padding: EdgeInsets.only(bottom: 20.h, left: 30.w, right: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Toggle
          _buildControlButton(
            icon: state.isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            color: state.isMicMuted
                ? Colors.red.withOpacity(0.8)
                : Colors.white.withOpacity(0.2),
            onTap: () {
              context.read<LiveStylistCubit>().toggleMute();
            },
          ),

          // End Call (Big Red Button)
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3B30).withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.call_end_rounded,
                  color: Colors.white, size: 32),
            ),
          ),

          // Flip Camera (Placeholder)
          _buildControlButton(
            icon: Icons.flip_camera_ios_rounded,
            color: Colors.white.withOpacity(0.2),
            onTap: () {
              // Switch camera logic would go here
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Switching camera...")));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: color,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),
          ),
        ),
      ),
    );
  }
}
