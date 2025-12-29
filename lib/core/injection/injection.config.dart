// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i8;
import 'package:dio/dio.dart' as _i6;
import 'package:firebase_auth/firebase_auth.dart' as _i7;
import 'package:firebase_storage/firebase_storage.dart' as _i9;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i11;
import 'package:get_it/get_it.dart' as _i1;
import 'package:ginfit/app/bloc/app_bloc.dart' as _i30;
import 'package:ginfit/app/data/app_usecase.dart' as _i22;
import 'package:ginfit/app/features/auth/features/create_account/bloc/create_account_bloc.dart'
    as _i32;
import 'package:ginfit/app/features/auth/features/create_account/data/create_account_usecase.dart'
    as _i24;
import 'package:ginfit/app/features/auth/features/login/bloc/login_bloc.dart'
    as _i26;
import 'package:ginfit/app/features/auth/features/login/data/login_usecase.dart'
    as _i14;
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart'
    as _i33;
import 'package:ginfit/app/features/auth/features/profile/data/profile_usecase.dart'
    as _i28;
import 'package:ginfit/app/features/auth/features/splash/bloc/splash_bloc.dart'
    as _i19;
import 'package:ginfit/app/features/auth/features/splash/data/splash_usecase.dart'
    as _i20;
import 'package:ginfit/app/features/closet/bloc/closet_bloc.dart' as _i31;
import 'package:ginfit/app/features/closet/data/closet_usecase.dart' as _i23;
import 'package:ginfit/app/features/closet/services/closet_analysis_service.dart'
    as _i5;
import 'package:ginfit/app/features/fal_ai/data/fal_ai_usecase.dart' as _i25;
import 'package:ginfit/app/features/fit_check/services/fit_check_service.dart'
    as _i10;
import 'package:ginfit/app/features/payment/bloc/payment_bloc.dart' as _i27;
import 'package:ginfit/app/features/payment/data/payment_usecase.dart' as _i15;
import 'package:ginfit/app/features/report/bloc/report_bloc.dart' as _i29;
import 'package:ginfit/app/features/report/data/report_usecase.dart' as _i16;
import 'package:ginfit/core/data_sources/firebase_module_firestore.dart'
    as _i35;
import 'package:ginfit/core/data_sources/local_data_source/secure_data_storage.dart'
    as _i17;
import 'package:ginfit/core/injection/modules/dio_module.dart' as _i34;
import 'package:ginfit/core/injection/modules/secure_storage_module.dart'
    as _i36;
import 'package:ginfit/core/routes/app_router.dart' as _i3;
import 'package:ginfit/core/services/bottom_sheet_service.dart' as _i4;
import 'package:ginfit/core/services/language_service.dart' as _i13;
import 'package:ginfit/core/services/snackbar_service.dart' as _i18;
import 'package:ginfit/core/services/theme_service.dart' as _i21;
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
    gh.factory<_i3.AppRouter>(() => _i3.AppRouter());
    gh.lazySingleton<_i4.BottomSheetService>(() => _i4.BottomSheetService());
    gh.singleton<_i5.ClosetAnalysisService>(() => _i5.ClosetAnalysisService());
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
    gh.factory<_i21.ThemeService>(() => _i21.ThemeService());
    gh.factory<_i22.AppUseCase>(() => _i22.AppUseCase(
          gh<_i17.SecureDataStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i23.ClosetUseCase>(() => _i23.ClosetUseCase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.factory<_i24.CreateAccountUseCase>(() => _i24.CreateAccountUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i12.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i25.FalAiUsecase>(() => _i25.FalAiUsecase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.singleton<_i26.LoginBloc>(() => _i26.LoginBloc(
          loginUseCase: gh<_i14.LoginUseCase>(),
          createAccountUseCase: gh<_i24.CreateAccountUseCase>(),
        ));
    gh.singleton<_i27.PaymentBloc>(
        () => _i27.PaymentBloc(generateUseCase: gh<_i15.PaymentUsecase>()));
    gh.factory<_i28.ProfileUseCase>(() => _i28.ProfileUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i12.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
          secureDataStorage: gh<_i17.SecureDataStorage>(),
        ));
    gh.singleton<_i29.ReportBloc>(
        () => _i29.ReportBloc(reportUsecase: gh<_i16.ReportUsecase>()));
    gh.singleton<_i30.AppBloc>(
        () => _i30.AppBloc(appUsecase: gh<_i22.AppUseCase>()));
    gh.singleton<_i31.ClosetBloc>(
        () => _i31.ClosetBloc(closetUseCase: gh<_i23.ClosetUseCase>()));
    gh.singleton<_i32.CreateAccountBloc>(() => _i32.CreateAccountBloc(
        createAccountUseCase: gh<_i24.CreateAccountUseCase>()));
    gh.singleton<_i33.ProfileBloc>(() => _i33.ProfileBloc(
          loginUseCase: gh<_i14.LoginUseCase>(),
          createAccountUseCase: gh<_i24.CreateAccountUseCase>(),
          profileUseCase: gh<_i28.ProfileUseCase>(),
        ));
    return this;
  }
}

class _$DioModule extends _i34.DioModule {}

class _$FirebaseModule extends _i14.FirebaseModule {}

class _$FirebaseModuleFirestore extends _i35.FirebaseModuleFirestore {}

class _$RegisterModule extends _i34.RegisterModule {}

class _$SecureStorageModule extends _i36.SecureStorageModule {}
