import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginfit/app/features/video_generate/ui/widgets/video_resolution_section.dart';
import 'package:ginfit/app/features/video_generate/ui/widgets/video_length_section.dart';
import 'package:ginfit/app/features/video_generate/ui/widgets/video_aspect_ratio_section.dart';
import 'package:ginfit/generated/l10n.dart';

class VideoSettingsSection extends StatelessWidget {
  final VideoGenerateState state;
  final Function(String) onResolutionSelected;
  final Function(String) onLengthSelected;
  final Function(String) onAspectRatioSelected;

  const VideoSettingsSection({
    super.key,
    required this.state,
    required this.onResolutionSelected,
    required this.onLengthSelected,
    required this.onAspectRatioSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = state.requestModel?.image != null;
    final isImageToVideo = hasImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Mode badge
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 20.w,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              AppLocalizations.of(context).pollo_settings,
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
                    ? AppLocalizations.of(context).image_to_video
                    : AppLocalizations.of(context).text_to_video,
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
        SizedBox(height: 20.h),

        // Resolution Section
        VideoResolutionSection(
          state: state,
          onResolutionSelected: onResolutionSelected,
        ),
        SizedBox(height: 20.h),

        // Length Section
        VideoLengthSection(
          state: state,
          onLengthSelected: onLengthSelected,
        ),
        SizedBox(height: 20.h),

        // Aspect Ratio Section - Only for Text to Video
        if (!isImageToVideo) ...[
          VideoAspectRatioSection(
            state: state,
            onAspectRatioSelected: onAspectRatioSelected,
          ),
          SizedBox(height: 20.h),
        ],
      ],
    );
  }
}
