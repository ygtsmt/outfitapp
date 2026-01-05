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

    if (result.selectedFiles.length == 1) {
      // Single photo - go to form then pop
      final formResult = await context.router.push(
        ClosetItemFormScreenRoute(imageFile: result.selectedFiles.first),
      );
      if (mounted) {
        context.router.pop(formResult);
      }
    } else {
      // Multiple photos - go to batch upload
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
