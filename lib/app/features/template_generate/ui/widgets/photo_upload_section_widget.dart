import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';

class PhotoUploadSectionWidget extends StatelessWidget {
  final bool isDifferentPhoto;
  final File? imageFile1;
  final File? imageFile2;
  final File? imageFile3;
  final Function(int) onImagePicked;

  const PhotoUploadSectionWidget({
    super.key,
    required this.isDifferentPhoto,
    required this.imageFile1,
    required this.imageFile2,
    required this.imageFile3,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    if (isDifferentPhoto) {
      return _buildSeparatePhotosSection(context);
    } else {
      return _buildSinglePhotoSection(context);
    }
  }

  Widget _buildSeparatePhotosSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.h),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).upload_photos,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: context.baseColor,
                      ),
                ),
                Text(
                  AppLocalizations.of(context).selectPhotosForBothPeople,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 10.sp,
                      ),
                ),
              ],
            ),
            // Header Section
            SizedBox(height: 12.h),
            // Photo Upload Cards
            Row(
              children: [
                Expanded(
                  child: _buildModernPhotoCard(
                    context,
                    imageFile: imageFile1,
                    title: AppLocalizations.of(context).uploadFirstPhoto,
                    subtitle: AppLocalizations.of(context).person1,
                    onTap: () => onImagePicked(1),
                    cardNumber: 1,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildModernPhotoCard(
                    context,
                    imageFile: imageFile2,
                    title: AppLocalizations.of(context).uploadSecondaryPhoto,
                    subtitle: AppLocalizations.of(context).person2,
                    onTap: () => onImagePicked(2),
                    cardNumber: 2,
                  ),
                ),
              ],
            ),

            // Progress Indicator
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePhotoSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.h),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).uploadPhoto,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: context.baseColor,
                      ),
                ),
                Text(
                  AppLocalizations.of(context).selectASinglePhoto,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                        fontSize: 10.sp,
                      ),
                ),
              ],
            ),
            // Header Section
            SizedBox(height: 12.h),
            // Single Photo Upload Card
            _buildModernPhotoCard(
              context,
              imageFile: imageFile3,
              title: AppLocalizations.of(context).upload_photo,
              subtitle: AppLocalizations.of(context).tapToSelect,
              onTap: () => onImagePicked(3),
              cardNumber: 1,
              isLarge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernPhotoCard(
    BuildContext context, {
    required File? imageFile,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int cardNumber,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: imageFile != null
                ? Colors.transparent
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: imageFile != null ? 2.5 : 1.5,
          ),
          color: imageFile != null
              ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
              : Theme.of(context).colorScheme.surface,
          boxShadow: imageFile != null
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageFile != null) ...[
                Image.file(
                  File(imageFile!.path),
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ],

              // Card Number Badge

              // Main Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (imageFile == null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          imageFile != null
                              ? Icons.check_circle_rounded
                              : Icons.add_photo_alternate_rounded,
                          color: imageFile != null
                              ? Colors.white
                              : Theme.of(context).colorScheme.outline,
                          size: 28.sp,
                        ),
                      ),
                    if (imageFile == null) SizedBox(height: 16.h),
                    Text(
                      imageFile != null
                          ? AppLocalizations.of(context).photoAdded
                          : title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: imageFile != null
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.sp,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateProgress() {
    if (isDifferentPhoto) {
      int uploaded = 0;
      if (imageFile1 != null) uploaded++;
      if (imageFile2 != null) uploaded++;
      return uploaded / 2;
    } else {
      return imageFile3 != null ? 1.0 : 0.0;
    }
  }
}
