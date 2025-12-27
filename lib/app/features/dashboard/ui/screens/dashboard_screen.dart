import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:ginly/app/features/dashboard/ui/widgets/weather_widget.dart";
import 'package:ginly/app/features/fit_check/ui/widgets/fit_check_card.dart';
import "package:ginly/core/extensions.dart";

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: context.baseColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Bugün nasıl görünmek istersin?',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: context.baseColor.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 24.h),

              // Weather Widget
              const WeatherWidget(),

              SizedBox(height: 24.h),

              // Fit Check Card
              const FitCheckCard(),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Günaydın ☀️';
    } else if (hour < 18) {
      return 'İyi günler 👋';
    } else {
      return 'İyi akşamlar 🌙';
    }
  }
}
