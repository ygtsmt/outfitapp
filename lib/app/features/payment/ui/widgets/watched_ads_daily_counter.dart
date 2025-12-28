// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginfit/app/features/payment/bloc/payment_bloc.dart';
import 'package:ginfit/core/core.dart';

class WatchedAdsDailyCounter extends StatelessWidget {
  const WatchedAdsDailyCounter({super.key});

  @override
  Widget build(BuildContext context) {
    // Progress bar her zaman 60 üzerinden (3 reklam = 1 claim)
    // iOS: Sınırsız claim, Android: Günde 1 claim
    const claimLimit = 60;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final watched = profileState.profileInfo?.dailyAdsWatched ?? 0;

        // Progress bar her zaman 60'a göre dolar
        final progress = (watched / claimLimit).clamp(0.0, 1.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140.h,
              height: 140.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                color: Colors.white,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120.h,
                    height: 120.h,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade300,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(context.baseColor),
                    ),
                  ),
                  BlocBuilder<PaymentBloc, PaymentState>(
                    builder: (context, paymentState) {
                      final isLoading =
                          paymentState.addCreditForRewardedStatus ==
                              EventStatus.processing;

                      return isLoading
                          ? SizedBox(
                              width: 30.h,
                              height: 30.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: context.baseColor,
                              ),
                            )
                          : Text(
                              "$watched / $claimLimit", // Her claim için 60 kredi (3 reklam)
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.baseColor,
                                  ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
