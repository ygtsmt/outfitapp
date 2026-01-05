// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:comby/core/core.dart';
import 'package:flutter/material.dart';

import 'package:comby/core/constants/layout_constants.dart';
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
            
            ],
          ),
        ),
      ),
    );
  }
}
