import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/data/models/features_doc_model.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TemplatePreviewWidget extends StatelessWidget {
  final VideoTemplate videoTemplate;

  const TemplatePreviewWidget({
    super.key,
    required this.videoTemplate,
  });

  @override
  Widget build(BuildContext context) {
    // URL boşsa veya null ise loading widget göster
    if (videoTemplate.previewUrl == null || videoTemplate.previewUrl!.isEmpty) {
      return _buildLoadingWidget(context);
    }

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: videoTemplate.previewUrl!,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildLoadingWidget(context),
          errorWidget: (context, url, error) => _buildErrorWidget(context),
        ),
        // Alttan üste doğru siyah gradient gölge
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7), // Alt kısım daha koyu
                  Colors.black.withOpacity(0.4), // Orta kısım
                  Colors.black.withOpacity(0.1), // Üst kısım hafif
                  Colors.transparent, // En üst tamamen şeffaf
                ],
                stops: const [0.0, 0.3, 0.7, 1.0], // Gradient geçiş noktaları
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.fourRotatingDots(
              color: Theme.of(context).colorScheme.primary,
              size: 32.h,
            ),
            SizedBox(height: 12.h),
            Text(
              AppLocalizations.of(context).video_preview_loading,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: Theme.of(context).colorScheme.outline,
              size: 48.h,
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).video_preview_error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
