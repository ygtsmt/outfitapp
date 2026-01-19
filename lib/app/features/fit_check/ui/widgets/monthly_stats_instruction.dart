import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MonthlyStatsInstruction extends StatelessWidget {
  const MonthlyStatsInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Text(
          'Geçmiş kombinleri incelemek için takvimden gün seçin 👆',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 13.sp,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
