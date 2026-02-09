// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i8;
import 'package:comby/app/bloc/app_bloc.dart' as _i43;
import 'package:comby/app/data/app_usecase.dart' as _i31;
import 'package:comby/app/features/auth/features/create_account/bloc/create_account_bloc.dart'
    as _i46;
import 'package:comby/app/features/auth/features/create_account/data/create_account_usecase.dart'
    as _i34;
import 'package:comby/app/features/auth/features/login/bloc/login_bloc.dart'
    as _i36;
import 'package:comby/app/features/auth/features/login/data/login_usecase.dart'
    as _i18;
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart'
    as _i48;
import 'package:comby/app/features/auth/features/profile/data/profile_usecase.dart'
    as _i39;
import 'package:comby/app/features/auth/features/profile/services/activity_service.dart'
    as _i3;
import 'package:comby/app/features/auth/features/profile/services/style_dna_service.dart'
    as _i26;
import 'package:comby/app/features/auth/features/splash/bloc/splash_bloc.dart'
    as _i24;
import 'package:comby/app/features/auth/features/splash/data/splash_usecase.dart'
    as _i25;
import 'package:comby/app/features/chat/bloc/chat_bloc.dart' as _i49;
import 'package:comby/app/features/chat/data/chat_repository.dart' as _i32;
import 'package:comby/app/features/chat/data/chat_usecase.dart' as _i44;
import 'package:comby/app/features/closet/bloc/closet_bloc.dart' as _i45;
import 'package:comby/app/features/closet/data/closet_usecase.dart' as _i33;
import 'package:comby/app/features/closet/services/closet_analysis_service.dart'
    as _i29;
import 'package:comby/app/features/fal_ai/data/fal_ai_usecase.dart' as _i35;
import 'package:comby/app/features/fit_check/services/fit_check_service.dart'
    as _i10;
import 'package:comby/app/features/live_stylist/cubit/live_stylist_cubit.dart'
    as _i47;
import 'package:comby/app/features/payment/bloc/payment_bloc.dart' as _i38;
import 'package:comby/app/features/payment/data/payment_usecase.dart' as _i20;
import 'package:comby/app/features/report/bloc/report_bloc.dart' as _i40;
import 'package:comby/app/features/report/data/report_usecase.dart' as _i21;
import 'package:comby/core/data_sources/firebase_module_firestore.dart' as _i51;
import 'package:comby/core/data_sources/local_data_source/secure_data_storage.dart'
    as _i22;
import 'package:comby/core/injection/modules/dio_module.dart' as _i50;
import 'package:comby/core/injection/modules/secure_storage_module.dart'
    as _i52;
