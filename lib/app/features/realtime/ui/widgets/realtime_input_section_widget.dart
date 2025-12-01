import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginly/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:ginly/app/features/realtime/bloc/realtime_bloc.dart';
import 'package:ginly/app/ui/widgets/prompt_textfield.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/core/constants/layout_constants.dart';
import 'package:ginly/core/core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ginly/core/routes/app_router.dart';

class RealtimeInputSectionWidget extends StatefulWidget {
  const RealtimeInputSectionWidget({
    super.key,
    required this.profileState,
    required this.textController,
    required this.isPreview,
  });

  final ProfileState profileState;
  final TextEditingController textController;
  final bool isPreview;
  @override
  State<RealtimeInputSectionWidget> createState() =>
      _RealtimeInputSectionWidgetState();
}

class _RealtimeInputSectionWidgetState
    extends State<RealtimeInputSectionWidget> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _checkCreditsAndGenerate(String prompt) {
    // Real-time kredi kontrolü için StreamBuilder kullan
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final userData = doc.data();
        final totalCredit = userData?['profile_info']?['totalCredit'] ??
            userData?['totalCredit'] ??
            userData?['profile_info']?['credits'] ??
            userData?['credits'] ??
            0;

        // Get credit requirements from AppBloc
        final appBloc = getIt<AppBloc>();
        final creditRequirements = appBloc.state.generateCreditRequirements;
        final requiredCredits =
            creditRequirements?.realtimeImageRequiredCredits ?? 1;

        if (totalCredit >= requiredCredits) {
          // Yeterli kredi varsa işlemi yap
          getIt<RealtimeBloc>().add(
            GenerateImageForRealtimeFlux(
              prompt: prompt,
              context: context,
            ),
          );
        } else {
          // Get hasReceivedReviewCredit from ProfileBloc
          final profileBloc = context.read<ProfileBloc>();
          final hasReceivedReviewCredit =
              profileBloc.state.profileInfo?.hasReceivedReviewCredit ?? false;

          // Platform kontrolü - Android ve iOS için farklı davranış (Play Store politikası)
          if (Platform.isAndroid) {
            // Android'de review teşviki yok, direkt ödeme ekranına veya reklam ekranına yönlendir
            if (hasReceivedReviewCredit) {
              context.router.push(PaymentsScreenRoute());
            } else {
              context.router.push(FreeCreditScreenRoute()); // Sadece reklam seçeneği için
            }
          } else {
            // iOS'ta review credit kontrolü yap
            if (hasReceivedReviewCredit) {
              context.router.push(PaymentsScreenRoute());
            } else {
              context.router.push(FreeCreditScreenRoute());
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(LayoutConstants.highRadius),
      ),
      child: Column(
        children: [
          // Input Field
          PromptTextField(
            isPreview: widget.isPreview,
            textToImagePromptController: widget.textController,
            onChanged: (onChangedText) async {
              _debounce?.cancel();

              _debounce = Timer(const Duration(milliseconds: 300), () {
                if (onChangedText.isNotEmpty) {
                  // Real-time kredi kontrolü için StreamBuilder kullan
                  _checkCreditsAndGenerate(onChangedText);
                }
              });
            },
            showRequiredCredit: true,
          ),
        ],
      ),
    );
  }
}
