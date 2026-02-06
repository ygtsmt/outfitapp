import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/chat/ui/chat_screen.dart';
import 'package:comby/generated/l10n.dart';

class AIChatCard extends StatelessWidget {
  const AIChatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: 32.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).aiStyleConsultant,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Get instant fashion advice from Gemini AI',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
