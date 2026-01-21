import 'package:comby/core/core.dart';
import 'package:comby/app/ui/widgets/profile_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String? photoUrl;
  final String displayName;
  final String styleTitle;
  final int level;
  final String uid;

  const ProfileHeaderWidget({
    super.key,
    required this.photoUrl,
    required this.displayName,
    this.styleTitle = "Minimalist Trendsetter", // Default/Mock for now
    this.level = 5, // Default/Mock
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 8.w,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.baseColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ProfileImageNetwork(
                    url: photoUrl,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: context.baseColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    "Lvl $level",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                spacing: 8.h,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5), // Light purple
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      styleTitle,
                      style: TextStyle(
                        color: const Color(0xFF9C27B0),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: uid));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("UID Copied"),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fingerprint,
                              size: 14.sp, color: Colors.grey),
                          SizedBox(width: 4.w),
                          Text(
                            uid.length > 7
                                ? "ID: ${uid.substring(0, 7)}..."
                                : "ID: $uid",
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey.shade700),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.copy, size: 12.sp, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
