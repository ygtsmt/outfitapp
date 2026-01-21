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
import 'package:comby/app/ui/widgets/personal_info_card_widget.dart';
import 'package:comby/app/ui/widgets/profile_security_card_widget.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        getIt<ProfileBloc>().add(FetchProfileInfoEvent(currentUser.uid));
      }
    });
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
                  ),
                  SizedBox(height: 8.h),

                  // 2. Style DNA (Radar Chart + Colors)
                  const StyleDNAWidget(),
                  SizedBox(height: 8.h),

                  // 3. Wardrobe Analytics (Value, Sustainability, Categories)
                  const WardrobeAnalyticsWidget(),
                  SizedBox(height: 8.h),

                  // 4. Activity Heatmap
                  const ActivityHeatmapWidget(),
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
