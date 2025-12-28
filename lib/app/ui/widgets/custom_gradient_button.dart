// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ginfit/core/core.dart';
import 'package:flutter/material.dart';

import 'package:ginfit/core/constants/layout_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomGradientButton extends StatelessWidget {
  final String title;
  final String? requiredCredit;
  final Widget? leading;
  final void Function()? onTap;
  final bool isFilled;
  const CustomGradientButton({
    Key? key,
    required this.title,
    this.requiredCredit,
    this.leading,
    this.onTap,
    required this.isFilled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: requiredCredit != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              if (requiredCredit != null)
                Row(
                  spacing: 4.w,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      PngPaths.coin,
                      height: 24.h, // Sabit ve orantılı ikon boyutu
                      width: 24.w, color: Colors.transparent,
                    ),
                    Text(
                      requiredCredit ?? '0',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.transparent,
                          ),
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) leading!,
                  LayoutConstants.lowEmptyWidth,
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isFilled ? context.white : context.baseColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                  ),
                ],
              ),
              if (requiredCredit != null)
                Row(
                  spacing: 4.w,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      requiredCredit ?? '0',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.baseColor,
                          ),
                    ),
                    Image.asset(
                      PngPaths.coin,
                      height: 20.h, // Sabit ve orantılı ikon boyutu
                      width: 20.w,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
