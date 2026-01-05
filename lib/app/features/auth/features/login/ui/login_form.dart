import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:comby/app/bloc/app_bloc.dart';

import 'package:comby/app/features/auth/features/login/bloc/login_bloc.dart';

import 'package:comby/app/features/auth/ui/login_logo.dart';

import 'package:comby/app/ui/widgets/custom_gradient_button.dart';
import 'package:comby/app/ui/widgets/terms_and_policy_accept_widget.dart';
import 'package:comby/core/utils.dart';
import 'package:comby/core/core.dart';
import 'package:comby/core/constants/layout_constants.dart';
import 'package:comby/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_field_validator/form_field_validator.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Padding(
          padding:
              EdgeInsets.symmetric(horizontal: LayoutConstants.defaultSize),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Sağ üstte çarpı butonu

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Expanded(
                    child: Column(
                      children: [
                        LayoutConstants.midEmptyHeight,
                        const LoginLogo(haveText: true),
                      ],
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 8.h),
                          child: IconButton(
                            onPressed: () {
                              // Eğer giriş yapılmış hesap yoksa guest olarak giriş yap
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                getIt<LoginBloc>()
                                    .add(const LoginAsGuestEvent());
                              } else {
                                context.router.replace(const HomeScreenRoute());
                              }
                            },
                            icon: Icon(
                              Icons.close,
                              size: 24.sp,
                              color: context.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: context.baseColor,
                              shape: const CircleBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).loginTitle.capitalize(),
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(),
                    ),
                    LayoutConstants.midEmptyHeight,
                    Text(
                      AppLocalizations.of(context).loginDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                    ),
                    LayoutConstants.defaultEmptyHeight,
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      autofillHints: const <String>[AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).email,
                        prefixIcon: const Icon(
                          Icons.person_outline_outlined,
                        ),
                        labelStyle: const TextStyle(),
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
                              errorText: AppLocalizations.current.empty_error),
                          EmailValidator(
                              errorText: AppLocalizations.current.email_error),
                        ],
                      ),
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _passwordController,
                      autofillHints: const <String>[AutofillHints.password],
                      validator: MultiValidator(
                        [
                          RequiredValidator(
                            errorText: AppLocalizations.current.empty_error,
                          ),
                        ],
                      ),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).password,
                        prefixIcon: const Icon(
                          Icons.password_outlined,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: _obscureText
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
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
                      obscureText: _obscureText,
                      textInputAction: TextInputAction.done,
                      /*  validator: MultiValidator(
                        [
                          RequiredValidator(
                              errorText: AppLocalizations.current.empty_error),
                          PatternValidator(passwordRegex,
                              errorText:
                                  AppLocalizations.current.password_error),
                        ],
                      ), */
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final email = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController();
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  LayoutConstants.highRadius),
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  Icons.lock_reset,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 24.w,
                                ),
                                LayoutConstants.defaultEmptyWidth,
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .resetYourPassword,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).enterYourEmail,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        LayoutConstants.defaultRadius),
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)
                                          .enterYourEmail,
                                      border: InputBorder.none,
                                      contentPadding:
                                          LayoutConstants.defaultAllPadding,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => context.router.pop(),
                                child: Text(
                                  AppLocalizations.of(context).cancel,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  context.router.pop(controller.text);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        LayoutConstants.defaultRadius),
                                  ),
                                ),
                                child: Text(AppLocalizations.of(context).send),
                              ),
                            ],
                          );
                        },
                      );

                      if (email != null && email.isNotEmpty) {
                        getIt<LoginBloc>()
                            .add(ResetPasswordEvent(email: email));
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context).forgotPassword,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: context.baseColor,
                            decorationColor: context.baseColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationThickness: 2,
                          ),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  LayoutConstants.defaultEmptyHeight,
                  AnimatedScale(
                    scale: _scale,
                    duration: const Duration(milliseconds: 200),
                    child: const TermsAndPolicyAcceptWidget(),
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<AppBloc, AppState>(
                        builder: (context, state) {
                          return CustomGradientButton(
                            title: AppLocalizations.of(context)
                                .loginTitle
                                .toUpperCase(),
                            leading: const SizedBox(),
                            isFilled: true,
                            onTap: () async {
                              if (state.isCheckedTermsAndPolicy != true) {
                                Utils.showToastMessage(
                                  context: context,
                                  content: AppLocalizations.of(context)
                                      .terms_of_service_required,
                                );
                                _animateScale();
                              } else if (state.isCheckedTermsAndPolicy ==
                                      true &&
                                  _formKey.currentState!.validate()) {
                                getIt<LoginBloc>().add(
                                  LoginWithEmailEvent(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  ),
                                );
                              } else {
                                if (_formKey.currentState!.validate()) {
                                  getIt<LoginBloc>().add(
                                    LoginWithEmailEvent(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      )),
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
                  Column(
                    children: [
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
                                      getIt<LoginBloc>().add(
                                        const LoginWithGoogleEvent(),
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
                                      if (state.isCheckedTermsAndPolicy !=
                                          true) {
                                        Utils.showToastMessage(
                                          context: context,
                                          content: AppLocalizations.of(context)
                                              .terms_of_service_required,
                                        );
                                        _animateScale();
                                      } else {
                                        getIt<LoginBloc>().add(
                                          const LoginWithAppleEvent(),
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
                          // Guest Login Button - Yuvarlak buton olarak diğerleriyle aynı hizada
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
                                      getIt<LoginBloc>()
                                          .add(const LoginAsGuestEvent());
                                    }
                                  },
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 24.h,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            AppLocalizations.of(context).google,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.baseColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (Platform.isIOS || Platform.isMacOS)
                            Text(
                              AppLocalizations.of(context).apple,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: context.baseColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          Text(
                            AppLocalizations.of(context).guest,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.baseColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              TextButton(
                onPressed: () {
                  context.router.navigate(CreateAccountScreenRoute());
                },
                child: RichText(
                  text: TextSpan(
                    text: AppLocalizations.of(context).signup_button_text,
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: <TextSpan>[
                      TextSpan(
                        text: AppLocalizations.of(context).signup_button_link,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              LayoutConstants.highEmptyHeight,
            ],
          ),
        );
      },
    );
  }
}
