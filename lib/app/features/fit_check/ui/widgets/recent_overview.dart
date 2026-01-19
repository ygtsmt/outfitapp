import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/app/features/fit_check/ui/widgets/fit_check_stat_item.dart';
import 'package:comby/app/features/fit_check/ui/widgets/recent_thumbnail.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FitCheckRecentOverview extends StatelessWidget {
  final List<FitCheckLog> recentFitChecks;
  final Map<DateTime, List<FitCheckLog>> events;
  final int currentStreak;

  const FitCheckRecentOverview({
    super.key,
    required this.recentFitChecks,
    required this.events,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    // Calculation Logic for stats
    final allLogs = events.values.expand((element) => element).toList();
    final totalChecks = allLogs.length;
    // Removed activeDays calculation

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

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Dashboard Row

          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
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
                  label: 'Toplam',
                  value: '$totalChecks',
                  suffix: ' Check',
                ),
                _buildDivider(),
                FitCheckStatItem(
                  label: 'Mevcut Seri',
                  value: '$currentStreak',
                  suffix: ' Gün',
                  isAccent: true, // Highlight streak
                ),
                _buildDivider(),
                FitCheckStatItem(
                  label: 'Favori Tarz',
                  value: topStyle.length == 1 ? '🤔' : topStyle,
                  isStyle: true,
                ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
            child: Text(
              'SON 30 GÜN',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Thumbnails
          SizedBox(
            height: 90.h,
            child: recentFitChecks.isEmpty
                ? Center(
                    child: Text(
                      'Henüz FitCheck kaydı yok',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: recentFitChecks.length,
                    itemBuilder: (context, index) {
                      final log = recentFitChecks[index];
                      return RecentFitCheckThumbnail(log: log);
                    },
                  ),
          ),
        ],
      ),
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
