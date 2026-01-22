// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i8;
import 'package:comby/app/bloc/app_bloc.dart' as _i32;
import 'package:comby/app/data/app_usecase.dart' as _i24;
import 'package:comby/app/features/auth/features/create_account/bloc/create_account_bloc.dart'
    as _i34;
import 'package:comby/app/features/auth/features/create_account/data/create_account_usecase.dart'
    as _i26;
import 'package:comby/app/features/auth/features/login/bloc/login_bloc.dart'
    as _i28;
import 'package:comby/app/features/auth/features/login/data/login_usecase.dart'
    as _i14;
import 'package:comby/app/features/auth/features/profile/bloc/profile_bloc.dart'
    as _i35;
import 'package:comby/app/features/auth/features/profile/data/profile_usecase.dart'
    as _i30;
import 'package:comby/app/features/auth/features/profile/services/activity_service.dart'
    as _i3;
import 'package:comby/app/features/auth/features/profile/services/style_dna_service.dart'
    as _i21;
import 'package:comby/app/features/auth/features/splash/bloc/splash_bloc.dart'
    as _i19;
import 'package:comby/app/features/auth/features/splash/data/splash_usecase.dart'
    as _i20;
import 'package:comby/app/features/closet/bloc/closet_bloc.dart' as _i33;
import 'package:comby/app/features/closet/data/closet_usecase.dart' as _i25;
import 'package:comby/app/features/closet/services/closet_analysis_service.dart'
    as _i23;
import 'package:comby/app/features/fal_ai/data/fal_ai_usecase.dart' as _i27;
import 'package:comby/app/features/fit_check/services/fit_check_service.dart'
    as _i10;
import 'package:comby/app/features/payment/bloc/payment_bloc.dart' as _i29;
import 'package:comby/app/features/payment/data/payment_usecase.dart' as _i15;
import 'package:comby/app/features/report/bloc/report_bloc.dart' as _i31;
import 'package:comby/app/features/report/data/report_usecase.dart' as _i16;
import 'package:comby/core/data_sources/firebase_module_firestore.dart' as _i37;
import 'package:comby/core/data_sources/local_data_source/secure_data_storage.dart'
    as _i17;
import 'package:comby/core/injection/modules/dio_module.dart' as _i36;
import 'package:comby/core/injection/modules/secure_storage_module.dart'
    as _i38;
import 'package:comby/core/routes/app_router.dart' as _i4;
import 'package:comby/core/services/bottom_sheet_service.dart' as _i5;
import 'package:comby/core/services/language_service.dart' as _i13;
import 'package:comby/core/services/snackbar_service.dart' as _i18;
import 'package:comby/core/services/theme_service.dart' as _i22;
import 'package:dio/dio.dart' as _i6;
import 'package:firebase_auth/firebase_auth.dart' as _i7;
import 'package:firebase_storage/firebase_storage.dart' as _i9;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:google_sign_in/google_sign_in.dart' as _i12;
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
    gh.lazySingleton<_i12.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.factory<_i13.LanguageService>(() => _i13.LanguageService());
    gh.factory<_i14.LoginUseCase>(() => _i14.LoginUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i12.GoogleSignIn>(),
        ));
    gh.factory<_i15.PaymentUsecase>(() => _i15.PaymentUsecase(
          gh<_i7.FirebaseAuth>(),
          gh<_i9.FirebaseStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i16.ReportUsecase>(() => _i16.ReportUsecase(
          gh<_i7.FirebaseAuth>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.singleton<_i17.SecureDataStorage>(
        () => _i17.SecureDataStorage(gh<_i11.FlutterSecureStorage>()));
    gh.factory<_i18.SnackBarService>(() => _i18.SnackBarService());
    gh.singleton<_i19.SplashBloc>(() => _i19.SplashBloc());
    gh.factory<_i20.SplashUseCase>(() => const _i20.SplashUseCase());
    gh.singleton<_i21.StyleDNAService>(() => _i21.StyleDNAService());
    gh.factory<_i22.ThemeService>(() => _i22.ThemeService());
    gh.singleton<_i23.WardrobeAnalysisService>(
        () => _i23.WardrobeAnalysisService());
    gh.factory<_i24.AppUseCase>(() => _i24.AppUseCase(
          gh<_i17.SecureDataStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i25.ClosetUseCase>(() => _i25.ClosetUseCase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.factory<_i26.CreateAccountUseCase>(() => _i26.CreateAccountUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i12.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i27.FalAiUsecase>(() => _i27.FalAiUsecase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.singleton<_i28.LoginBloc>(() => _i28.LoginBloc(
          loginUseCase: gh<_i14.LoginUseCase>(),
          createAccountUseCase: gh<_i26.CreateAccountUseCase>(),
        ));
    gh.singleton<_i29.PaymentBloc>(
        () => _i29.PaymentBloc(generateUseCase: gh<_i15.PaymentUsecase>()));
    gh.factory<_i30.ProfileUseCase>(() => _i30.ProfileUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i12.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
          secureDataStorage: gh<_i17.SecureDataStorage>(),
        ));
    gh.singleton<_i31.ReportBloc>(
        () => _i31.ReportBloc(reportUsecase: gh<_i16.ReportUsecase>()));
    gh.singleton<_i32.AppBloc>(
        () => _i32.AppBloc(appUsecase: gh<_i24.AppUseCase>()));
    gh.singleton<_i33.ClosetBloc>(
        () => _i33.ClosetBloc(closetUseCase: gh<_i25.ClosetUseCase>()));
    gh.singleton<_i34.CreateAccountBloc>(() => _i34.CreateAccountBloc(
        createAccountUseCase: gh<_i26.CreateAccountUseCase>()));
    gh.singleton<_i35.ProfileBloc>(() => _i35.ProfileBloc(
          loginUseCase: gh<_i14.LoginUseCase>(),
          createAccountUseCase: gh<_i26.CreateAccountUseCase>(),
          profileUseCase: gh<_i30.ProfileUseCase>(),
        ));
    return this;
  }
}

class _$DioModule extends _i36.DioModule {}

class _$FirebaseModule extends _i14.FirebaseModule {}

class _$FirebaseModuleFirestore extends _i37.FirebaseModuleFirestore {}

class _$RegisterModule extends _i36.RegisterModule {}

class _$SecureStorageModule extends _i38.SecureStorageModule {}
