import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:comby/core/core.dart';

/// Gallery Selection Screen for Model items.
/// Uses ReusableGalleryPicker with multi-select and AI validation.
class ModelGallerySelectionScreen extends StatefulWidget {
  const ModelGallerySelectionScreen({super.key});

  @override
  State<ModelGallerySelectionScreen> createState() =>
      _ModelGallerySelectionScreenState();
}

class _ModelGallerySelectionScreenState
    extends State<ModelGallerySelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openGalleryPicker();
    });
  }

  Future<void> _openGalleryPicker() async {
    final result = await ReusableGalleryPicker.show(
      context: context,
      title: 'Select Model Photo',
      mode: GallerySelectionMode.multi,
      maxSelection: 50,
      enableCrop: false,
      showCameraButton: true,
    );

    if (!mounted) return;

    if (result == null || result.selectedFiles.isEmpty) {
      context.router.pop();
      return;
    }

    // Navigate to batch model upload progress screen
    context.router.replace(
      BatchModelUploadProgressScreenRoute(imageFiles: result.selectedFiles),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
