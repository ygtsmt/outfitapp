import "package:auto_route/auto_route.dart";
import "package:ginfit/app/features/auth/features/login/bloc/login_bloc.dart";
import "package:ginfit/app/features/auth/features/login/ui/login_form.dart";
import "package:ginfit/core/utils.dart";
import "package:ginfit/core/core.dart";
import "package:ginfit/core/helpers/error_message_handle.dart";

import "package:ginfit/generated/l10n.dart";
import "package:flutter/material.dart";
import "package:flutter_adaptive_ui/flutter_adaptive_ui.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:ginfit/app/core/services/revenue_cat_service.dart";

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (final context, final state) {
          // var dialog = CustomProgressDialog(context);
          if (state.status == EventStatus.processing) {
            //  dialog.show();
          }
          if (state.status == EventStatus.success) {
            //  dialog.close();
            Utils.showToastMessage(
                context: context, content: AppLocalizations.current.success);

            // Login başarılı olduğunda RevenueCat'i Firebase ile sync et
            RevenueCatService.syncWithFirebase();

            context.router.replace(const HomeScreenRoute());
          }
          if (state.status == EventStatus.failure) {
            //   dialog.close();
            Utils.showToastMessage(
              context: context,
              content: ErrorMessageHandle.getFirebaseAuthErrorMessage(
                  state.authError),
            );
          }
          if (state.resetPasswordStatus == EventStatus.success) {
            Utils.showToastMessage(
              context: context,
              content: AppLocalizations.of(context).passwordResetLinkSent,
            );
          }
        },
        builder: (final context, final state) {
          return state.status != EventStatus.idle
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: AdaptiveBuilder(
                        layoutDelegate:
                            AdaptiveLayoutDelegateWithMinimallScreenType(
                          handset: (final BuildContext context,
                              final Screen screen) {
                            return const LoginForm();
                          },
                          tablet: (final BuildContext context,
                              final Screen screen) {
                            return const Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 32),
                                    child: LoginForm(),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                        defaultBuilder:
                            (final BuildContext context, final Screen screen) {
                          return const LoginForm();
                        },
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
