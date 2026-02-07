import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveStylistPermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionsGranted;

  const LiveStylistPermissionScreen({
    Key? key,
    required this.onPermissionsGranted,
  }) : super(key: key);

  @override
  State<LiveStylistPermissionScreen> createState() =>
      _LiveStylistPermissionScreenState();
}

class _LiveStylistPermissionScreenState
    extends State<LiveStylistPermissionScreen> {
  bool _isRequesting = false;
  PermissionStatus _cameraStatus = PermissionStatus.denied;
  PermissionStatus _micStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    setState(() {
      _cameraStatus = cameraStatus;
      _micStatus = micStatus;
    });

    // If both are granted, proceed automatically
    if (cameraStatus.isGranted && micStatus.isGranted) {
      widget.onPermissionsGranted();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _isRequesting = true);

    // Request both permissions
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraStatus = statuses[Permission.camera]!;
    final micStatus = statuses[Permission.microphone]!;

    setState(() {
      _cameraStatus = cameraStatus;
      _micStatus = micStatus;
      _isRequesting = false;
    });

    // Check if both are granted
    if (cameraStatus.isGranted && micStatus.isGranted) {
      widget.onPermissionsGranted();
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  bool get _anyPermanentlyDenied =>
      _cameraStatus.isPermanentlyDenied || _micStatus.isPermanentlyDenied;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.3),
                  Colors.black,
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  // Close Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  const Spacer(),

                  // Icon
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.video_camera_front_rounded,
                      size: 64.sp,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Title
                  Text(
                    "Live Stylist Needs Permissions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16.h),

                  // Description
                  Text(
                    "To provide you with real-time fashion advice, we need access to your camera and microphone.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 15.sp,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 40.h),

                  // Permission Items
                  _buildPermissionItem(
                    icon: Icons.videocam_rounded,
                    title: "Camera",
                    description: "We'll see what you're wearing",
                    status: _cameraStatus,
                  ),

                  SizedBox(height: 16.h),

                  _buildPermissionItem(
                    icon: Icons.mic_rounded,
                    title: "Microphone",
                    description: "We'll listen to your questions",
                    status: _micStatus,
                  ),

                  const Spacer(),

                  // Action Button
                  if (_anyPermanentlyDenied)
                    _buildActionButton(
                      label: "Open Settings",
                      onTap: _openSettings,
                      isPrimary: true,
                    )
                  else
                    _buildActionButton(
                      label:
                          _isRequesting ? "Requesting..." : "Grant Permissions",
                      onTap: _isRequesting ? null : _requestPermissions,
                      isPrimary: true,
                    ),

                  SizedBox(height: 16.h),

                  // Skip Button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Not Now",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required PermissionStatus status,
  }) {
    final isGranted = status.isGranted;
    final isPermanentlyDenied = status.isPermanentlyDenied;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isGranted
                ? Colors.green.withOpacity(0.2)
                : isPermanentlyDenied
                    ? Colors.red.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isGranted
                  ? Colors.green.withOpacity(0.5)
                  : isPermanentlyDenied
                      ? Colors.red.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),

              SizedBox(width: 16.w),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Icon
              Icon(
                isGranted
                    ? Icons.check_circle_rounded
                    : isPermanentlyDenied
                        ? Icons.block_rounded
                        : Icons.radio_button_unchecked,
                color: isGranted
                    ? Colors.green
                    : isPermanentlyDenied
                        ? Colors.red
                        : Colors.white.withOpacity(0.3),
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                )
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
