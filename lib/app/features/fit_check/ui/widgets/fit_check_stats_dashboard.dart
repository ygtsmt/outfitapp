import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/app/features/fit_check/ui/widgets/fit_check_stat_item.dart';
import 'package:comby/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FitCheckStatsDashboard extends StatelessWidget {
  final Map<DateTime, List<FitCheckLog>> events;
  final int currentStreak;
  final String? userName;

  const FitCheckStatsDashboard({
    super.key,
    required this.events,
    required this.currentStreak,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    // Calculation Logic for stats
    final allLogs = events.values.expand((element) => element).toList();
    final totalChecks = allLogs.length;

    // Find Top Style
    final styleCounts = <String, int>{};
    for (var log in allLogs) {
      if (log.overallStyle != null) {
        styleCounts[log.overallStyle!] =
            (styleCounts[log.overallStyle!] ?? 0) + 1;
      }
    }
    String topStyle = '-';
    if (styleCounts.isNotEmpty) {
      final sortedStyles = styleCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topStyle = sortedStyles.first.key;
    }

    // Motivational Text Logic
    String motivationText = AppLocalizations.of(context).noStreakYet;
    Color motivationColor = Colors.grey[600]!;

    // Helper to personalize text
    String personalize(String text) {
      if (userName != null && userName!.isNotEmpty) {
        return '$text $userName!';
      }
      return text;
    }

    if (currentStreak >= 30) {
      motivationText =
          personalize(AppLocalizations.of(context).streakLegendary);
      motivationColor = Colors.purple;
    } else if (currentStreak >= 7) {
      motivationText = personalize(AppLocalizations.of(context).streakAwesome);
      motivationColor = Colors.orange[700]!;
    } else if (currentStreak >= 3) {
      motivationText = personalize(AppLocalizations.of(context).streakSuper);
      motivationColor = Colors.blue[700]!;
    } else if (currentStreak > 0) {
      motivationText = personalize(AppLocalizations.of(context).streakGood);
      motivationColor = Colors.green[700]!;
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              FitCheckStatItem(
                label: AppLocalizations.of(context).total,
                value: '$totalChecks',
                suffix: ' ${AppLocalizations.of(context).check}',
              ),
              _buildDivider(),
              FitCheckStatItem(
                label: AppLocalizations.of(context).currentStreak,
                value: '$currentStreak',
                suffix: ' ${AppLocalizations.of(context).day}',
                isAccent: true, // Highlight streak
              ),
              _buildDivider(),
              FitCheckStatItem(
                label: AppLocalizations.of(context).favoriteStyle,
                value: topStyle.length == 1 ? '🤔' : topStyle,
                isStyle: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: motivationColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tips_and_updates, size: 16.sp, color: motivationColor),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  motivationText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: motivationColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32.h,
      width: 1,
      color: Colors.grey.shade200,
    );
  }
}
