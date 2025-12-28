import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginfit/app/features/realtime/bloc/realtime_bloc.dart';
import 'package:ginfit/core/constants/layout_constants.dart';
import 'package:ginfit/core/core.dart';

class RealtimeGeneratedImageWidget extends StatelessWidget {
  const RealtimeGeneratedImageWidget({
    super.key,
    required this.state,
    required this.profileState,
    required this.onReportPressed,
    required this.isKeyboardVisible,
  });

  final RealtimeState state;
  final ProfileState profileState;
  final VoidCallback onReportPressed;
  final bool isKeyboardVisible;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            blurRadius: 25.r,
            offset: const Offset(0, 12),
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            (state.realtimePhotoBase64 != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.memory(
                      base64Decode(state.realtimePhotoBase64!),
                      fit: isKeyboardVisible ? BoxFit.contain : BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 48.w,
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox()),
            // Report Icon - Her zaman resmin sağ üst köşesinde
            Positioned(
              top: 8.h,
              right: isKeyboardVisible ? 42.w : 8.w,
              child: GestureDetector(
                onTap: onReportPressed,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(LayoutConstants.defaultRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.report,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
