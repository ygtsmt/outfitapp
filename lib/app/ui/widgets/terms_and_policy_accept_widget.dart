import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:comby/app/bloc/app_bloc.dart';
import 'package:comby/app/data/models/multi_lang_file.dart';
import 'package:comby/app/features/auth/features/login/ui/widgets/terms_agreement_text.dart';
import 'package:comby/app/features/payment/ui/payment_screen.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';

class TermsAndPolicyAcceptWidget extends StatelessWidget {
  const TermsAndPolicyAcceptWidget({
    super.key,
  });

  /// Dil'e göre document URL'ini çözümle
  String resolveDocumentByLocale(
    String currentLocale,
    String enUrl,
    String trUrl,
    String deUrl,
    String frUrl,
  ) {
    switch (currentLocale) {
      case 'tr':
        return trUrl;
      case 'de':
        return deUrl;
      case 'fr':
        return frUrl;
      case 'en':
      default:
        return enUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Row(
          children: [
            Checkbox(
              value: state.isCheckedTermsAndPolicy ?? true,
              onChanged: (value) {
                getIt<AppBloc>()
                    .add(CheckedTermsAndPolicyEvent(value ?? false));
              },
            ),
            Expanded(
                child: TermsAgreementText(
              onTermsTap: () {
                context.router.push(
                  DocumentsWebViewScreenRoute(
                    pdfUrl: 'https://www.comby.ai/#/terms',
                    title: AppLocalizations.of(context).termsOfService,
                  ),
                );
              },
              onPrivacyTap: () {
                context.router.push(
                  DocumentsWebViewScreenRoute(
                    pdfUrl: 'https://www.comby.ai/#/privacy',
                    title: AppLocalizations.of(context).privacyPolicy,
                  ),
                );
              },
            ))
          ],
        );
      },
    );
  }
}
