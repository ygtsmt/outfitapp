import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/video_generate/bloc/video_generate_bloc.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';

class VideoGenerateButton extends StatelessWidget {
  final VideoGenerateState state;
  final VoidCallback onGenerate;

  const VideoGenerateButton({
    super.key,
    required this.state,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isProcessing = state.uploadStatus == EventStatus.processing ||
        state.status == EventStatus.processing;

    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isProcessing ? null : onGenerate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isProcessing) ...[
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
              ] else ...[
                Icon(
                  Icons.play_arrow_rounded,
                  size: 24.w,
                  color: Colors.white,
                ),
                SizedBox(width: 8.w),
              ],
              Text(
                isProcessing
                    ? AppLocalizations.of(context).processing_request
                    : AppLocalizations.of(context).generate_with_pollo,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
