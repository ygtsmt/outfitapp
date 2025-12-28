import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:ginfit/app/features/closet/services/closet_analysis_service.dart';

class ClosetAnalyticsWidget extends StatefulWidget {
  const ClosetAnalyticsWidget({super.key});

  @override
  State<ClosetAnalyticsWidget> createState() => _ClosetAnalyticsWidgetState();
}

class _ClosetAnalyticsWidgetState extends State<ClosetAnalyticsWidget> {
  ClosetStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await GetIt.I<ClosetAnalysisService>().getClosetStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  // Helper to map color names to Flutter Colors
  Color _getColorFromName(String name) {
    switch (name.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.grey.shade200; // Visible on white bg
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'beige':
        return Color(0xFFF5F5DC);
      default:
        return Colors.teal; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 150.h,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_stats == null || _stats!.totalItems == 0) {
      return Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(child: Text("Henüz dolabın boş! Ürün ekle.")),
      );
    }

    // Prepare chart data (top 5 colors)
    final sortedColors = _stats!.colorDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topColors = sortedColors.take(5).toList();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dolap Analizi",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "${_stats!.totalItems} Parça",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4C40F7), // Brand/Theme color
                    ),
                  ),
                ],
              ),
              // Pie Chart
              SizedBox(
                height: 80.h,
                width: 80.w,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 20,
                    sections: topColors.map((e) {
                      return PieChartSectionData(
                          color: _getColorFromName(e.key),
                          value: e.value.toDouble(),
                          title: '',
                          radius: 12,
                          showTitle: false);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Simple Bar for Categories (Top 3)
          Row(
            children: _stats!.categoryCount.entries.take(3).map((e) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        e.key,
                        style: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${e.value}",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
