import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';

class PhotoUploadCardWidget extends StatelessWidget {
  final File? imageFile;
  final String title;
  final VoidCallback onTap;
  final bool isLarge;

  const PhotoUploadCardWidget({
    super.key,
    required this.imageFile,
    required this.title,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: imageFile != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: imageFile != null ? 2 : 1,
          ),
          color: imageFile != null
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
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
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        imageFile != null
                            ? Icons.check_circle
                            : Icons.add_photo_alternate,
                        color: imageFile != null
                            ? context.white
                            : Theme.of(context).colorScheme.outline,
                        size: 24,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        imageFile != null
                            ? AppLocalizations.of(context).photoAdded
                            : title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: imageFile != null
                                  ? context.white
                                  : Theme.of(context).colorScheme.outline,
                              fontWeight: imageFile != null
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 9.sp,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
