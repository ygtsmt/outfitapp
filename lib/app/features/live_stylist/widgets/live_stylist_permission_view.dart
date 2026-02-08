import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/live_stylist/cubit/live_stylist_cubit.dart';

class LiveStylistPermissionView extends StatelessWidget {
  const LiveStylistPermissionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LiveStylistCubit, LiveStylistState>(
        builder: (context, state) {
          final isCameraGranted = state.isCameraPermissionGranted;
          final isMicGranted = state.isMicPermissionGranted;
          final allGranted = isCameraGranted && isMicGranted;

          return Stack(
            children: [
              // 🌈 Background Gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F2027),
                      Color(0xFF203A43),
                      Color(0xFF2C5364),
                    ],
                  ),
                ),
              ),

              // 🪟 Center Card
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: EdgeInsets.all(28.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✨ Icon
                            Icon(
                              Icons.auto_awesome,
                              size: 48.sp,
                              color: Colors.white,
                            ),
                            SizedBox(height: 20.h),

                            // 🧠 Title
                            Text(
                              "Almost Ready",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10.h),

                            // 📄 Subtitle
                            Text(
                              "We just need these permissions to start your live styling session.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 32.h),

                            // 🎥 Camera Permission
                            _permissionTile(
                              icon: Icons.camera_alt_rounded,
                              title: "Camera",
                              subtitle: "So we can see your outfit",
                              granted: isCameraGranted,
                            ),
                            SizedBox(height: 16.h),

                            // 🎙️ Mic Permission
                            _permissionTile(
                              icon: Icons.mic_rounded,
                              title: "Microphone",
                              subtitle: "So we can talk in real-time",
                              granted: isMicGranted,
                            ),

                            SizedBox(height: 32.h),

                            // 🚀 Action Button
                            SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: allGranted
                                      ? () => Navigator.of(context).pop()
                                      : () => context
                                          .read<LiveStylistCubit>()
                                          .requestPermissions(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: allGranted
                                        ? Colors.greenAccent
                                        : Colors.white,
                                    foregroundColor: Colors.black,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    allGranted
                                        ? "Continue"
                                        : "Grant Permissions",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 🔙 Back Button
              Positioned(
                top: 50.h,
                left: 20.w,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🧩 Permission Card
  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool granted,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: granted
            ? Colors.green.withOpacity(0.18)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: granted
              ? Colors.greenAccent.withOpacity(0.6)
              : Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 26.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13.sp,
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
