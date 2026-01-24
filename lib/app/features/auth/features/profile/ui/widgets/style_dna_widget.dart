import 'package:comby/core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StyleDNAWidget extends StatefulWidget {
  final Map<String, int> styleScores;
  final String analysis;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final DateTime? lastUpdated;

  const StyleDNAWidget({
    super.key,
    required this.styleScores,
    required this.analysis,
    this.isLoading = false,
    this.onRefresh,
    this.lastUpdated,
  });

  @override
  State<StyleDNAWidget> createState() => _StyleDNAWidgetState();
}

class _StyleDNAWidgetState extends State<StyleDNAWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
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
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Stil DNA'sı",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (widget.onRefresh != null)
                            GestureDetector(
                              onTap: widget.isLoading ? null : widget.onRefresh,
                              child: Icon(
                                Icons.refresh,
                                size: 20.sp,
                                color: widget.isLoading
                                    ? Colors.grey[400]
                                    : context.baseColor,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        widget.analysis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: _isExpanded ? 50 : 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.analysis.length > 150)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              _isExpanded ? "Daha az göster" : "Devamını gör",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: context.baseColor,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 8.h),
                      Text(
                        "Gemini 3 Flash",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                      if (widget.lastUpdated != null)
                        Text(
                          _formatLastUpdated(widget.lastUpdated!),
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Radar Chart
              SizedBox(
                height: 150.h,
                width: 150.w,
                child: RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    ticksTextStyle: const TextStyle(color: Colors.transparent),
                    gridBorderData:
                        BorderSide(color: Colors.grey.shade200, width: 2),
                    tickBorderData:
                        BorderSide(color: Colors.grey.shade200, width: 2),
                    titlePositionPercentageOffset: 0.15,
                    titleTextStyle: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold),
                    dataSets: [
                      RadarDataSet(
                        fillColor: context.baseColor.withOpacity(0.3),
                        borderColor: context.baseColor.withBlue(200),
                        entryRadius: 4,
                        dataEntries: widget.styleScores.entries.map((entry) {
                          return RadarEntry(value: entry.value.toDouble());
                        }).toList(),
                      ),
                    ],
                    getTitle: (index, angle) {
                      if (index < widget.styleScores.length) {
                        return RadarChartTitle(
                            text: widget.styleScores.keys.elementAt(index));
                      }
                      return const RadarChartTitle(text: "");
                    },
                  ),
                ),
              ),
            ],
          ),
          if (widget.isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatLastUpdated(DateTime lastUpdated) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Şimdi güncellendi';
        }
        return '${difference.inMinutes} dakika önce';
      }
      return 'Bugün güncellendi';
    } else if (difference.inDays == 1) {
      return 'Dün güncellendi';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    }
  }
}
