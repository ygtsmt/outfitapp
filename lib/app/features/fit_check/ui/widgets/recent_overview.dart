import 'package:comby/app/features/fit_check/models/fit_check_model.dart';
import 'package:comby/app/features/fit_check/ui/widgets/recent_thumbnail.dart';
import 'package:comby/generated/l10n.dart';

import 'package:auto_route/auto_route.dart';
import 'package:comby/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FitCheckRecentOverview extends StatelessWidget {
  final List<FitCheckLog> recentFitChecks;

  const FitCheckRecentOverview({
    super.key,
    required this.recentFitChecks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).last30Days,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.router.push(const FitCheckHistoryScreenRoute());
                  },
                  child: Text(
                    AppLocalizations.of(context).allTabs,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue, // Or usage of primary color
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thumbnails
          SizedBox(
            height: 90.h,
            child: recentFitChecks.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context).noFitCheckLogsYet,
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
}
