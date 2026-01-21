import 'package:comby/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityHeatmapWidget extends StatelessWidget {
  const ActivityHeatmapWidget({super.key});

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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  "12 Gün Serisi 🔥",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Mock Heatmap Grid (52 weeks is too wide, maybe just last 4 weeks or a simplified view)
          // For now, let's just do a row of squares for the last 14 days
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14,
              reverse: true, // Show newest first
              itemBuilder: (context, index) {
                // Mock data: random activity level 0-4
                final intensity = (index * 7) % 5;
                return Container(
                  width: 30.w,
                  margin: EdgeInsets.only(left: 4.w),
                  decoration: BoxDecoration(
                    color: _getColorForIntensity(intensity, context),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      _getDayLabel(index),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: intensity > 2 ? Colors.white : Colors.grey[600],
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
              _buildStat("42", "Kombin"),
              _buildStat("15", "Fit Check"),
              _buildStat("8", "Favori"),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForIntensity(int intensity, BuildContext context) {
    if (intensity == 0) return Colors.grey.shade100;
    return context.baseColor.withOpacity(intensity * 0.25);
  }

  String _getDayLabel(int index) {
    final date = DateTime.now().subtract(Duration(days: index));
    return "${date.day}";
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
