import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:comby/app/features/fal_ai/data/fal_ai_usecase.dart';
import 'package:comby/generated/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class QuickTryOnScreen extends StatefulWidget {
  const QuickTryOnScreen({super.key});

  @override
  State<QuickTryOnScreen> createState() => _QuickTryOnScreenState();
}

enum TryOnStep { captureUser, captureClothes, processing, result }

class _QuickTryOnScreenState extends State<QuickTryOnScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  TryOnStep _currentStep = TryOnStep.captureUser;

  File? _userImage;
  File? _clothesImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context).cameraPermissionRequired)),
        );
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Use front camera for user step, back for clothes
        final camera = _currentStep == TryOnStep.captureUser
            ? _cameras!.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras!.first)
            : _cameras!.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras!.first);

        _controller = CameraController(
          camera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final lensDirection = _controller?.description.lensDirection;
    CameraDescription newCamera;

    if (lensDirection == CameraLensDirection.front) {
      newCamera = _cameras!.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras!.first);
    } else {
      newCamera = _cameras!.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first);
    }

    await _controller?.dispose();
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error switching camera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      final XFile file = await _controller!.takePicture();
      final File imageFile = File(file.path);

      setState(() {
        if (_currentStep == TryOnStep.captureUser) {
          _userImage = imageFile;
          // Transition to next step
          _currentStep = TryOnStep.captureClothes;
          // Switch to back camera for clothes automatically
          _switchCamera();
        } else if (_currentStep == TryOnStep.captureClothes) {
          _clothesImage = imageFile;
          _startProcessing();
        }
      });
    } catch (e) {
      debugPrint('Error capturing picture: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        if (_currentStep == TryOnStep.captureUser) {
          _userImage = File(image.path);
          _currentStep = TryOnStep.captureClothes;
          // Switch to back camera for clothes functionality
          _switchCamera();
        } else if (_currentStep == TryOnStep.captureClothes) {
          _clothesImage = File(image.path);
          _startProcessing();
        }
      });
    }
  }

  Future<void> _startProcessing() async {
    if (_userImage == null || _clothesImage == null) return;

    setState(() {
      _currentStep = TryOnStep.processing;
      _isLoading = true;
    });

    try {
      final falAiUsecase = GetIt.I<FalAiUsecase>();
      // final closetUseCase = GetIt.I<ClosetUseCase>(); // No longer needed

      // 1. Upload Images
      final userUrl =
          await falAiUsecase.uploadImageToStorage(_userImage!, 'models');
      final clothesUrl =
          await falAiUsecase.uploadImageToStorage(_clothesImage!, 'closet');

      // 2. Trigger AI Generation (Without saving to closet/models)
      final result = await falAiUsecase.generateGeminiImageEdit(
        imageUrls: [
          userUrl,
          clothesUrl
        ], // First image is user (model), second is reference
        prompt:
            "Put the clothes from the second image onto the person in the first image.",
        sourceId: 2, // Quick Try On
        usedClosetItems: null, // Don't link to any permanent items
      );

      if (result != null && result['status'] == 'processing') {
        final requestId = result['id'];

        // 3. Poll for Result (or listen to stream)
        // Since we are in a modal flow, a simple stream listener for this specific doc is best
        _listenForCompletion(requestId);
      } else {
        throw Exception("Failed to start processing");
      }
    } catch (e) {
      debugPrint('Error processing try-on: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context).errorOccurred(e.toString()))),
        );
        setState(() {
          _currentStep = TryOnStep.captureUser; // Reset
          _userImage = null;
          _clothesImage = null;
          _isLoading = false;
        });
      }
    }
  }

  void _listenForCompletion(String requestId) {
    if (!mounted) return;

    // Listen to the document in 'combines' collection
    final firestore = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    debugPrint('🔍 Quick Try: Listening for completion of request: $requestId');

    firestore
        .collection('users')
        .doc(userId)
        .collection('combines')
        .doc(requestId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      if (snapshot.exists) {
        final data = snapshot.data();
        final status = data?['status'];
        final output = data?['output'];

        debugPrint(
            '🔍 Quick Try: Status update - status: $status, output: $output');

        // Webhook saves status as 'succeeded', not 'completed'
        if (status == 'succeeded' && output != null) {
          debugPrint('✅ Quick Try: Generation succeeded!');
          setState(() {
            _isLoading = false;
            _currentStep = TryOnStep.result;
            _resultData = data;
          });
        } else if (status == 'failed') {
          debugPrint('❌ Quick Try: Generation failed');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context).operationFailed)),
            );
            setState(() {
              _isLoading = false;
              _currentStep = TryOnStep.captureUser;
            });
          }
        }
      } else {
        debugPrint(
            '⚠️ Quick Try: Document does not exist yet for request: $requestId');
      }
    });
  }

  // Add field to store result
  Map<String, dynamic>? _resultData;

  @override
  Widget build(BuildContext context) {
    if (_currentStep == TryOnStep.result && _resultData != null) {
      return _buildResultView();
    }

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).primaryColor,
                size: 40,
              ),
              SizedBox(height: 16.h),
              Text(
                AppLocalizations.of(context).geminiProcessing,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _controller == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).quickTryOn),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(_controller!),

          // Overlay Guide
          _buildGuideOverlay(),

          // Top Bar
          Positioned(
            top: 40.h,
            left: 16.w,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => context.router.pop(),
            ),
          ),

          Positioned(
            top: 40.h,
            right: 16.w,
            child: IconButton(
              icon: const Icon(Icons.flip_camera_ios,
                  color: Colors.white, size: 30),
              onPressed: _switchCamera,
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  _currentStep == TryOnStep.captureUser
                      ? AppLocalizations.of(context).captureYourself
                      : AppLocalizations.of(context).captureClothes,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery Button
                    IconButton(
                      icon: const Icon(Icons.photo_library,
                          color: Colors.white, size: 32),
                      onPressed: _pickFromGallery,
                    ),

                    // Capture Button
                    GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Center(
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Spacer for alignment
                    SizedBox(width: 32.w),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
            bottom: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 100.h),
        child: Center(
          child: Text(
            _currentStep == TryOnStep.captureUser
                ? AppLocalizations.of(context).alignFaceAndBody
                : AppLocalizations.of(context).centerTheClothes,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    String? imageUrl;
    if (_resultData != null) {
      final output = _resultData!['output'];
      // Webhook saves output as an array: [firebaseUrl]
      if (output is List && output.isNotEmpty) {
        imageUrl = output.first as String?;
      } else if (output is Map && output.containsKey('images')) {
        // Fallback for other formats
        final images = output['images'];
        if (images is List && images.isNotEmpty) {
          imageUrl = images.first['url'];
        }
      } else if (output is Map && output.containsKey('image')) {
        imageUrl = output['image']['url'];
      }
    }

    if (imageUrl == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).result)),
        body: Center(child: Text(AppLocalizations.of(context).imageLoadFailed)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).combineResult,
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: ElevatedButton(
                onPressed: () {
                  context.router.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(AppLocalizations.of(context).ok),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
