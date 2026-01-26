import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/generated/l10n.dart';

class MonthlyStatsInstruction extends StatelessWidget {
  const MonthlyStatsInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Text(
          AppLocalizations.of(context).instructionSelectDay,
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
