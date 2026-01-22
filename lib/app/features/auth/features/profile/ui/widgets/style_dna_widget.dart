import 'package:comby/core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StyleDNAWidget extends StatefulWidget {
  final Map<String, int> styleScores;
  final String analysis;
  final bool isLoading;

  const StyleDNAWidget({
    super.key,
    required this.styleScores,
    required this.analysis,
    this.isLoading = false,
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
                      Text(
                        "Stil DNA'sı",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
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
                      )
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
}
