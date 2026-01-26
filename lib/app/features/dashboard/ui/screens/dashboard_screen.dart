import "package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import 'package:comby/app/features/closet/ui/widgets/wardrobe_analytics_widget.dart';
import "package:comby/app/features/dashboard/ui/widgets/weather_widget.dart";
import 'package:comby/app/features/fit_check/ui/widgets/fit_check_card.dart';
import "package:comby/core/extensions.dart";

import 'package:comby/app/features/dashboard/ui/widgets/ai_fashion_critique_widget.dart';

import 'dart:math';
import 'package:comby/generated/l10n.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                    _getGreeting(context, state.profileInfo?.displayName ?? ""),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: context.baseColor,
                    ),
                  );
                },
              ),
              Builder(
                builder: (context) {
                  final messages =
                      AppLocalizations.of(context).welcome_messages.split('|');

                  if (messages.isEmpty) return const SizedBox.shrink();

                  final randomMessage =
                      messages[Random().nextInt(messages.length)];

                  return Text(
                    randomMessage,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: context.baseColor.withOpacity(0.6),
                    ),
                  );
                },
              ),
            ],
          ),

          // Weather Widget
          const WeatherWidget(),

          // AI Fashion Critique Widget
          const AIFashionCritiqueWidget(),

          // Fit Check Card
          const FitCheckCard(),

          // Closet Analytics
          //  const WardrobeAnalyticsWidget(),
        ],
      ),
    );
  }

  String _getGreeting(BuildContext context, String username) {
    String name =
        username.split(" ").length > 1 ? username.split(" ")[0] : username;
    final noGuestName = name.toLowerCase() != 'guest' ? name : '';
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context);
    if (hour < 12) {
      return l10n.goodMorning(noGuestName);
    } else if (hour < 18) {
      return l10n.goodAfternoon(noGuestName);
    } else {
      return l10n.goodEvening(noGuestName);
    }
  }
}
