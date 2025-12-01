import 'package:auto_route/auto_route.dart';
import 'package:ginly/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginly/app/features/realtime/bloc/realtime_bloc.dart';
import 'package:ginly/app/features/realtime/ui/realtime_history_listview_widget.dart';
import 'package:ginly/app/features/realtime/ui/widgets/realtime_generated_image_widget.dart';
import 'package:ginly/app/features/realtime/ui/widgets/realtime_header_widget.dart';
import 'package:ginly/app/features/realtime/ui/widgets/realtime_input_section_widget.dart';
import 'package:ginly/app/features/realtime/ui/widgets/realtime_placeholder_widget.dart';
import 'package:ginly/core/ui/widgets/report_dialog.dart';
import 'package:ginly/core/constants/layout_constants.dart';
import 'package:ginly/core/core.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RealtimeScreen extends StatefulWidget {
  const RealtimeScreen({super.key});

  @override
  State<RealtimeScreen> createState() => _RealtimeScreenState();
}

class _RealtimeScreenState extends State<RealtimeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  TextEditingController textToImagePromptController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController reportController = TextEditingController();
  bool _isKeyboardVisible = false;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    initAnimations();
    _checkKeyboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _checkKeyboard();
  }

  void _checkKeyboard() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RealtimeBloc, RealtimeState>(
      listener: (context, state) {
        if (state.status == EventStatus.success) {
          getIt<ProfileBloc>().add(
            FetchProfileInfoEvent(auth.currentUser?.uid ?? ''),
          );
        }
      },
      builder: (realtimeContext, state) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (builderContext, profileState) {
            return SafeArea(
              child: GestureDetector(
                onTap: () {
                  context.router.push(const GenerateRealtimeScreenRoute());
                },
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: LayoutConstants.defaultAllPadding,
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RealtimeHeaderWidget(),
                                ),
                                LayoutConstants.centralEmptyHeight,
                                const Expanded(
                                  child: RealtimePlaceholderWidget(),
                                ),
                              ],
                            ),
                          ),

                          // Input Section
                          RealtimeInputSectionWidget(
                            isPreview: true,
                            profileState: profileState,
                            textController: textToImagePromptController,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void initAnimations() {
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _scaleController.forward();
  }
}
