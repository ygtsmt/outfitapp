import "package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import 'package:comby/app/features/closet/ui/widgets/wardrobe_analytics_widget.dart';
import "package:comby/app/features/dashboard/ui/widgets/weather_widget.dart";
import 'package:comby/app/features/fit_check/ui/widgets/fit_check_card.dart';
import "package:comby/core/extensions.dart";

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            spacing: 8.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      return Text(
                        _getGreeting(state.profileInfo?.displayName ?? ""),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: context.baseColor,
                        ),
                      );
                    },
                  ),
                  Text(
                    'Bugün nasıl görünmek istersin?',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: context.baseColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              // Weather Widget
              const WeatherWidget(),

              // Fit Check Card
              // FitCheckWidget content
              const FitCheckCard(),

              // Closet Analytics
              const WardrobeAnalyticsWidget(),
            ],
          ),
        ));
  }

  String _getGreeting(String username) {
    String name =
        username.split(" ").length > 1 ? username.split(" ")[0] : username;
    final noGuestName = name.toLowerCase() != 'guest' ? name : '';
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Günaydın $noGuestName ☀️ ';
    } else if (hour < 18) {
      return 'İyi günler $noGuestName 👋 ';
    } else {
      return 'İyi akşamlar $noGuestName 🌙';
    }
  }
}
