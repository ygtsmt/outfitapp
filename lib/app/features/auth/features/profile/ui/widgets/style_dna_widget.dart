import 'package:comby/core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StyleDNAWidget extends StatelessWidget {
  const StyleDNAWidget({super.key});

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
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
              Text(
                "Gemini 3 flash ",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              )
            ],
          ),

          // Color Palette

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
                    dataEntries: [
                      const RadarEntry(value: 80), // Casual
                      const RadarEntry(value: 40), // Classic
                      const RadarEntry(value: 60), // Sporty
                      const RadarEntry(value: 30), // Vintage
                      const RadarEntry(value: 50), // Minimalist
                    ],
                  ),
                ],
                getTitle: (index, angle) {
                  const titles = [
                    'Casual',
                    'Classic',
                    'Sporty',
                    'Vintage',
                    'Minimal'
                  ];
                  return RadarChartTitle(text: titles[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
