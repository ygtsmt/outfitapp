import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart';
import 'package:comby/app/ui/widgets/custom_gradient_button.dart';
import 'package:comby/core/core.dart';
import 'package:comby/generated/l10n.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  @override
  State<ChangePasswordBottomSheet> createState() =>
      ChangePasswordBottomSheetState();
}

class ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final repeatController = TextEditingController();

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    repeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Wrap(
            runSpacing: 16,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Text(
                AppLocalizations.of(context).change_password,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: currentController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).current_password),
                validator: (v) => v == null || v.isEmpty
                    ? AppLocalizations.of(context).required
                    : null,
              ),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).new_password),
                validator: (v) => v == null || v.length < 6
                    ? AppLocalizations.of(context).min_6_chars
                    : null,
              ),
              TextFormField(
                controller: repeatController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context).repeat_new_password),
                validator: (v) => v != newController.text
                    ? AppLocalizations.of(context).passwords_dont_match
                    : null,
              ),
              CustomGradientButton(
                title: AppLocalizations.of(context).change_password,
                leading: const SizedBox(),
                isFilled: true,
                onTap: () {
                  if (_formKey.currentState?.validate() == true) {
                    getIt<ProfileBloc>().add(
                      ChangePasswordEvent(
                        currentPassword: currentController.text,
                        newPassword: newController.text,
                      ),
                    );
                    context.router.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
