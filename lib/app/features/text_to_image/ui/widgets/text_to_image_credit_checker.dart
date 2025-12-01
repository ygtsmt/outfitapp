import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/app/features/text_to_image/bloc/text_to_image_bloc.dart';
import 'package:ginly/app/ui/widgets/custom_generate_button.dart';
import 'package:ginly/app/ui/widgets/prompt_textfield.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/core/constants/layout_constants.dart';
import 'package:ginly/core/utils.dart';
import 'package:ginly/generated/l10n.dart';

class TextToImageCreditChecker extends StatelessWidget {
  final TextToImageState state;
  final TextEditingController promptController;
  final VoidCallback onGenerate;

  const TextToImageCreditChecker({
    super.key,
    required this.state,
    required this.promptController,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(
              includeMetadataChanges:
                  false), // Sadece gerçek data değişikliklerini dinle
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(AppLocalizations.of(context).errorLoadingCredits);
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final totalCredit = userData?['profile_info']?['totalCredit'] ??
            userData?['totalCredit'] ??
            userData?['profile_info']?['credits'] ??
            userData?['credits'] ??
            0;

        // Get credit requirements from AppBloc
        final appBloc = getIt<AppBloc>();
        final creditRequirements = appBloc.state.generateCreditRequirements;
        final requiredCredits = creditRequirements?.imageRequiredCredits ?? 2;

        final hasEnoughCredits = totalCredit >= requiredCredits;

        return Column(
          children: [
            LayoutConstants.centralEmptyHeight,
            PromptTextField(
              isPreview: false,
              textToImagePromptController: promptController,
              showRequiredCredit: false,
            ),
            CustomGenerateButton(
              title: state.textToImageStatus == EventStatus.processing
                  ? AppLocalizations.of(context).processing_request
                  : AppLocalizations.of(context).generate,
              generateType: GenerateType.image,
              onTap: state.textToImageStatus == EventStatus.processing
                  ? null
                  : () => _handleGenerate(
                      context, hasEnoughCredits, requiredCredits, totalCredit),
              leading: state.textToImageStatus == EventStatus.processing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(context.white),
                      ),
                    )
                  : Image.asset(
                      PngPaths.generateFilled,
                      color: context.white,
                      height: 24,
                    ),
              isFilled: hasEnoughCredits &&
                  state.textToImageStatus != EventStatus.processing,
            ),
          ],
        );
      },
    );
  }

  void _handleGenerate(BuildContext context, bool hasEnoughCredits,
      int requiredCredits, int totalCredit) async {
    final promptText = promptController.text.trim();

    if (promptText.isEmpty) {
      Utils.showToastMessage(
        context: context,
        content: AppLocalizations.of(context).promptEmpty,
      );
      return;
    }

    // Check for banned words first
    final bannedWordsResult = BannedWordsService.checkPrompt(promptText);
    if (bannedWordsResult.hasBannedWord) {
      BannedWordsDialog.show(context, bannedWordsResult.bannedWord!);
      return;
    }

    if (!hasEnoughCredits) {
      Utils.showToastMessage(
        context: context,
        content: '❌ ${AppLocalizations.of(context).insufficientCredits}',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    // Only proceed if user has enough credits
    if (hasEnoughCredits) {
      // Clear any previous filter error message
      getIt<TextToImageBloc>().add(
        GenerateImageForTextToImageFlux(
          prompt: promptText,
          size: Size(
            MediaQuery.of(context).size.width *
                MediaQuery.of(context).devicePixelRatio,
            MediaQuery.of(context).size.height *
                MediaQuery.of(context).devicePixelRatio,
          ),
        ),
      );
    }
  }
}
