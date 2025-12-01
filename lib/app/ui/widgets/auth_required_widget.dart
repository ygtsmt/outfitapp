import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ginly/app/ui/widgets/custom_gradient_button.dart';
import 'package:ginly/core/core.dart';
import 'package:ginly/generated/l10n.dart';

class AuthRequiredWidget extends StatelessWidget {
  const AuthRequiredWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: CustomGradientButton(
          title: AppLocalizations.of(context).loginTitle,
          onTap: () {
            context.router.push(const LoginScreenRoute());
          },
          isFilled: true,
        ),
      ),
    );
  }
}
