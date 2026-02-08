import 'dart:async';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comby/core/injection/injection.dart';
import 'package:comby/app/features/live_stylist/cubit/live_stylist_cubit.dart';
import 'package:comby/app/features/live_stylist/widgets/thought_bubble_widget.dart';
import 'package:comby/app/features/live_stylist/widgets/live_stylist_permission_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

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
  bool _isSwitchingCamera = false;

  // Control visibility state
  bool _showControls = true;
  Timer? _hideControlsTimer;

  // Photo capture timer for continuous capture during speech
  Timer? _photoCaptureTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _initCamera(); // Wait for permissions

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Start auto-hide timer
    _resetHideControlsTimer();
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer?.cancel();
    setState(() => _showControls = true);

    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControlsVisibility() {
    if (!_showControls) {
      _resetHideControlsTimer();
    }
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
        ResolutionPreset.high, // Lower resolution for better performance
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
    if (now.difference(_lastFrameTime).inMilliseconds < 2000) return;
    _lastFrameTime = now;
  }

  Future<void> _switchCamera() async {
    if (_isSwitchingCamera || cameras.length < 2) return;

    setState(() => _isSwitchingCamera = true);

    try {
      final currentDirection = _controller?.description.lensDirection;
      final newCamera = cameras.firstWhere(
        (c) => c.lensDirection != currentDirection,
        orElse: () => cameras.first,
      );

      if (newCamera.lensDirection == currentDirection) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Only one camera available")),
          );
        }
        return;
      }

      await _controller?.stopImageStream();
      await _controller?.dispose();
      _controller = null;
      if (!mounted) return;

      setState(() => _isCameraInitialized = false);

      _controller = CameraController(
        newCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      if (!mounted) return;

      _controller!.startImageStream((CameraImage image) {
        _processCameraImage(image);
      });

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Camera switch error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to switch camera: $e"),
            backgroundColor: Colors.red,
          ),
        );
        _initCamera();
      }
    } finally {
      if (mounted) {
        setState(() => _isSwitchingCamera = false);
      }
    }
  }

  // Start continuous photo capture every 1 second while speaking
  void _startContinuousPhotoCapture(BuildContext context) {
    _photoCaptureTimer?.cancel();
    // Take first photo immediately
    _captureAndSendPhoto(context);
    // Then continue every 1 second
    _photoCaptureTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _captureAndSendPhoto(context);
    });
  }

  void _stopContinuousPhotoCapture() {
    _photoCaptureTimer?.cancel();
    _photoCaptureTimer = null;
  }

  // Capture single photo
  Future<void> _captureAndSendPhoto(BuildContext context) async {
    if (_controller != null &&
        _controller!.value.isInitialized &&
        !_controller!.value.isTakingPicture) {
      try {
        final XFile file = await _controller!.takePicture();
        final bytes = await file.readAsBytes();
        if (mounted) {
          context.read<LiveStylistCubit>().sendVideoFrame(bytes);
          debugPrint("📸 Photo sent to Live API");
        }
      } catch (e) {
        debugPrint("Capture error: $e");
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideControlsTimer?.cancel();
    _photoCaptureTimer?.cancel();
    _controller?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LiveStylistCubit>()..startSession(),
      child: BlocConsumer<LiveStylistCubit, LiveStylistState>(
        listener: (context, state) {
          // Initialize camera when active and not initialized
          if ((state.status == LiveStylistStatus.connecting ||
                  state.status == LiveStylistStatus.connected) &&
              !_isCameraInitialized &&
              _controller == null) {
            _initCamera();
          }

          // Start/stop photo capture based on user speaking
          if (state.isUserSpeaking && _photoCaptureTimer == null) {
            _startContinuousPhotoCapture(context);
          } else if (!state.isUserSpeaking && _photoCaptureTimer != null) {
            _stopContinuousPhotoCapture();
          }

          if (state.status == LiveStylistStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message ?? "Unknown Error"),
                backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          // 1. Checking Permissions
          if (state.status == LiveStylistStatus.checkingPermissions) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          }

          // 2. Permissions Denied -> Show Permission View
          if (state.status == LiveStylistStatus.permissionsDenied) {
            return const LiveStylistPermissionView();
          }

          // 3. Main Live Stylist UI
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Camera Layer (Full Screen - no black bars, BoxFit.cover = no distortion)
                if (_isCameraInitialized)
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.previewSize!.height,
                        height: _controller!.value.previewSize!.width,
                        child: CameraPreview(_controller!),
                      ),
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

                // 3. Main UI Layer with Tap-to-Show
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _toggleControlsVisibility,
                  child: BlocConsumer<LiveStylistCubit, LiveStylistState>(
                    listener: (_, __) {}, // Already handled in parent listener
                    builder: (context, state) {
                      return SafeArea(
                        child: Column(
                          children: [
                            // --- TOP BAR ---
                            if (_showControls)
                              FadeIn(
                                duration: const Duration(milliseconds: 300),
                                child: _buildTopBar(context, state),
                              ),

                            const Spacer(),

                            // --- THOUGHT BUBBLE ---
                            ThoughtBubbleWidget(
                              thought: state.currentThought,
                              toolName: state.currentToolName,
                              isVisible: state.hasActiveThought,
                            ),

                            // --- CENTER FEEDBACK ---
                            if (state.status ==
                                LiveStylistStatus.connecting) ...[
                              const CircularProgressIndicator(
                                  color: Colors.white),
                              SizedBox(height: 16.h),
                              Text(
                                "Connecting to Stylist...",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ] else if (state.status ==
                                LiveStylistStatus.connected)
                              _buildVoiceVisualizer(state),

                            const Spacer(),

                            // --- LOGS PREVIEW ---
                            if (state.logs.isNotEmpty && _showControls)
                              FadeIn(
                                duration: const Duration(milliseconds: 300),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24.w, vertical: 16.h),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.1)),
                                        ),
                                        child: Text(
                                          state.logs.last,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
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
                              ),

                            // --- BOTTOM CONTROLS ---
                            if (_showControls)
                              FadeIn(
                                duration: const Duration(milliseconds: 300),
                                child: _buildBottomControls(context, state),
                              ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, LiveStylistState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Minimize / Back

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
                  "GEMINI LIVE API",
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
        ],
      ),
    );
  }

  Widget _buildVoiceVisualizer(LiveStylistState state) {
    // Don't render at all when not speaking - saves resources
    if (!state.isAiSpeaking) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.9,
      );
    }

    return RepaintBoundary(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Lottie.asset(
          'assets/gemini-responding-lottie.json',
          repeat: true,
          animate: true,
          fit: BoxFit.contain,
          // Performance optimizations
          frameRate: FrameRate(60), // Limit to 60fps instead of unlimited
          renderCache:
              RenderCache.raster, // Use raster cache for better performance
          options: LottieOptions(
            enableMergePaths: true, // Optimize path rendering
          ),
        ),
      ),
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
            color: state.isMicMuted ? Colors.red : Colors.white,
            onTap: () {
              context.read<LiveStylistCubit>().toggleMute();
            },
          ),

          // End Call (Big Red Button with transparency)
          GestureDetector(
            onTap: () {
              _resetHideControlsTimer();
              Navigator.of(context).pop();
            },
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3B30).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.call_end_rounded,
                      color: Colors.white, size: 32),
                ),
              ),
            ),
          ),

          // Flip Camera
          _buildControlButton(
            icon: Icons.flip_camera_ios_rounded,
            color: _isSwitchingCamera
                ? Colors.white.withOpacity(0.3)
                : Colors.white,
            onTap: _isSwitchingCamera ? () {} : _switchCamera,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        _resetHideControlsTimer(); // Reset timer on interaction
        onTap();
      },
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15), // More transparent
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24.sp),
          ),
        ),
      ),
    );
  }
}
