import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final bool? forPhone;

  const InfoTile({
    Key? key,
    required this.title,
    required this.value,
    this.forPhone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 12.sp)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value.isEmpty ? '$title not found' : value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Divider(thickness: 0 / 5),
        const SizedBox(height: 8),
      ],
    );
  }
}
