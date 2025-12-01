import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';

class TermsAgreementText extends StatelessWidget {
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const TermsAgreementText({
    super.key,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        style: Theme.of(context).textTheme.labelSmall?.copyWith(),
        children: [
          TextSpan(
              text: '${AppLocalizations.of(context).iHaveReadAndAgreedTo} '),
          TextSpan(
            text: AppLocalizations.of(context).termsOfService,
            style: TextStyle(
              color: context.baseColor,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTermsTap,
          ),
          TextSpan(text: ' ${AppLocalizations.of(context).and} '),
          TextSpan(
            text: AppLocalizations.of(context).privacyPolicy,
            style: TextStyle(
              color: context.baseColor,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
          ),
        ],
      ),
    );
  }
}