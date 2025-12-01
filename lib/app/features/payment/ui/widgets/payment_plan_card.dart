import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';

class PaymentPlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final bool isSelected;
  final bool isProPlan; // Pro plan mı kontrol etmek için
  final int credits; // Kredi sayısı
  final List<String> benefits; // Benefits listesi
  final bool isLoading;
  final VoidCallback? onTap;
  final bool showPurchaseButton;

  const PaymentPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.duration,
    this.isSelected = false,
    this.isProPlan = false, // Default false
    required this.credits,
    required this.benefits,
    this.isLoading = false,
    this.onTap,
    this.showPurchaseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.baseColor,
                  context.baseColor.withOpacity(0.8),
                  context.baseColor.withOpacity(0.6),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? Colors.grey[900]! : Colors.white,
                  isDark ? Colors.grey[850]! : Colors.grey[50]!,
                ],
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? context.baseColor
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: context.baseColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: context.baseColor.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap, // Parent widget handles tap
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              children: [
                // Left side - Plan info
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          if (isSelected)
                            Container(
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16.h,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black87),
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Kredi sayısını göster
                      SizedBox(height: 4.h),

                      // Benefits'i göster
                      if (benefits.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        ...benefits.map((benefit) => Padding(
                              padding: EdgeInsets.only(bottom: 2.h),
                              child: Text(
                                '• $benefit',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                ),
                              ),
                            )),
                      ],
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 40.h,
                  width: 1,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        isSelected
                            ? Colors.white.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Right side - Price
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isSelected ? Colors.white : context.baseColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        '/$duration',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? context.white.withOpacity(0.7)
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      if (isProPlan) ...[
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context).bestPrice,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: context.baseColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      if (showPurchaseButton) ...[
                        SizedBox(height: 8.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSelected ? Colors.white : context.baseColor,
                              foregroundColor:
                                  isSelected ? context.baseColor : Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 16.h,
                                    width: 16.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isSelected
                                            ? context.baseColor
                                            : Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context).purchase,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isSelected
                                          ? context.baseColor
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
