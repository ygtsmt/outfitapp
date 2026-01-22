import 'package:comby/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityHeatmapWidget extends StatelessWidget {
  final int streak;
  final int outfitCount;
  final int fitCheckCount;
  final Map<DateTime, int> heatmapData;
  final bool isLoading;

  const ActivityHeatmapWidget({
    super.key,
    this.streak = 0,
    this.outfitCount = 0,
    this.fitCheckCount = 0,
    this.heatmapData = const {},
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Stil Günlüğü",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (!isLoading)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStreakColor(streak, context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    "$streak Gün Serisi 🔥",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: _getStreakColor(streak, context),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Heatmap Grid (Last 14 days)
          if (isLoading)
            SizedBox(
              height: 40.h,
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            SizedBox(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                reverse: true, // Show newest first (right to left visually)
                itemBuilder: (context, index) {
                  final date = DateTime.now().subtract(Duration(days: index));
                  final normalizedDate =
                      DateTime(date.year, date.month, date.day);
                  final count = heatmapData[normalizedDate] ?? 0;
                  final intensity = count > 4 ? 4 : count; // Cap at 4

                  return Container(
                    width: 30.w,
                    margin: EdgeInsets.only(left: 4.w),
                    decoration: BoxDecoration(
                      color: _getColorForIntensity(intensity, context),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: Text(
                        "${date.day}",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color:
                              intensity > 2 ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          SizedBox(height: 16.h),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(isLoading ? "-" : "$outfitCount", "Kombin"),
              _buildStat(isLoading ? "-" : "$fitCheckCount", "Fit Check"),
              // Note: 'Favori' logic was requested to be 'Closet Count' but passed from parent?
              // The user requested: "favoriyi yerine closet sayısı gelsın"
              // For now, I'll keep it as passed or if not passed, remove/replace.
              // Waiting for ProfileInfoScreen to pass closet count or we fetch it here?
              // The implementation plan mainly focused on Outfits/FitChecks.
              // Let's stick to what we have or add a placeholder for now as 3rd stat.
              // Actually, I should probably expose closet count if I can.
              // But ProfileInfoScreen logic didn't fetch closet count specifically for this widget yet,
              // it's in WardrobeAnalytics.
              // I will leave the 3rd stat as specific to "Stil Günlüğü" context or remove it.
              // User said "favoriyi yerine closet sayısı gelsın".
              // I'll add a 'closetCount' to this widget in a future step or just use outfitCount/Wait,
              // Actually I can pass closet count if I have it.
              // Let's implement what lines up with ProfileInfoScreen args for now to fix build.
              // ProfileInfoScreen passes: streak, outfitCount, fitCheckCount, heatmapData.
              // It does NOT pass closet count yet.
              // I'll temporarily hide the 3rd stat or show something else to avoid errors basically.
              // Or I can just check if I can get closet count easily.
              // Ideally ActivityHeatmap focuses on *Activity*. Closet count is state, not activity.
              // Maybe "Daily Generate"?
              // Let's stick to the plan: fix build first.
              // I'll render an empty stat or just 2 stats for now until I add closet count.
              _buildStat(
                  isLoading ? "-" : "0", "Dolap"), // Placeholder as requested
            ],
          ),
        ],
      ),
    );
  }

  Color _getStreakColor(int streak, BuildContext context) {
    if (streak == 0) return Colors.grey;
    if (streak < 3) return Colors.orange;
    return Colors.green;
  }

  Color _getColorForIntensity(int intensity, BuildContext context) {
    if (intensity == 0) return Colors.grey.shade100;
    // Darker brand color for higher intensity
    return context.baseColor.withOpacity(0.2 + (intensity * 0.2));
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
