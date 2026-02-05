// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i8;
import 'package:comby/app/bloc/app_bloc.dart' as _i39;
import 'package:comby/app/data/app_usecase.dart' as _i28;
import 'package:comby/app/features/auth/features/create_account/bloc/create_account_bloc.dart'
    as _i42;
import 'package:comby/app/features/auth/features/create_account/data/create_account_usecase.dart'
    as _i31;
import 'package:comby/app/features/auth/features/login/bloc/login_bloc.dart'
    as _i33;
import 'package:comby/app/features/auth/features/login/data/login_usecase.dart'
    as _i16;
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart'
    as _i44;
import 'package:comby/app/features/auth/features/profile/data/profile_usecase.dart'
    as _i36;
import 'package:comby/app/features/auth/features/profile/services/activity_service.dart'
    as _i3;
import 'package:comby/app/features/auth/features/profile/services/style_dna_service.dart'
    as _i23;
import 'package:comby/app/features/auth/features/splash/bloc/splash_bloc.dart'
    as _i21;
import 'package:comby/app/features/auth/features/splash/data/splash_usecase.dart'
    as _i22;
import 'package:comby/app/features/chat/bloc/chat_bloc.dart' as _i45;
import 'package:comby/app/features/chat/data/chat_repository.dart' as _i29;
import 'package:comby/app/features/chat/data/chat_usecase.dart' as _i40;
import 'package:comby/app/features/closet/bloc/closet_bloc.dart' as _i41;
import 'package:comby/app/features/closet/data/closet_usecase.dart' as _i30;
import 'package:comby/app/features/closet/services/closet_analysis_service.dart'
    as _i26;
import 'package:comby/app/features/fal_ai/data/fal_ai_usecase.dart' as _i32;
import 'package:comby/app/features/fit_check/services/fit_check_service.dart'
    as _i10;
import 'package:comby/app/features/live_stylist/cubit/live_stylist_cubit.dart'
    as _i43;
import 'package:comby/app/features/payment/bloc/payment_bloc.dart' as _i35;
import 'package:comby/app/features/payment/data/payment_usecase.dart' as _i17;
import 'package:comby/app/features/report/bloc/report_bloc.dart' as _i37;
import 'package:comby/app/features/report/data/report_usecase.dart' as _i18;
import 'package:comby/core/data_sources/firebase_module_firestore.dart' as _i47;
import 'package:comby/core/data_sources/local_data_source/secure_data_storage.dart'
    as _i19;
import 'package:comby/core/injection/modules/dio_module.dart' as _i46;
import 'package:comby/core/injection/modules/secure_storage_module.dart'
    as _i48;
