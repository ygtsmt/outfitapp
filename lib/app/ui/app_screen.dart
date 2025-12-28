import "package:ginfit/app/bloc/app_bloc.dart";
import "package:ginfit/app/features/auth/features/create_account/bloc/create_account_bloc.dart";
import "package:ginfit/app/features/auth/features/login/bloc/login_bloc.dart";
import "package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart";
import "package:ginfit/app/features/auth/features/splash/bloc/splash_bloc.dart";
import "package:ginfit/app/features/library/bloc/library_bloc.dart";
import "package:ginfit/app/features/closet/bloc/closet_bloc.dart";
import "package:ginfit/app/features/payment/bloc/payment_bloc.dart";
import "package:ginfit/app/features/realtime/bloc/realtime_bloc.dart";
import "package:ginfit/app/features/report/bloc/report_bloc.dart";
import "package:ginfit/app/features/template_generate/bloc/template_generate_bloc.dart";
import "package:ginfit/app/features/text_to_image/bloc/text_to_image_bloc.dart";
import "package:ginfit/app/features/video_generate/bloc/video_generate_bloc.dart";
import "package:ginfit/core/color_schemes.g.dart";
import "package:ginfit/core/core.dart";
import "package:ginfit/generated/l10n.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";

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

    // Kredi requirements'ı çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AppBloc>().add(const GetGenerateCreditRequirementsEvent());
    });
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
        BlocProvider<RealtimeBloc>(
          create: (final context) => getIt<RealtimeBloc>(),
        ),
        BlocProvider<TextToImageBloc>(
          create: (final context) => getIt<TextToImageBloc>(),
        ),
        BlocProvider<VideoGenerateBloc>(
          create: (final context) => getIt<VideoGenerateBloc>(),
        ),
        BlocProvider<LibraryBloc>(
          create: (final context) => getIt<LibraryBloc>(),
        ),
        BlocProvider<ClosetBloc>(
          create: (final context) => getIt<ClosetBloc>(),
        ),
        BlocProvider<PaymentBloc>(
          create: (final context) => getIt<PaymentBloc>(),
        ),
        BlocProvider<TemplateGenerateBloc>(
          create: (final context) => getIt<TemplateGenerateBloc>(),
        ),
        BlocProvider<ReportBloc>(
          create: (final context) => getIt<ReportBloc>(),
        ),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (final context, final state) {
          print('🔥 APP SCREEN BUILD - Locale: ${state.languageLocale}');
          print(
              '🔥 Current language: ${state.languageLocale?.languageCode ?? 'null'}');
          // Kredi requirements yüklenmeden app'i gösterme
          if (state.generateCreditRequirements == null) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 8,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

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
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    colorScheme: darkColorScheme,
                    fontFamily: 'Futura',
                  ),
                  locale: state.languageLocale ?? const Locale('en'),
                  themeMode: ThemeMode.light,
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
