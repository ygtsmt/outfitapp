import "package:auto_route/auto_route.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:ginfit/app/bloc/app_bloc.dart";
import "package:ginfit/app/features/auth/features/create_account/bloc/create_account_bloc.dart";
import "package:ginfit/app/features/auth/ui/login_logo.dart";
import "package:ginfit/app/ui/widgets/custom_gradient_button.dart";
import "package:ginfit/app/ui/widgets/terms_and_policy_accept_widget.dart";
import "package:ginfit/core/core.dart";
import "package:ginfit/core/constants/layout_constants.dart";
import "package:ginfit/core/utils.dart";
import "package:ginfit/generated/l10n.dart";
import "package:flutter/material.dart";
import "package:form_field_validator/form_field_validator.dart";
import "dart:io";

class CreateAccountForm extends StatefulWidget {
  final bool? isUpgrade;
  const CreateAccountForm({super.key, this.isUpgrade = false});

  @override
  State<CreateAccountForm> createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _scale = 1.0;

  void _animateScale() {
    setState(() {
      _scale = 1.1;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _scale = 1.0;
      });
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: LayoutConstants.defaultSize),
      child: Column(
        children: <Widget>[
          LayoutConstants.centralEmptyHeight,
          //   const LoginLogo(haveText: true),
          LayoutConstants.midEmptyHeight,
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  widget.isUpgrade == true
                      ? AppLocalizations.of(context).upgradeYourAccount
                      : AppLocalizations.of(context).create_account,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(),
                ),
                LayoutConstants.midEmptyHeight,
                Text(
                  widget.isUpgrade == true
                      ? "Please enter your full name to create your account."
                      : AppLocalizations.of(context).create_account_form,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                  textAlign: TextAlign.center,
                ),
                LayoutConstants.highEmptyHeight,
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _fullNameController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).full_name,
                          prefixIcon: const Icon(
                            Icons.person_outline,
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              // Çizginin rengi
                              width: 1.0, // Çizginin kalınlığı
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              // Odaklanıldığında çizginin rengi
                              width: 1.5, // Odaklanıldığında çizginin kalınlığı
                            ),
                          ),
                        ),
                        validator: RequiredValidator(
                          errorText: AppLocalizations.of(context).promptEmpty,
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).email,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0, // Çizginin kalınlığı
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5, // Odaklanıldığında çizginin kalınlığı
                      ),
                    ),
                  ),
                  validator: MultiValidator(
                    [
                      RequiredValidator(
                        errorText: AppLocalizations.current.empty_error,
                      ),
                      EmailValidator(
                        errorText: AppLocalizations.current.email_error,
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).password,
                    prefixIcon: const Icon(
                      Icons.password_outlined,
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0, // Çizginin kalınlığı
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5, // Odaklanıldığında çizginin kalınlığı
                      ),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: _obscureText
                          ? const Icon(
                              Icons.visibility_off,
                            )
                          : const Icon(
                              Icons.visibility,
                            ),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: MultiValidator(
                    [
                      RequiredValidator(
                          errorText: AppLocalizations.current.empty_error),
                      MinLengthValidator(8,
                          errorText: AppLocalizations.current.password_error),
                      PatternValidator(passwordRegex,
                          errorText: AppLocalizations.current.password_error),
                    ],
                  ),
                ),
                TextFormField(
                  controller: _rePasswordController,
                  decoration: InputDecoration(
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.0, // Çizginin kalınlığı
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1.5, // Odaklanıldığında çizginin kalınlığı
                      ),
                    ),
                    labelText: AppLocalizations.of(context).confirm_password,
                    prefixIcon: const Icon(
                      Icons.password_outlined,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureTextConfirm = !_obscureTextConfirm;
                        });
                      },
                      icon: _obscureTextConfirm
                          ? const Icon(
                              Icons.visibility_off,
                            )
                          : const Icon(
                              Icons.visibility,
                            ),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  obscureText: _obscureTextConfirm,
                  validator: (final String? val) => MatchValidator(
                          errorText:
                              AppLocalizations.current.confirm_password_error)
                      .validateMatch(
                    _passwordController.text,
                    _rePasswordController.text,
                  ),
                ),
                LayoutConstants.defaultEmptyHeight,
                AnimatedScale(
                  scale: _scale,
                  duration: const Duration(milliseconds: 200),
                  child: TermsAndPolicyAcceptWidget(),
                ),
                LayoutConstants.defaultEmptyHeight,
                BlocBuilder<AppBloc, AppState>(
                  builder: (context, state) {
                    return CustomGradientButton(
                      title: AppLocalizations.of(context)
                          .create_account
                          .toUpperCase(),
                      leading: const SizedBox(),
                      isFilled: true,
                      onTap: () async {
                        if (state.isCheckedTermsAndPolicy == true) {
                          if (_formKey.currentState!.validate()) {
                            getIt<CreateAccountBloc>().add(
                              CreateAccountEvent(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  displayName: _fullNameController.text),
                            );
                          }
                        } else {
                          Utils.showToastMessage(
                            context: context,
                            content: AppLocalizations.of(context)
                                .terms_of_service_required,
                          );
                          _animateScale();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          LayoutConstants.defaultEmptyHeight,
          Row(
            spacing: 16.w,
            children: [
              const Flexible(child: Divider()),
              Text(AppLocalizations.of(context).orLoginWith),
              const Flexible(child: Divider())
            ],
          ),
          LayoutConstants.defaultEmptyHeight,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BlocBuilder<AppBloc, AppState>(
                builder: (context, state) {
                  return Container(
                    height: 50.h,
                    width: 50.h,
                    decoration: BoxDecoration(
                        color: context.baseColor,
                        borderRadius: BorderRadius.circular(100)),
                    padding: EdgeInsets.all(8.h),
                    child: InkWell(
                      onTap: () async {
                        if (state.isCheckedTermsAndPolicy != true) {
                          Utils.showToastMessage(
                            context: context,
                            content: AppLocalizations.of(context)
                                .terms_of_service_required,
                          );
                          _animateScale();
                        } else {
                          getIt<CreateAccountBloc>().add(
                            const CreateAccountWithGoogleEvent(),
                          );
                        }
                      },
                      child: Image.asset(
                        PngPaths.googleLogo,
                        height: 36.h,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              if (Platform.isIOS || Platform.isMacOS)
                BlocBuilder<AppBloc, AppState>(
                  builder: (context, state) {
                    return Container(
                      height: 50.h,
                      width: 50.h,
                      decoration: BoxDecoration(
                          color: context.baseColor,
                          borderRadius: BorderRadius.circular(100)),
                      padding: EdgeInsets.all(8.h),
                      child: InkWell(
                        onTap: () async {
                          if (state.isCheckedTermsAndPolicy != true) {
                            Utils.showToastMessage(
                              context: context,
                              content: AppLocalizations.of(context)
                                  .terms_of_service_required,
                            );
                            _animateScale();
                          } else {
                            getIt<CreateAccountBloc>().add(
                              const CreateAccountWithAppleEvent(),
                            );
                          }
                        },
                        child: Image.asset(
                          PngPaths.appleLogo,
                          height: 36.h,
                          color: Colors.white,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          LayoutConstants.midEmptyHeight,
        ],
      ),
    );
  }
}
