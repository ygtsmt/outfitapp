import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:comby/app/features/closet/services/closet_analysis_service.dart';

class WardrobeAnalyticsWidget extends StatefulWidget {
  const WardrobeAnalyticsWidget({super.key});

  @override
  State<WardrobeAnalyticsWidget> createState() =>
      _WardrobeAnalyticsWidgetState();
}

class _WardrobeAnalyticsWidgetState extends State<WardrobeAnalyticsWidget> {
  WardrobeStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await GetIt.I<WardrobeAnalysisService>().getWardrobeStats();
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

          // Capsule Score Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4C40F7).withOpacity(0.05),
                  Color(0xFF4C40F7).withOpacity(0.1)
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border:
                  Border.all(color: const Color(0xFF4C40F7).withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 50.w,
                      width: 50.w,
                      child: CircularProgressIndicator(
                        value: (_stats?.capsuleScore ?? 0) / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF4C40F7),
                        strokeWidth: 6,
                      ),
                    ),
                    Text(
                      "%${_stats?.capsuleScore ?? 0}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4C40F7),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kapsül Dolap Skoru",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _getCapsuleStatus(_stats?.capsuleScore ?? 0),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Favori Renkler",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SizedBox(
                  height: 24.w,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildColorDot(Colors.black),
                      _buildColorDot(Colors.white, border: true),
                      _buildColorDot(Colors.blueGrey),
                      _buildColorDot(const Color(0xFFE0C097)), // Beige
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

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

  String _getCapsuleStatus(int score) {
    if (score >= 90) return "Mükemmel! Tam bir kapsül dolap uzmanısın.";
    if (score >= 70) return "Harika gidiyorsun, çok dengeli.";
    if (score >= 50) return "İyi başlangıç, biraz daha denge lazım.";
    return "Henüz yolun başındasın, dolabını sadeleştir.";
  }

  Widget _buildColorDot(Color color, {bool border = false}) {
    return Container(
      width: 24.w,
      height: 24.w,
      margin: EdgeInsets.only(right: 8.w),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border ? Border.all(color: Colors.grey.shade300) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
