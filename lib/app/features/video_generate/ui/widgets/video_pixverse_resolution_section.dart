import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginly/generated/l10n.dart';
import 'package:ginly/core/utils.dart';

class VideoPixverseResolutionSection extends StatelessWidget {
  final VideoGenerateState state;
  final Function(String) onResolutionSelected;

  const VideoPixverseResolutionSection({
    super.key,
    required this.state,
    required this.onResolutionSelected,
  });

  // 8s ve 1080p uyumsuzluğu kontrolü
  bool _isResolutionDisabled(String resolution) {
    if (resolution == '1080p') {
      // 8s seçiliyse veya fast mode seçiliyse 1080p'yi disable yap
      return state.requestModel?.length == 8 ||
          state.requestModel?.mode == 'fast';
    }
    return false;
  }

  // Uyumsuzluk mesajını göster
  void _showIncompatibilityMessage(BuildContext context) {
    Utils.showToastMessage(
      context: context,
      content: AppLocalizations.of(context).length_resolution_incompatible,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).resolution,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildResolutionCard(
                context,
                resolution: '360p',
                title: '360p',
                description: AppLocalizations.of(context).low_quality,
                isSelected: state.requestModel?.resolution == '360p',
                onTap: () => onResolutionSelected('360p'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildResolutionCard(
                context,
                resolution: '540p',
                title: '540p',
                description: AppLocalizations.of(context).medium_quality,
                isSelected: state.requestModel?.resolution == '540p',
                onTap: () => onResolutionSelected('540p'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildResolutionCard(
                context,
                resolution: '720p',
                title: '720p',
                description: AppLocalizations.of(context).high_quality,
                isSelected: state.requestModel?.resolution == '720p',
                onTap: () => onResolutionSelected('720p'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildResolutionCard(
                context,
                resolution: '1080p',
                title: '1080p',
                description: AppLocalizations.of(context).ultra_quality,
                isSelected: state.requestModel?.resolution == '1080p',
                onTap: _isResolutionDisabled('1080p')
                    ? () => _showIncompatibilityMessage(context)
                    : () => onResolutionSelected('1080p'),
                isDisabled: _isResolutionDisabled('1080p'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResolutionCard(
    BuildContext context, {
    required String resolution,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isDisabled
              ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
              : isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isDisabled
                ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
                : isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDisabled
                        ? Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.5)
                        : isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDisabled
                        ? Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.4)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10.sp,
                  ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              SizedBox(height: 4.h),
              Icon(
                Icons.check_circle,
                size: 16.w,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
