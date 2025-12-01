import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginly/app/features/video_generate/ui/widgets/video_image_upload_card.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';

class VideoImageUploadSection extends StatelessWidget {
  final VideoGenerateState state;
  final Function(BuildContext, bool) onImagePickerDialog;

  const VideoImageUploadSection({
    super.key,
    required this.state,
    required this.onImagePickerDialog,
  });

  void _clearImage(BuildContext context, bool isFirstImage) {
    getIt<VideoGenerateBloc>().add(ClearImageEvent(isFirstImage: isFirstImage));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context).upload_images,
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
              child: VideoImageUploadCard(
                title: AppLocalizations.of(context).start_image,
                subtitle: AppLocalizations.of(context).beginning_of_video,
                icon: Icons.play_arrow_rounded,
                onTap: () => onImagePickerDialog(context, true),
                onClearImage: () => _clearImage(context, true),
                imageUrl: state.requestModel?.image,
                isLoading: state.uploadStatus == EventStatus.processing &&
                    state.requestModel?.image == null,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: VideoImageUploadCard(
                title: AppLocalizations.of(context).tail_image,
                subtitle: AppLocalizations.of(context).end_of_video,
                icon: Icons.stop_rounded,
                onTap: () => onImagePickerDialog(context, false),
                onClearImage: () => _clearImage(context, false),
                imageUrl: state.requestModel?.imageTail,
                isLoading: state.uploadStatus == EventStatus.processing &&
                    state.requestModel?.imageTail == null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
