import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginfit/app/features/video_generate/ui/widgets/video_selection_card.dart';
import 'package:ginfit/generated/l10n.dart';

class VideoResolutionSection extends StatelessWidget {
  final VideoGenerateState state;
  final Function(String) onResolutionSelected;

  const VideoResolutionSection({
    super.key,
    required this.state,
    required this.onResolutionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context).resolution,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                AppLocalizations.of(context).optional,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: VideoSelectionCard(
                title: '480p',
                icon: Icons.high_quality_rounded,
                isSelected: state.requestModel?.resolution == '480p',
                onTap: () => onResolutionSelected('480p'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: VideoSelectionCard(
                title: '720p',
                icon: Icons.high_quality_rounded,
                isSelected: state.requestModel?.resolution == '720p',
                onTap: () => onResolutionSelected('720p'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: VideoSelectionCard(
                title: '1080p',
                icon: Icons.high_quality_rounded,
                isSelected: state.requestModel?.resolution == '1080p',
                onTap: () => onResolutionSelected('1080p'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
