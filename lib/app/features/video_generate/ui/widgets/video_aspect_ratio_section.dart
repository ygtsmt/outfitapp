import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginfit/app/features/video_generate/ui/widgets/video_selection_card.dart';
import 'package:ginfit/generated/l10n.dart';

class VideoAspectRatioSection extends StatelessWidget {
  final VideoGenerateState state;
  final Function(String) onAspectRatioSelected;

  const VideoAspectRatioSection({
    super.key,
    required this.state,
    required this.onAspectRatioSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context).aspect_ratio,
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
                title: '16:9',
                icon: Icons.aspect_ratio_rounded,
                isSelected: state.requestModel?.aspectRatio == '16:9',
                onTap: () => onAspectRatioSelected('16:9'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: VideoSelectionCard(
                title: '9:16',
                icon: Icons.aspect_ratio_rounded,
                isSelected: state.requestModel?.aspectRatio == '9:16',
                onTap: () => onAspectRatioSelected('9:16'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: VideoSelectionCard(
                title: '1:1',
                icon: Icons.aspect_ratio_rounded,
                isSelected: state.requestModel?.aspectRatio == '1:1',
                onTap: () => onAspectRatioSelected('1:1'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: VideoSelectionCard(
                title: '4:3',
                icon: Icons.aspect_ratio_rounded,
                isSelected: state.requestModel?.aspectRatio == '4:3',
                onTap: () => onAspectRatioSelected('4:3'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: VideoSelectionCard(
                title: '3:4',
                icon: Icons.aspect_ratio_rounded,
                isSelected: state.requestModel?.aspectRatio == '3:4',
                onTap: () => onAspectRatioSelected('3:4'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(), // Empty space for alignment
            ),
          ],
        ),
      ],
    );
  }
}
