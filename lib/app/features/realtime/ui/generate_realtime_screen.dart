import 'package:auto_route/auto_route.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginfit/app/features/library/bloc/library_bloc.dart';
import 'package:ginfit/app/features/realtime/bloc/realtime_bloc.dart';
import 'package:ginfit/app/features/report/bloc/report_bloc.dart';
import 'package:ginfit/app/features/realtime/ui/realtime_history_listview_widget.dart';
import 'package:ginfit/app/features/realtime/ui/widgets/realtime_generated_image_widget.dart';
import 'package:ginfit/app/features/realtime/ui/widgets/realtime_input_section_widget.dart';
import 'package:ginfit/app/features/realtime/ui/widgets/realtime_placeholder_widget.dart';
import 'package:ginfit/app/features/library/ui/screens/library_screen.dart';
import 'package:ginfit/core/ui/widgets/report_dialog.dart';
import 'package:ginfit/core/constants/layout_constants.dart';
import 'package:ginfit/app/ui/widgets/total_credit_widget.dart';
import 'package:ginfit/core/core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginfit/core/utils.dart';
import 'package:ginfit/generated/l10n.dart';

class GenerateRealtimeScreen extends StatefulWidget {
  const GenerateRealtimeScreen({super.key});

  @override
  State<GenerateRealtimeScreen> createState() => _GenerateRealtimeScreenState();
}

class _GenerateRealtimeScreenState extends State<GenerateRealtimeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  TextEditingController textToImagePromptController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController reportController = TextEditingController();
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkKeyboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Sayfa tekrar açıldığında keyboard state'ini kontrol et
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkKeyboard();
      });
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Post frame callback kullanarak keyboard state'ini güvenli şekilde güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkKeyboard();
    });
  }

  void _checkKeyboard() {
    if (!mounted) return; // Widget dispose edilmişse kontrol etme

    try {
      final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
      final newValue = bottomInset > 0.0;

      if (newValue != _isKeyboardVisible) {
        if (mounted) {
          setState(() {
            _isKeyboardVisible = newValue;
          });
        }
      }
    } catch (e) {
      // Hata durumunda keyboard'ı kapalı olarak işaretle
      if (mounted && _isKeyboardVisible) {
        setState(() {
          _isKeyboardVisible = false;
        });
      }
    }
  }

  void _showReportDialog(
      BuildContext context, RealtimeState state, ProfileState profileState) {
    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        mediaUrl: state.realtimePhotoIsBase64 == true
            ? (state.realtimePhotoBase64 ?? '')
            : state.realtimePhotoUrl ?? '',
        reportType: 'realtimeImage',
        isBase64: false,
        onReportSubmitted: (report) {
          getIt<ReportBloc>().add(SubmitReportEvent(report: report));
        },
        reportController: reportController,
        prompt: textToImagePromptController.text,
      ),
    );
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
            return BlocListener<ReportBloc, ReportState>(
              listener: (context, reportState) {
                if (reportState.submitReportStatus == EventStatus.success) {
                  Utils.showToastMessage(
                    context: context,
                    content:
                        AppLocalizations.of(context).reportSentSuccessfully,
                  );
                } else if (reportState.submitReportStatus ==
                    EventStatus.failure) {
                  Utils.showToastMessage(
                    context: context,
                    content:
                        'Rapor gönderimi başarısız oldu! Lütfen daha sonra tekrar deneyin.',
                    color: Colors.red,
                  );
                }
              },
              child: Scaffold(
                appBar: _isKeyboardVisible == true ? null : appbar(context),
                body: SafeArea(
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 8.h),
                    child: Column(
                      spacing: 8.h,
                      children: [
                        if (!_isKeyboardVisible &&
                            state.realtimePhotoBase64LIST != null &&
                            state.realtimePhotoBase64LIST!.isNotEmpty)
                          SizedBox(
                            height: 32.h,
                            child: Row(
                              children: [
                                Expanded(
                                  child: RealtimeHistoryListviewWidget(),
                                ),
                                GestureDetector(
                                  onTap: () {
                                  /*   LibraryScreen.setInitialTabIndex(2);
                                    context.router.pushNamed(
                                        '/homeScreen/library/library-screen'); */
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    child: Icon(
                                      Icons.history,
                                      color: context.baseColor,
                                      size: 18.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Flexible(
                          flex: _isKeyboardVisible ? 2 : 5,
                          child: (state.realtimePhotoBase64 != null &&
                                  state.realtimePhotoBase64!.isNotEmpty &&
                                  state.realtimePhotoIsBase64 == true)
                              ? RealtimeGeneratedImageWidget(
                                  state: state,
                                  profileState: profileState,
                                  onReportPressed: () {
                                    _showReportDialog(
                                        context, state, profileState);
                                  },
                                  isKeyboardVisible: _isKeyboardVisible,
                                )
                              : Column(
                                  children: [
                                    LayoutConstants.centralEmptyHeight,
                                    Expanded(
                                        child:
                                            const RealtimePlaceholderWidget()),
                                  ],
                                ),
                        ),

                        // Input Section
                        RealtimeInputSectionWidget(
                          isPreview: false,
                          profileState: profileState,
                          textController: textToImagePromptController,
                        ),
                      ],
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

  AppBar appbar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      actionsPadding: EdgeInsets.only(right: 16.w),
      title: Text(
        AppLocalizations.of(context).realtimeAI,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      actions: [
        TotalCreditWidget(navigateAvailable: true),
      ],
    );
  }
}
