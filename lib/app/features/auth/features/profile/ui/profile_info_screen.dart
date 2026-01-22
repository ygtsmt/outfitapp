import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:comby/app/features/auth/features/profile/ui/widgets/profile_header_widget.dart';
import 'package:comby/app/features/auth/features/profile/ui/widgets/style_dna_widget.dart';
import 'package:comby/app/features/auth/features/profile/ui/widgets/activity_heatmap_widget.dart';
import 'package:comby/app/features/auth/features/profile/ui/widgets/settings_button.dart';
import 'package:comby/app/features/closet/ui/widgets/wardrobe_analytics_widget.dart';
import 'package:comby/app/features/auth/features/profile/services/style_dna_service.dart';
import 'package:comby/app/ui/widgets/personal_info_card_widget.dart';
import 'package:comby/app/ui/widgets/profile_security_card_widget.dart';
import 'package:comby/app/features/auth/features/profile/services/activity_service.dart';
import 'package:comby/app/ui/widgets/custom_gradient_button.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/utils.dart';
import 'package:comby/core/helpers/error_message_handle.dart';
import 'package:comby/generated/l10n.dart';
import 'package:get_it/get_it.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Style DNA Data
  Map<String, int> _styleScores = {
    'Casual': 0,
    'Classic': 0,
    'Sporty': 0,
    'Vintage': 0,
    'Minimal': 0,
  };
  String _styleAnalysis = "Analiz ediliyor...";
  String _styleTitle = "Yükleniyor...";
  bool _isStyleLoading = true;

  // Activity Data
  int _streak = 0;
  int _outfitCount = 0;
  int _fitCheckCount = 0;
  Map<DateTime, int> _heatmapData = {};
  bool _isActivityLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        getIt<ProfileBloc>().add(FetchProfileInfoEvent(currentUser.uid));
        _loadStyleDNA();
        _loadActivityStats();
      }
    });
  }

  Future<void> _loadStyleDNA() async {
    try {
      final result = await getIt<StyleDNAService>().analyzeStyle();
      if (mounted) {
        setState(() {
          _styleScores = result['scores'] as Map<String, int>;
          _styleAnalysis = result['analysis'] as String;
          _styleTitle = result['title'] as String;
          _isStyleLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _styleAnalysis = "Analiz yüklenemedi.";
          _styleTitle = "Stil Kaşifi";
          _isStyleLoading = false;
        });
      }
    }
  }

  Future<void> _loadActivityStats() async {
    final activityService = GetIt.I<ActivityService>();
    try {
      final streak = await activityService.getCurrentStreak();
      final stats = await activityService.getUserStats();
      final heatmap = await activityService.getHeatmapData();

      if (mounted) {
        setState(() {
          _streak = streak;
          _outfitCount = stats['outfit'] ?? 0;
          _fitCheckCount = stats['fit_check'] ?? 0;
          _heatmapData = heatmap;
          _isActivityLoading = false;
        });
      }
    } catch (e) {
      print("Error loading activity stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state.logoutStatus == EventStatus.success ||
                state.deleteAccountStatus == EventStatus.success) {
              context.router.replaceAll([const LoginScreenRoute()]);
            }
          },
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[50]!, Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Column(
                children: [
                  // 1. Header with Level & Titles
                  ProfileHeaderWidget(
                    photoUrl: profileState.profileInfo?.photoURL,
                    displayName: profileState.profileInfo?.displayName ??
                        AppLocalizations.of(context).user,
                    uid: profileState.profileInfo?.uid ??
                        FirebaseAuth.instance.currentUser?.uid ??
                        "",
                    styleTitle: _styleTitle,
                    level: 1,
                  ),
                  SizedBox(height: 8.h),

                  // 2. Style DNA (Radar Chart + Colors)
                  StyleDNAWidget(
                    styleScores: _styleScores,
                    analysis: _styleAnalysis,
                    isLoading: _isStyleLoading,
                  ),
                  SizedBox(height: 8.h),

                  // 3. Wardrobe Analytics (Value, Sustainability, Categories)
                  const WardrobeAnalyticsWidget(),
                  SizedBox(height: 8.h),

                  // 4. Activity Heatmap
                  ActivityHeatmapWidget(
                    streak: _streak,
                    outfitCount: _outfitCount,
                    fitCheckCount: _fitCheckCount,
                    heatmapData: _heatmapData,
                    isLoading: _isActivityLoading,
                  ),
                  SizedBox(height: 8.h),

                  // 5. Settings Button (To open Settings Screen)
                  SettingsButton(
                    onTap: () {
                      context.router.push(const SettingsScreenRoute());
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