import 'package:comby/core/routes/app_router.dart' as _i4;
import 'package:comby/core/services/agent_service.dart' as _i38;
import 'package:comby/core/services/bottom_sheet_service.dart' as _i5;
import 'package:comby/core/services/gemini_rest_service.dart' as _i12;
import 'package:comby/core/services/language_service.dart' as _i14;
import 'package:comby/core/services/live_agent_service.dart' as _i15;
import 'package:comby/core/services/notification_service.dart' as _i34;
import 'package:comby/core/services/snackbar_service.dart' as _i20;
import 'package:comby/core/services/theme_service.dart' as _i24;
import 'package:comby/core/services/user_preference_service.dart' as _i25;
import 'package:comby/core/services/weather_service.dart' as _i27;
import 'package:dio/dio.dart' as _i6;
import 'package:firebase_auth/firebase_auth.dart' as _i7;
import 'package:firebase_storage/firebase_storage.dart' as _i9;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i13;
import 'package:injectable/injectable.dart' as _i2;
import 'package:comby/core/services/location_service.dart' as _i49;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final dioModule = _$DioModule();
    final firebaseModule = _$FirebaseModule();
    final firebaseModuleFirestore = _$FirebaseModuleFirestore();
    final registerModule = _$RegisterModule();
    final secureStorageModule = _$SecureStorageModule();
    gh.singleton<_i3.ActivityService>(() => _i3.ActivityService());
    gh.factory<_i4.AppRouter>(() => _i4.AppRouter());
    gh.lazySingleton<_i5.BottomSheetService>(() => _i5.BottomSheetService());
    gh.singleton<_i6.Dio>(() => dioModule.dio());
    gh.lazySingleton<_i7.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i8.FirebaseFirestore>(
        () => firebaseModuleFirestore.firebaseAuth);
    gh.singleton<_i9.FirebaseStorage>(() => registerModule.firebaseStorage);
    gh.factory<_i10.FitCheckService>(() => _i10.FitCheckService(
          gh<_i7.FirebaseAuth>(),
          gh<_i8.FirebaseFirestore>(),
          gh<_i9.FirebaseStorage>(),
        ));
    gh.singleton<_i11.FlutterSecureStorage>(
        () => secureStorageModule.storage());
    gh.factory<_i12.GeminiRestService>(() => _i12.GeminiRestService());
    gh.lazySingleton<_i13.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.factory<_i14.LanguageService>(() => _i14.LanguageService());
    gh.lazySingleton<_i15.LiveAgentService>(() => _i15.LiveAgentService());
    gh.factory<_i16.LoginUseCase>(() => _i16.LoginUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i13.GoogleSignIn>(),
        ));
    gh.factory<_i17.PaymentUsecase>(() => _i17.PaymentUsecase(
          gh<_i7.FirebaseAuth>(),
          gh<_i9.FirebaseStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i18.ReportUsecase>(() => _i18.ReportUsecase(
          gh<_i7.FirebaseAuth>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.singleton<_i19.SecureDataStorage>(
        () => _i19.SecureDataStorage(gh<_i11.FlutterSecureStorage>()));
    gh.factory<_i20.SnackBarService>(() => _i20.SnackBarService());
    gh.singleton<_i21.SplashBloc>(() => _i21.SplashBloc());
    gh.factory<_i22.SplashUseCase>(() => const _i22.SplashUseCase());
    gh.singleton<_i23.StyleDNAService>(() => _i23.StyleDNAService());
    gh.factory<_i24.ThemeService>(() => _i24.ThemeService());
    gh.factory<_i25.UserPreferenceService>(() => _i25.UserPreferenceService());
    gh.factory<_i49.LocationService>(() => _i49.LocationService());
    gh.singleton<_i26.WardrobeAnalysisService>(
        () => _i26.WardrobeAnalysisService());
    gh.factory<_i27.WeatherService>(
        () => _i27.WeatherService(gh<_i8.FirebaseFirestore>()));
    gh.factory<_i28.AppUseCase>(() => _i28.AppUseCase(
          gh<_i19.SecureDataStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i29.ChatRepository>(() => _i29.ChatRepository(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
        ));
    gh.factory<_i30.ClosetUseCase>(() => _i30.ClosetUseCase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.factory<_i31.CreateAccountUseCase>(() => _i31.CreateAccountUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i13.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i32.FalAiUsecase>(() => _i32.FalAiUsecase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.singleton<_i33.LoginBloc>(() => _i33.LoginBloc(
          loginUseCase: gh<_i16.LoginUseCase>(),
          createAccountUseCase: gh<_i31.CreateAccountUseCase>(),
        ));
    gh.singleton<_i34.NotificationService>(
        () => _i34.NotificationService(gh<_i25.UserPreferenceService>()));
    gh.singleton<_i35.PaymentBloc>(
        () => _i35.PaymentBloc(generateUseCase: gh<_i17.PaymentUsecase>()));
    gh.factory<_i36.ProfileUseCase>(() => _i36.ProfileUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i13.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
          secureDataStorage: gh<_i19.SecureDataStorage>(),
        ));
    gh.singleton<_i37.ReportBloc>(
        () => _i37.ReportBloc(reportUsecase: gh<_i18.ReportUsecase>()));
    gh.factory<_i38.AgentService>(() => _i38.AgentService(
          weatherService: gh<_i27.WeatherService>(),
          closetUseCase: gh<_i30.ClosetUseCase>(),
          falAiUsecase: gh<_i32.FalAiUsecase>(),
          userPreferenceService: gh<_i25.UserPreferenceService>(),
          notificationService: gh<_i34.NotificationService>(),
          locationService: gh<_i49.LocationService>(),
        ));
    gh.singleton<_i39.AppBloc>(
        () => _i39.AppBloc(appUsecase: gh<_i28.AppUseCase>()));
    gh.factory<_i40.ChatUseCase>(() => _i40.ChatUseCase(
          gh<_i30.ClosetUseCase>(),
          gh<_i38.AgentService>(),
          gh<_i12.GeminiRestService>(),
        ));
    gh.singleton<_i41.ClosetBloc>(
        () => _i41.ClosetBloc(closetUseCase: gh<_i30.ClosetUseCase>()));
    gh.singleton<_i42.CreateAccountBloc>(() => _i42.CreateAccountBloc(
        createAccountUseCase: gh<_i31.CreateAccountUseCase>()));
    gh.factory<_i43.LiveStylistCubit>(() => _i43.LiveStylistCubit(
          gh<_i15.LiveAgentService>(),
          gh<_i30.ClosetUseCase>(),
          gh<_i36.ProfileUseCase>(),
          gh<_i7.FirebaseAuth>(),
        ));
    gh.singleton<_i44.ProfileBloc>(() => _i44.ProfileBloc(
          loginUseCase: gh<_i16.LoginUseCase>(),
          createAccountUseCase: gh<_i31.CreateAccountUseCase>(),
          profileUseCase: gh<_i36.ProfileUseCase>(),
        ));
    gh.factory<_i45.ChatBloc>(() => _i45.ChatBloc(
          gh<_i40.ChatUseCase>(),
          gh<_i29.ChatRepository>(),
          gh<_i7.FirebaseAuth>(),
        ));
    return this;
  }
}

class _$DioModule extends _i46.DioModule {}

class _$FirebaseModule extends _i16.FirebaseModule {}

class _$FirebaseModuleFirestore extends _i47.FirebaseModuleFirestore {}

class _$RegisterModule extends _i46.RegisterModule {}

class _$SecureStorageModule extends _i48.SecureStorageModule {}
