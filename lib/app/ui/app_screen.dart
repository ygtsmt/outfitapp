import "package:comby/app/bloc/app_bloc.dart";
import "package:comby/app/features/auth/features/create_account/bloc/create_account_bloc.dart";
import "package:comby/app/features/auth/features/login/bloc/login_bloc.dart";
import "package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart";
import "package:comby/app/features/auth/features/splash/bloc/splash_bloc.dart";
import "package:comby/app/features/chat/bloc/chat_bloc.dart";
import "package:comby/app/features/closet/bloc/closet_bloc.dart";
import "package:comby/app/features/payment/bloc/payment_bloc.dart";
import "package:comby/app/features/report/bloc/report_bloc.dart";
import "package:comby/core/color_schemes.g.dart";
import "package:comby/core/core.dart";
import "package:comby/generated/l10n.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:comby/core/theme/app_colors_extension.dart";

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final _appRouter = AppRouter();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      final String defaultRouteName =
          // ignore: deprecated_member_use
          WidgetsBinding.instance.window.defaultRouteName;
      if (defaultRouteName != "/") {
        SystemNavigator.routeInformationUpdated(replace: true);
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AppBloc>(
          create: (final context) => getIt<AppBloc>(),
        ),
        BlocProvider<SplashBloc>(
          create: (final context) => getIt<SplashBloc>(),
        ),
        BlocProvider<LoginBloc>(
          create: (final context) => getIt<LoginBloc>(),
        ),
        BlocProvider<CreateAccountBloc>(
          create: (final context) => getIt<CreateAccountBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (final context) => getIt<ProfileBloc>(),
        ),
        BlocProvider<ClosetBloc>(
          create: (final context) => getIt<ClosetBloc>(),
        ),
        BlocProvider<PaymentBloc>(
          create: (final context) => getIt<PaymentBloc>(),
        ),
        BlocProvider<ReportBloc>(
          create: (final context) => getIt<ReportBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (final context) => getIt<ChatBloc>(),
        ),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (final context, final state) {
          print('🔥 APP SCREEN BUILD - Locale: ${state.languageLocale}');
          print(
              '🔥 Current language: ${state.languageLocale?.languageCode ?? 'null'}');

          return BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              return MediaQuery(
                data: data.copyWith(
                  textScaler: const TextScaler.linear(1.0),
                  boldText: false,
                ),
                child: MaterialApp.router(
                  scaffoldMessengerKey: snackbarKey,
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: AppLocalizations.delegate.supportedLocales,
                  theme: ThemeData(
                    useMaterial3: true,
                    colorScheme: lightColorScheme,
                    fontFamily: 'Futura',
                    extensions: const [AppColorsExtension.light],
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    colorScheme: darkColorScheme,
                    fontFamily: 'Futura',
                    extensions: const [AppColorsExtension.dark],
                  ),
                  locale: state.languageLocale ?? const Locale('en'),
                  themeMode: state.themeMode,
                  routerDelegate: _appRouter.delegate(),
                  routeInformationParser: _appRouter.defaultRouteParser(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
