import "package:auto_route/auto_route.dart";
import "package:comby/app/features/auth/features/create_account/bloc/create_account_bloc.dart";
import "package:comby/app/features/auth/features/create_account/ui/create_account_form.dart";
import "package:comby/app/ui/widgets/custom_progress_dialog.dart";
import "package:comby/core/utils.dart";
import "package:comby/core/core.dart";
import "package:comby/core/helpers/error_message_handle.dart";

import "package:flutter/material.dart";
import "package:flutter_adaptive_ui/flutter_adaptive_ui.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:comby/generated/l10n.dart";
import "package:comby/app/core/services/revenue_cat_service.dart";

class CreateAccountScreen extends StatelessWidget {
  final bool? isUpgrade;
  const CreateAccountScreen({super.key, this.isUpgrade = false});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocConsumer<CreateAccountBloc, CreateAccountState>(
        listener: (final context, final state) {
          var dialog = CustomProgressDialog(context);
          if (state.createAccountStatus == EventStatus.processing) {
            dialog.show();
          }
          if (state.createAccountStatus == EventStatus.success) {
            dialog.close();
            Utils.showToastMessage(
                context: context,
                content: AppLocalizations.of(context).successfully);

            // Account oluşturulduğunda RevenueCat'i Firebase ile sync et
            RevenueCatService.syncWithFirebase();

            context.router.navigate(const LoginScreenRoute());
          } else if (state.createAccountStatus == EventStatus.failure) {
            dialog.close();
            Utils.showToastMessage(
              context: context,
              content: ErrorMessageHandle.getFirebaseAuthErrorMessage(
                state.authError,
              ),
            );
          }
        },
        builder: (final context, final state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: AdaptiveBuilder(
                    layoutDelegate:
                        AdaptiveLayoutDelegateWithMinimallScreenType(
                      handset:
                          (final BuildContext context, final Screen screen) {
                        return CreateAccountForm(isUpgrade: isUpgrade);
                      },
                      tablet:
                          (final BuildContext context, final Screen screen) {
                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: CreateAccountForm(isUpgrade: isUpgrade),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                    defaultBuilder:
                        (final BuildContext context, final Screen screen) {
                      return CreateAccountForm(isUpgrade: isUpgrade);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