import 'package:comby/core/routes/app_router.dart' as _i4;
import 'package:comby/core/services/agent_service.dart' as _i42;
import 'package:comby/core/services/bottom_sheet_service.dart' as _i5;
import 'package:comby/core/services/gemini_rest_service.dart' as _i12;
import 'package:comby/core/services/gemini_wrapper_service.dart' as _i13;
import 'package:comby/core/services/language_service.dart' as _i15;
import 'package:comby/core/services/live_agent_service.dart' as _i16;
import 'package:comby/core/services/location_service.dart' as _i17;
import 'package:comby/core/services/mock_data_service.dart' as _i19;
import 'package:comby/core/services/notification_service.dart' as _i37;
import 'package:comby/core/services/snackbar_service.dart' as _i23;
import 'package:comby/core/services/theme_service.dart' as _i27;
import 'package:comby/core/services/user_preference_service.dart' as _i28;
import 'package:comby/core/services/weather_service.dart' as _i30;
import 'package:comby/core/services/wrapped_data_service.dart' as _i41;
import 'package:dio/dio.dart' as _i6;
import 'package:firebase_auth/firebase_auth.dart' as _i7;
import 'package:firebase_storage/firebase_storage.dart' as _i9;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i14;
import 'package:injectable/injectable.dart' as _i2;

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
    gh.factory<_i13.GeminiWrapperService>(() => _i13.GeminiWrapperService());
    gh.lazySingleton<_i14.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.factory<_i15.LanguageService>(() => _i15.LanguageService());
    gh.lazySingleton<_i16.LiveAgentService>(() => _i16.LiveAgentService());
    gh.factory<_i17.LocationService>(() => _i17.LocationService());
    gh.factory<_i18.LoginUseCase>(() => _i18.LoginUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i14.GoogleSignIn>(),
        ));
    gh.lazySingleton<_i19.MockDataService>(() => _i19.MockDataService(
          gh<_i8.FirebaseFirestore>(),
          gh<_i7.FirebaseAuth>(),
        ));
    gh.factory<_i20.PaymentUsecase>(() => _i20.PaymentUsecase(
          gh<_i7.FirebaseAuth>(),
          gh<_i9.FirebaseStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i21.ReportUsecase>(() => _i21.ReportUsecase(
          gh<_i7.FirebaseAuth>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.singleton<_i22.SecureDataStorage>(
        () => _i22.SecureDataStorage(gh<_i11.FlutterSecureStorage>()));
    gh.factory<_i23.SnackBarService>(() => _i23.SnackBarService());
    gh.singleton<_i24.SplashBloc>(() => _i24.SplashBloc());
    gh.factory<_i25.SplashUseCase>(() => const _i25.SplashUseCase());
    gh.singleton<_i26.StyleDNAService>(() => _i26.StyleDNAService());
    gh.factory<_i27.ThemeService>(() => _i27.ThemeService());
    gh.factory<_i28.UserPreferenceService>(() => _i28.UserPreferenceService());
    gh.singleton<_i29.WardrobeAnalysisService>(
        () => _i29.WardrobeAnalysisService());
    gh.factory<_i30.WeatherService>(
        () => _i30.WeatherService(gh<_i8.FirebaseFirestore>()));
    gh.factory<_i31.AppUseCase>(() => _i31.AppUseCase(
          gh<_i22.SecureDataStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i32.ChatRepository>(() => _i32.ChatRepository(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
        ));
    gh.factory<_i33.ClosetUseCase>(() => _i33.ClosetUseCase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.factory<_i34.CreateAccountUseCase>(() => _i34.CreateAccountUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i14.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i35.FalAiUsecase>(() => _i35.FalAiUsecase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.singleton<_i36.LoginBloc>(() => _i36.LoginBloc(
          loginUseCase: gh<_i18.LoginUseCase>(),
          createAccountUseCase: gh<_i34.CreateAccountUseCase>(),
        ));
    gh.singleton<_i37.NotificationService>(
        () => _i37.NotificationService(gh<_i28.UserPreferenceService>()));
    gh.singleton<_i38.PaymentBloc>(
        () => _i38.PaymentBloc(generateUseCase: gh<_i20.PaymentUsecase>()));
    gh.factory<_i39.ProfileUseCase>(() => _i39.ProfileUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i14.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
          secureDataStorage: gh<_i22.SecureDataStorage>(),
        ));
    gh.singleton<_i40.ReportBloc>(
        () => _i40.ReportBloc(reportUsecase: gh<_i21.ReportUsecase>()));
    gh.factory<_i41.WrappedDataService>(() => _i41.WrappedDataService(
          gh<_i33.ClosetUseCase>(),
          gh<_i32.ChatRepository>(),
          gh<_i3.ActivityService>(),
          gh<_i29.WardrobeAnalysisService>(),
        ));
    gh.factory<_i42.AgentService>(() => _i42.AgentService(
          weatherService: gh<_i30.WeatherService>(),
          closetUseCase: gh<_i33.ClosetUseCase>(),
          falAiUsecase: gh<_i35.FalAiUsecase>(),
          userPreferenceService: gh<_i28.UserPreferenceService>(),
          notificationService: gh<_i37.NotificationService>(),
          locationService: gh<_i17.LocationService>(),
        ));
    gh.singleton<_i43.AppBloc>(
        () => _i43.AppBloc(appUsecase: gh<_i31.AppUseCase>()));
    gh.factory<_i44.ChatUseCase>(() => _i44.ChatUseCase(
          gh<_i33.ClosetUseCase>(),
          gh<_i42.AgentService>(),
          gh<_i12.GeminiRestService>(),
        ));
    gh.singleton<_i45.ClosetBloc>(
        () => _i45.ClosetBloc(closetUseCase: gh<_i33.ClosetUseCase>()));
    gh.singleton<_i46.CreateAccountBloc>(() => _i46.CreateAccountBloc(
        createAccountUseCase: gh<_i34.CreateAccountUseCase>()));
    gh.factory<_i47.LiveStylistCubit>(() => _i47.LiveStylistCubit(
          gh<_i16.LiveAgentService>(),
          gh<_i33.ClosetUseCase>(),
          gh<_i39.ProfileUseCase>(),
          gh<_i7.FirebaseAuth>(),
        ));
    gh.singleton<_i48.ProfileBloc>(() => _i48.ProfileBloc(
          loginUseCase: gh<_i18.LoginUseCase>(),
          createAccountUseCase: gh<_i34.CreateAccountUseCase>(),
          profileUseCase: gh<_i39.ProfileUseCase>(),
        ));
    gh.factory<_i49.ChatBloc>(() => _i49.ChatBloc(
          gh<_i44.ChatUseCase>(),
          gh<_i32.ChatRepository>(),
          gh<_i7.FirebaseAuth>(),
        ));
    return this;
  }
}

class _$DioModule extends _i50.DioModule {}

class _$FirebaseModule extends _i18.FirebaseModule {}

class _$FirebaseModuleFirestore extends _i51.FirebaseModuleFirestore {}

class _$RegisterModule extends _i50.RegisterModule {}

class _$SecureStorageModule extends _i52.SecureStorageModule {}
