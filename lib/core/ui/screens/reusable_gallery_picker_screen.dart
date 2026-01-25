import 'package:auto_route/auto_route.dart';
import 'package:comby/core/ui/widgets/reusable_gallery_picker.dart';
import 'package:flutter/material.dart';

class ReusableGalleryPickerScreen extends StatelessWidget {
  final String title;
  final GallerySelectionMode mode;
  final int maxSelection;
  final bool enableCrop;
  final bool showCameraButton;

  const ReusableGalleryPickerScreen({
    super.key,
    required this.title,
    this.mode = GallerySelectionMode.single,
    this.maxSelection = 50,
    this.enableCrop = true,
    this.showCameraButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableGalleryPicker(
      title: title,
      mode: mode,
      maxSelection: maxSelection,
      enableCrop: enableCrop,
      showCameraButton: showCameraButton,
    );
  }
}
