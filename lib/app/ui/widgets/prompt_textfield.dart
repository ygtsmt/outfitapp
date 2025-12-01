// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ginly/app/features/auth/features/login/bloc/login_bloc.dart';
import 'package:ginly/app/ui/widgets/auth_required_widget.dart';

import 'package:ginly/app/ui/widgets/random_widget.dart';
import 'package:ginly/app/bloc/app_bloc.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';

class PromptTextField extends StatefulWidget {
  const PromptTextField({
    super.key,
    required this.textToImagePromptController,
    this.onChanged,
    required this.showRequiredCredit,
    required this.isPreview,
  });

  final TextEditingController textToImagePromptController;
  final void Function(String)? onChanged;
  final bool showRequiredCredit;
  final bool isPreview;

  @override
  State<PromptTextField> createState() => _PromptTextFieldState();
}

class _PromptTextFieldState extends State<PromptTextField> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return auth.currentUser?.uid == null
        ? AuthRequiredWidget()
        : BlocBuilder<AppBloc, AppState>(
            builder: (context, appState) {
              final theme = Theme.of(context);
              final requirements = appState.generateCreditRequirements;

              // Realtime image için gerekli kredi (default: 1)
              final requiredCredits =
                  requirements?.realtimeImageRequiredCredits ?? 1;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(
                  horizontal: 8.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: context.baseColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: context.baseColor,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  enabled: widget.isPreview == false,
                  onTap: widget.isPreview == true
                      ? () {
                          context.router
                              .push(const GenerateRealtimeScreenRoute());
                        }
                      : null,
                  textAlignVertical: TextAlignVertical.center,
                  textInputAction: TextInputAction.done,
                  onChanged: widget.onChanged ?? null,
                  controller: widget.textToImagePromptController,
                  textCapitalization: TextCapitalization.none,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                        AppLocalizations.of(context).describeWhatYouWantToSee,
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: context.labelColor,
                    ),
                    suffixIcon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: widget.showRequiredCredit
                          ? Container(
                              key: const ValueKey('coin'),
                              margin: EdgeInsets.only(right: 4.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    PngPaths.coin,
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    requiredCredits.toString(),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.black,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              key: const ValueKey('random'),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: RandomWidget(
                                textToImagePromptController:
                                    widget.textToImagePromptController,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
