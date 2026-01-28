// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i8;
import 'package:comby/app/bloc/app_bloc.dart' as _i35;
import 'package:comby/app/data/app_usecase.dart' as _i26;
import 'package:comby/app/features/auth/features/create_account/bloc/create_account_bloc.dart'
    as _i38;
import 'package:comby/app/features/auth/features/create_account/data/create_account_usecase.dart'
    as _i28;
import 'package:comby/app/features/auth/features/login/bloc/login_bloc.dart'
    as _i30;
import 'package:comby/app/features/auth/features/login/data/login_usecase.dart'
    as _i15;
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart'
    as _i39;
import 'package:comby/app/features/auth/features/profile/data/profile_usecase.dart'
    as _i32;
import 'package:comby/app/features/auth/features/profile/services/activity_service.dart'
    as _i3;
import 'package:comby/app/features/auth/features/profile/services/style_dna_service.dart'
    as _i22;
import 'package:comby/app/features/auth/features/splash/bloc/splash_bloc.dart'
    as _i20;
import 'package:comby/app/features/auth/features/splash/data/splash_usecase.dart'
    as _i21;
import 'package:comby/app/features/chat/bloc/chat_bloc.dart' as _i40;
import 'package:comby/app/features/chat/data/chat_usecase.dart' as _i36;
import 'package:comby/app/features/closet/bloc/closet_bloc.dart' as _i37;
import 'package:comby/app/features/closet/data/closet_usecase.dart' as _i27;
import 'package:comby/app/features/closet/services/closet_analysis_service.dart'
    as _i24;
import 'package:comby/app/features/fal_ai/data/fal_ai_usecase.dart' as _i29;
import 'package:comby/app/features/fit_check/services/fit_check_service.dart'
    as _i10;
import 'package:comby/app/features/payment/bloc/payment_bloc.dart' as _i31;
import 'package:comby/app/features/payment/data/payment_usecase.dart' as _i16;
import 'package:comby/app/features/report/bloc/report_bloc.dart' as _i33;
import 'package:comby/app/features/report/data/report_usecase.dart' as _i17;
import 'package:comby/core/data_sources/firebase_module_firestore.dart' as _i42;
import 'package:comby/core/data_sources/local_data_source/secure_data_storage.dart'
    as _i18;
import 'package:comby/core/injection/modules/dio_module.dart' as _i41;
import 'package:comby/core/injection/modules/secure_storage_module.dart'
    as _i43;
import 'package:comby/core/routes/app_router.dart' as _i4;
import 'package:comby/core/services/agent_service.dart' as _i34;
import 'package:comby/core/services/bottom_sheet_service.dart' as _i5;
import 'package:comby/core/services/gemini_rest_service.dart' as _i12;
import 'package:comby/core/services/language_service.dart' as _i14;
import 'package:comby/core/services/snackbar_service.dart' as _i19;
import 'package:comby/core/services/theme_service.dart' as _i23;
import 'package:comby/core/services/weather_service.dart' as _i25;
import 'package:dio/dio.dart' as _i6;
import 'package:firebase_auth/firebase_auth.dart' as _i7;
import 'package:firebase_storage/firebase_storage.dart' as _i9;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i13;
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
    gh.lazySingleton<_i13.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.factory<_i14.LanguageService>(() => _i14.LanguageService());
    gh.factory<_i15.LoginUseCase>(() => _i15.LoginUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i13.GoogleSignIn>(),
        ));
    gh.factory<_i16.PaymentUsecase>(() => _i16.PaymentUsecase(
          gh<_i7.FirebaseAuth>(),
          gh<_i9.FirebaseStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i17.ReportUsecase>(() => _i17.ReportUsecase(
          gh<_i7.FirebaseAuth>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.singleton<_i18.SecureDataStorage>(
        () => _i18.SecureDataStorage(gh<_i11.FlutterSecureStorage>()));
    gh.factory<_i19.SnackBarService>(() => _i19.SnackBarService());
    gh.singleton<_i20.SplashBloc>(() => _i20.SplashBloc());
    gh.factory<_i21.SplashUseCase>(() => const _i21.SplashUseCase());
    gh.singleton<_i22.StyleDNAService>(() => _i22.StyleDNAService());
    gh.factory<_i23.ThemeService>(() => _i23.ThemeService());
    gh.singleton<_i24.WardrobeAnalysisService>(
        () => _i24.WardrobeAnalysisService());
    gh.factory<_i25.WeatherService>(
        () => _i25.WeatherService(gh<_i8.FirebaseFirestore>()));
    gh.factory<_i26.AppUseCase>(() => _i26.AppUseCase(
          gh<_i18.SecureDataStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i27.ClosetUseCase>(() => _i27.ClosetUseCase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.factory<_i28.CreateAccountUseCase>(() => _i28.CreateAccountUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i13.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i29.FalAiUsecase>(() => _i29.FalAiUsecase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.singleton<_i30.LoginBloc>(() => _i30.LoginBloc(
          loginUseCase: gh<_i15.LoginUseCase>(),
          createAccountUseCase: gh<_i28.CreateAccountUseCase>(),
        ));
    gh.singleton<_i31.PaymentBloc>(
        () => _i31.PaymentBloc(generateUseCase: gh<_i16.PaymentUsecase>()));
    gh.factory<_i32.ProfileUseCase>(() => _i32.ProfileUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i13.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
          secureDataStorage: gh<_i18.SecureDataStorage>(),
        ));
    gh.singleton<_i33.ReportBloc>(
        () => _i33.ReportBloc(reportUsecase: gh<_i17.ReportUsecase>()));
    gh.factory<_i34.AgentService>(() => _i34.AgentService(
          weatherService: gh<_i25.WeatherService>(),
          closetUseCase: gh<_i27.ClosetUseCase>(),
          falAiUsecase: gh<_i29.FalAiUsecase>(),
        ));
    gh.singleton<_i35.AppBloc>(
        () => _i35.AppBloc(appUsecase: gh<_i26.AppUseCase>()));
    gh.factory<_i36.ChatUseCase>(() => _i36.ChatUseCase(
          gh<_i27.ClosetUseCase>(),
          gh<_i34.AgentService>(),
          gh<_i12.GeminiRestService>(),
        ));
    gh.singleton<_i37.ClosetBloc>(
        () => _i37.ClosetBloc(closetUseCase: gh<_i27.ClosetUseCase>()));
    gh.singleton<_i38.CreateAccountBloc>(() => _i38.CreateAccountBloc(
        createAccountUseCase: gh<_i28.CreateAccountUseCase>()));
    gh.singleton<_i39.ProfileBloc>(() => _i39.ProfileBloc(
          loginUseCase: gh<_i15.LoginUseCase>(),
          createAccountUseCase: gh<_i28.CreateAccountUseCase>(),
          profileUseCase: gh<_i32.ProfileUseCase>(),
        ));
    gh.factory<_i40.ChatBloc>(() => _i40.ChatBloc(gh<_i36.ChatUseCase>()));
    return this;
  }
}

class _$DioModule extends _i41.DioModule {}

class _$FirebaseModule extends _i15.FirebaseModule {}

class _$FirebaseModuleFirestore extends _i42.FirebaseModuleFirestore {}

class _$RegisterModule extends _i41.RegisterModule {}

class _$SecureStorageModule extends _i43.SecureStorageModule {}
