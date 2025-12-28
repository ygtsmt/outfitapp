import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginfit/generated/l10n.dart';

class VideoPromptSection extends StatelessWidget {
  final TextEditingController promptController;
  final VideoGenerateState state;

  const VideoPromptSection({
    super.key,
    required this.promptController,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = state.requestModel?.image != null;
    final isImageToVideo = hasImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context).describe_your_video,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isImageToVideo
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                isImageToVideo
                    ? AppLocalizations.of(context).optional
                    : AppLocalizations.of(context).required,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isImageToVideo
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: promptController,
              maxLines: 5,
              minLines: 5,
              expands: false,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).describe_video_hint,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
