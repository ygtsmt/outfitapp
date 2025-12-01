// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ginly/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginly/app/data/models/credit_model.dart';
import 'package:ginly/core/constants/layout_constants.dart';
import 'package:ginly/core/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomGenerateButton extends StatelessWidget {
  final String title;
  final GenerateType generateType;
  final Widget? leading;
  final void Function()? onTap;
  final bool isFilled;

  const CustomGenerateButton({
    Key? key,
    required this.title,
    required this.generateType,
    this.leading,
    this.onTap,
    required this.isFilled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final requirements = state.generateCreditRequirements;
        if (requirements == null) {
          return const SizedBox
              .shrink(); // Kredi sistemi yüklenmemişse gösterme
        }

        // Generate type'a göre gerekli kredi miktarını al
        final requiredCredits = _getRequiredCredits(requirements);

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              height: 36.h,
              decoration: isFilled
                  ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.h)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withAlpha(200),
                          Theme.of(context).colorScheme.primary.withAlpha(100),
                        ],
                      ),
                    )
                  : BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(width: 2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sol tarafta kredi ikonu ve miktarı
                  dummyTransparanWidget(context),
                  // Ortada title ve leading
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isFilled ? context.white : context.baseColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                  ),
                  // Sağ tarafta kredi ikonu ve miktarı (tekrar)
                  Row(
                    spacing: 4.w,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        requiredCredits.toString(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.baseColor,
                            ),
                      ),
                      Image.asset(
                        PngPaths.coin,
                        height: 20.h,
                        width: 20.w,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Row dummyTransparanWidget(BuildContext context) {
    return Row(
      spacing: 4.w,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          PngPaths.coin,
          height: 24.h, // Sabit ve orantılı ikon boyutu
          width: 24.w, color: Colors.transparent,
        ),
        Text(
          '0',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.transparent,
              ),
        ),
      ],
    );
  }

  int _getRequiredCredits(GenerateCreditRequirements requirements) {
    switch (generateType) {
      case GenerateType.image:
        return requirements.imageRequiredCredits;
      case GenerateType.realtimeImage:
        return requirements.realtimeImageRequiredCredits;
      case GenerateType.video:
        return requirements.videoRequiredCredits;
      case GenerateType.videoTemplate:
        return requirements.videoTemplateRequiredCredits;
    }
  }
}
