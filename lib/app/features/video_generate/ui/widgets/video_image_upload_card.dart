import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/generated/l10n.dart';

class VideoImageUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClearImage;
  final String? imageUrl;
  final bool isLoading;

  const VideoImageUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.onClearImage,
    this.imageUrl,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              if (hasImage && onClearImage != null) {
                onClearImage!();
              } else {
                onTap();
              }
            },
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasImage
                ? Colors.transparent
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: hasImage ? 2 : 1,
          ),
          color: hasImage
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Arkaplan görseli
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    );
                  },
                ),
              ),

            // Overlay
            if (hasImage)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),

            // Loading overlay
            if (isLoading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                    strokeWidth: 2.w,
                  ),
                ),
              ),

            // Ana içerik
            if (!isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      hasImage ? Icons.delete_outline : icon,
                      size: 24.w,
                      color: hasImage
                          ? Colors.white
                          : Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      hasImage ? 'Remove' : title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: hasImage
                                ? Colors.white
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            fontWeight:
                                hasImage ? FontWeight.w600 : FontWeight.w500,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!hasImage) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.7),
                              fontSize: 10.sp,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
