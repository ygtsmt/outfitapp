import 'dart:convert';
import 'dart:math';

import "package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:comby/app/features/dashboard/ui/widgets/compact_weather_widget.dart";
import "package:comby/app/features/dashboard/ui/widgets/ai_chat_card.dart";
import 'package:comby/app/features/fit_check/ui/widgets/fit_check_card.dart';
import "package:comby/core/extensions.dart";

import 'package:comby/app/features/dashboard/ui/widgets/ai_fashion_critique_widget.dart';

import 'package:comby/generated/l10n.dart';
import 'package:comby/app/features/chat/ui/chat_screen.dart';
import 'package:comby/core/injection/injection.dart';
import 'package:comby/core/services/agent_service.dart';
import 'package:comby/core/services/gemini_rest_service.dart';
import 'package:comby/app/features/dashboard/ui/widgets/live_stylist_card.dart';

import 'package:permission_handler/permission_handler.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveMission();
      _checkLocationPermission();
    });
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
  }

  Future<void> _checkActiveMission() async {
    try {
      final agentService = getIt<AgentService>();
      final geminiService = getIt<GeminiRestService>();

      final result = await agentService.monitorActiveMission(geminiService);

      if (result['status'] == 'active' && mounted) {
        final analysis = result['raw_analysis'];
        // Basit JSON parsing (Eğer result string ise)
        Map<String, dynamic> alertData = {};
        try {
          alertData = jsonDecode(analysis);
        } catch (e) {
          alertData = {
            'title': 'Travel Alert',
            'message': analysis,
            'alert_type': 'info'
          };
        }

        // 🔔 ALERT DIALOG
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  alertData['alert_type'] == 'danger'
                      ? Icons.warning_amber_rounded
                      : Icons.info_outline,
                  color: alertData['alert_type'] == 'danger'
                      ? Colors.red
                      : Colors.blue,
                ),
                SizedBox(width: 8),
                Expanded(
                    child: Text(alertData['title'] ?? 'Comby Advisor',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            content: Text(alertData['message'] ?? '',
                style: TextStyle(fontSize: 16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK, Thanks'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Chate git
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(),
                      ));
                },
                child: Text('Discuss Details'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Mission Check Fail: $e');
    }
  }

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

          // Compact Weather Widget (collapsed ~120px, expanded ~280px)
          const CompactWeatherWidget(),

          // Live Stylist Entry
          const LiveStylistCard(),
          // AI Chat Card
          const AIChatCard(),
          // Proactive Agent Card (Moved to Weather Widget)
          // DailyOutfitCard(
          //   onTap: () {},
          // ),

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
