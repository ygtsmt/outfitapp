import 'dart:async';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/data/models/features_doc_model.dart';
import 'package:ginly/app/features/template_generate/bloc/template_generate_bloc.dart';
import 'package:ginly/app/ui/widgets/custom_generate_button.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/core/routes/app_router.dart';
import 'package:ginly/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GenerateVideoButtonWidget extends StatefulWidget {
  final VideoTemplate videoTemplate;
  final TemplateGenerateState state;
  final bool isGenerationStarted;
  final VoidCallback onGeneratePressed;
  final bool isDifferentPhoto;
  final File? imageFile1;
  final File? imageFile2;
  final File? imageFile3;

  const GenerateVideoButtonWidget({
    super.key,
    required this.videoTemplate,
    required this.state,
    required this.isGenerationStarted,
    required this.onGeneratePressed,
    required this.isDifferentPhoto,
    required this.imageFile1,
    required this.imageFile2,
    required this.imageFile3,
  });

  @override
  State<GenerateVideoButtonWidget> createState() =>
      _GenerateVideoButtonWidgetState();
}

class _GenerateVideoButtonWidgetState extends State<GenerateVideoButtonWidget> {
  bool _isButtonPressed = false;

  bool _hasRequiredPhotos() {
    if (widget.isDifferentPhoto) {
      // For different photos mode, both imageFile1 and imageFile2 are required
      return widget.imageFile1 != null && widget.imageFile2 != null;
    } else {
      // For single photo mode, imageFile3 is required
      return widget.imageFile3 != null;
    }
  }

  String _getMissingPhotoMessage() {
    if (widget.isDifferentPhoto) {
      if (widget.imageFile1 == null && widget.imageFile2 == null) {
        return '${AppLocalizations.of(context).upload_photos} - ${AppLocalizations.of(context).firstPerson} & ${AppLocalizations.of(context).secondPerson}';
      } else if (widget.imageFile1 == null) {
        return '${AppLocalizations.of(context).upload_photo} - ${AppLocalizations.of(context).firstPerson}';
      } else if (widget.imageFile2 == null) {
        return '${AppLocalizations.of(context).upload_photo} - ${AppLocalizations.of(context).secondPerson}';
      }
    } else {
      if (widget.imageFile3 == null) {
        return AppLocalizations.of(context).upload_photo;
      }
    }
    return '';
  }

  void _showPhotoRequiredSnackBar() {
    final missingMessage = _getMissingPhotoMessage();
    if (missingMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(missingMessage),
              ),
            ],
          ),
          backgroundColor: context.baseColor,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = widget.state.uploadStatus == EventStatus.processing ||
        widget.state.generateStatus == EventStatus.processing ||
        widget.isGenerationStarted ||
        _isButtonPressed;

    final hasRequiredPhotos = _hasRequiredPhotos();

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
        final requiredCredits = creditRequirements?.videoRequiredCredits ?? 3;

        final hasEnoughCredits = totalCredit >= requiredCredits;

        // Get hasReceivedReviewCredit from ProfileBloc
        final profileBloc = context.read<ProfileBloc>();
        final hasReceivedReviewCredit =
            profileBloc.state.profileInfo?.hasReceivedReviewCredit ?? false;

        // Button is disabled if: processing, not enough credits, or no photos uploaded
        final isButtonDisabled =
            isProcessing || !hasEnoughCredits || !hasRequiredPhotos;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.h),
          child: CustomGenerateButton(
            title: isProcessing
                ? AppLocalizations.of(context).processing_request
                : !hasRequiredPhotos
                    ? AppLocalizations.of(context).uploadPhoto
                    : AppLocalizations.of(context).generate,
            generateType: GenerateType.videoTemplate,
            onTap: () {
              if (!hasEnoughCredits) {
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
              } else {
                if (isButtonDisabled) {
                  // Show warning snackbar when trying to tap disabled button
                  if (!hasRequiredPhotos) {
                    _showPhotoRequiredSnackBar();
                  }
                } else {
                  setState(() {
                    _isButtonPressed = true;
                  });
                  widget.onGeneratePressed();

                  // 3 saniye sonra butonu tekrar aktif et
                  Timer(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _isButtonPressed = false;
                      });
                    }
                  });
                }
              }
            },
            leading: isProcessing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(context.white),
                    ),
                  )
                : Image.asset(
                    PngPaths.generateFilled,
                    color: context.white,
                    height: 24,
                  ),
            isFilled: hasEnoughCredits,
          ),
        );
      },
    );
  }
}
