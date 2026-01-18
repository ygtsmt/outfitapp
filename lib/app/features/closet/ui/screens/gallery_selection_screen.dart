import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:comby/core/core.dart';

/// Gallery Selection Screen for Closet items.
/// This screen uses the reusable gallery picker for photo selection.
class GallerySelectionScreen extends StatefulWidget {
  const GallerySelectionScreen({super.key});

  @override
  State<GallerySelectionScreen> createState() => _GallerySelectionScreenState();
}

class _GallerySelectionScreenState extends State<GallerySelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to gallery picker after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openGalleryPicker();
    });
  }

  Future<void> _openGalleryPicker() async {
    final result = await ReusableGalleryPicker.show(
      context: context,
      title: 'Fotoğraf Seç',
      mode: GallerySelectionMode.multi,
      maxSelection: 50,
      enableCrop: false, // Crop disabled for multi-select
      showCameraButton: true,
    );

    if (!mounted) return;

    if (result == null || result.selectedFiles.isEmpty) {
      // User cancelled
      context.router.pop();
      return;
    }

    // Always go to batch upload, even for single files
    if (result.selectedFiles.isNotEmpty) {
      context.router.replace(
        BatchUploadProgressScreenRoute(imageFiles: result.selectedFiles),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This screen redirects to ReusableGalleryPicker
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
