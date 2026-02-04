import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon / Avatar

            SizedBox(height: 24.h),

            // Title
            Text(
              'Comby AI Agent Ready!',
              textAlign: TextAlign.center,
              style: GoogleFonts.balooBhai2(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              'I\'m Comby. What can I do for you?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32.h),

            // Capabilities List
            _buildCapabilityItem(
              context,
              icon: Icons.wb_sunny_rounded,
              title: 'Weather Check',
              description: 'I help you dress according to the weather.',
            ),
            _buildCapabilityItem(
              context,
              icon: Icons.checkroom_rounded,
              title: 'Wardrobe Analysis',
              description: 'I only recommend items you own.',
            ),
            _buildCapabilityItem(
              context,
              icon: Icons.remove_red_eye_rounded,
              title: 'Visual Analysis (Vision)',
              description:
                  'Upload a photo, I\'ll analyze your style and adapt it for you.',
            ),

            SizedBox(height: 24.h),

            // Tip Box
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.orange[700], size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Tip: You can use the buttons below to get started quickly.',
                      style:
                          TextStyle(fontSize: 12.sp, color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilityItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String description}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.sp,
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
