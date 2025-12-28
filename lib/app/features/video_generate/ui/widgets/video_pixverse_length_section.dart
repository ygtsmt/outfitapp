import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginfit/generated/l10n.dart';
import 'package:ginfit/core/utils.dart';

class VideoPixverseLengthSection extends StatelessWidget {
  final VideoGenerateState state;
  final Function(String) onLengthSelected;

  const VideoPixverseLengthSection({
    super.key,
    required this.state,
    required this.onLengthSelected,
  });

  // 8s ve 1080p uyumsuzluğu kontrolü
  bool _isLengthDisabled(String length) {
    if (length == '8') {
      // 1080p seçiliyse veya fast mode seçiliyse 8s'yi disable yap
      return state.requestModel?.resolution == '1080p' ||
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
          AppLocalizations.of(context).length,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildLengthCard(
                context,
                length: '5',
                title: '5s',
                description: AppLocalizations.of(context).short_video,
                isSelected: state.requestModel?.length?.toString() == '5',
                onTap: () => onLengthSelected('5'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildLengthCard(
                context,
                length: '8',
                title: '8s',
                description: AppLocalizations.of(context).long_video,
                isSelected: state.requestModel?.length?.toString() == '8',
                onTap: _isLengthDisabled('8')
                    ? () => _showIncompatibilityMessage(context)
                    : () => onLengthSelected('8'),
                isDisabled: _isLengthDisabled('8'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLengthCard(
    BuildContext context, {
    required String length,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDisabled
              ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
              : isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  size: 20.w,
                  color: isDisabled
                      ? Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.5)
                      : isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDisabled
                        ? Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withOpacity(0.4)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              SizedBox(height: 8.h),
              Icon(
                Icons.check_circle,
                size: 20.w,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
