import 'dart:convert';
import 'dart:math';

import "package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import 'package:comby/app/features/closet/ui/widgets/wardrobe_analytics_widget.dart';
import "package:comby/app/features/dashboard/ui/widgets/weather_widget.dart";
import 'package:comby/app/features/fit_check/ui/widgets/fit_check_card.dart';
import "package:comby/core/extensions.dart";

import 'package:comby/app/features/dashboard/ui/widgets/ai_fashion_critique_widget.dart';

import 'package:comby/generated/l10n.dart';
import 'package:comby/app/features/dashboard/ui/widgets/daily_outfit_card.dart';
import 'package:comby/app/features/chat/ui/chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:comby/core/injection/injection.dart';
import 'package:comby/core/services/agent_service.dart';
import 'package:comby/core/services/gemini_rest_service.dart';
import 'package:comby/app/features/dashboard/ui/widgets/live_stylist_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 🕵️‍♂️ MARATHON AGENT: Görev Kontrolü
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveMission();
    });
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
                child: Text('Tamam, Teşekkürler'),
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
                child: Text('Detayları Konuş'),
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

          // Weather Widget
          const WeatherWidget(),

          // Live Stylist Entry
          const LiveStylistCard(),

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
