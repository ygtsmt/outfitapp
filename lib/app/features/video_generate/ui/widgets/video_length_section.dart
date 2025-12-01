import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginly/app/features/video_generate/ui/widgets/video_selection_card.dart';
import 'package:ginly/generated/l10n.dart';

class VideoLengthSection extends StatelessWidget {
  final VideoGenerateState state;
  final Function(String) onLengthSelected;

  const VideoLengthSection({
    super.key,
    required this.state,
    required this.onLengthSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context).length,
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
                title: '5s',
                icon: Icons.timer_rounded,
                isSelected: state.requestModel?.length == 5,
                onTap: () => onLengthSelected('5'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: VideoSelectionCard(
                title: '10s',
                icon: Icons.timer_rounded,
                isSelected: state.requestModel?.length == 10,
                onTap: () => onLengthSelected('10'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
