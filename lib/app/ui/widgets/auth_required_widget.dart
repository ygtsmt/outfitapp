import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ginfit/app/ui/widgets/custom_gradient_button.dart';
import 'package:ginfit/core/core.dart';
import 'package:ginfit/generated/l10n.dart';

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
