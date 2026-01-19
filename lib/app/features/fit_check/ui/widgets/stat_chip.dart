import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FitCheckStatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const FitCheckStatChip({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    // Color parametresini kaldırdık veya opsiyonel yaptık
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        // Daha soft, neredeyse beyaz/gri bir arka plan
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
            color: Colors.grey[200]!,
            width: 1), // İnce bir çerçeve modern durur
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.black87, // İkonu nötr yaptık
            size: 14.sp,
          ),
          SizedBox(width: 8.w),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black87,
                letterSpacing: -0.2, // Daha sıkı ve modern bir görünüm
              ),
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' $label',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors
                        .black54, // Label'ı biraz daha soluk yaparak hiyerarşi kurduk
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
