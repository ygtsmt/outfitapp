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
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i12;
import 'package:get_it/get_it.dart' as _i1;
import 'package:ginfit/app/bloc/app_bloc.dart' as _i41;
import 'package:ginfit/app/core/services/first_install_bonus_service.dart'
    as _i10;
import 'package:ginfit/app/data/app_usecase.dart' as _i28;
import 'package:ginfit/app/features/auth/features/create_account/bloc/create_account_bloc.dart'
    as _i43;
import 'package:ginfit/app/features/auth/features/create_account/data/create_account_usecase.dart'
    as _i30;
import 'package:ginfit/app/features/auth/features/login/bloc/login_bloc.dart'
    as _i33;
import 'package:ginfit/app/features/auth/features/login/data/login_usecase.dart'
    as _i16;
import 'package:ginfit/app/features/auth/features/profile/bloc/profile_bloc.dart'
    as _i44;
import 'package:ginfit/app/features/auth/features/profile/data/profile_usecase.dart'
    as _i35;
import 'package:ginfit/app/features/auth/features/splash/bloc/splash_bloc.dart'
    as _i22;
import 'package:ginfit/app/features/auth/features/splash/data/splash_usecase.dart'
    as _i23;
import 'package:ginfit/app/features/closet/bloc/closet_bloc.dart' as _i42;
import 'package:ginfit/app/features/closet/data/closet_usecase.dart' as _i29;
import 'package:ginfit/app/features/closet/services/closet_analysis_service.dart'
    as _i5;
import 'package:ginfit/app/features/fal_ai/data/fal_ai_usecase.dart' as _i31;
import 'package:ginfit/app/features/fit_check/services/fit_check_service.dart'
    as _i11;
import 'package:ginfit/app/features/library/bloc/library_bloc.dart' as _i32;
import 'package:ginfit/app/features/library/data/library_usecase.dart' as _i15;
import 'package:ginfit/app/features/payment/bloc/payment_bloc.dart' as _i34;
import 'package:ginfit/app/features/payment/data/payment_usecase.dart' as _i17;
import 'package:ginfit/app/features/realtime/bloc/realtime_bloc.dart' as _i36;
import 'package:ginfit/app/features/realtime/data/realtime_usecase.dart' as _i18;
import 'package:ginfit/app/features/report/bloc/report_bloc.dart' as _i37;
import 'package:ginfit/app/features/report/data/report_usecase.dart' as _i19;
import 'package:ginfit/app/features/template_generate/bloc/template_generate_bloc.dart'
    as _i38;
import 'package:ginfit/app/features/template_generate/data/template_generate_usecase.dart'
    as _i24;
import 'package:ginfit/app/features/text_to_image/bloc/text_to_image_bloc.dart'
    as _i39;
import 'package:ginfit/app/features/text_to_image/data/text_to_image_usecase.dart'
    as _i25;
import 'package:ginfit/app/features/video_generate/bloc/video_generate_bloc.dart'
    as _i40;
import 'package:ginfit/app/features/video_generate/data/video_generate_usecase.dart'
    as _i27;
import 'package:ginfit/core/data_sources/firebase_module_firestore.dart' as _i46;
import 'package:ginfit/core/data_sources/local_data_source/secure_data_storage.dart'
    as _i20;
import 'package:ginfit/core/injection/modules/dio_module.dart' as _i45;
import 'package:ginfit/core/injection/modules/secure_storage_module.dart'
    as _i47;
import 'package:ginfit/core/routes/app_router.dart' as _i3;
import 'package:ginfit/core/services/bottom_sheet_service.dart' as _i4;
import 'package:ginfit/core/services/language_service.dart' as _i14;
import 'package:ginfit/core/services/snackbar_service.dart' as _i21;
import 'package:ginfit/core/services/theme_service.dart' as _i26;
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
    gh.factory<_i3.AppRouter>(() => _i3.AppRouter());
    gh.lazySingleton<_i4.BottomSheetService>(() => _i4.BottomSheetService());
    gh.singleton<_i5.ClosetAnalysisService>(() => _i5.ClosetAnalysisService());
    gh.singleton<_i6.Dio>(() => dioModule.dio());
    gh.lazySingleton<_i7.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i8.FirebaseFirestore>(
        () => firebaseModuleFirestore.firebaseAuth);
    gh.singleton<_i9.FirebaseStorage>(() => registerModule.firebaseStorage);
    gh.factory<_i10.FirstInstallBonusService>(
        () => _i10.FirstInstallBonusService(gh<_i8.FirebaseFirestore>()));
    gh.factory<_i11.FitCheckService>(() => _i11.FitCheckService(
          gh<_i7.FirebaseAuth>(),
          gh<_i8.FirebaseFirestore>(),
          gh<_i9.FirebaseStorage>(),
        ));
    gh.singleton<_i12.FlutterSecureStorage>(
        () => secureStorageModule.storage());
    gh.lazySingleton<_i13.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.factory<_i14.LanguageService>(() => _i14.LanguageService());
    gh.factory<_i15.LibraryUsecase>(() => _i15.LibraryUsecase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
        ));
    gh.factory<_i16.LoginUseCase>(() => _i16.LoginUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i13.GoogleSignIn>(),
        ));
    gh.factory<_i17.PaymentUsecase>(() => _i17.PaymentUsecase(
          gh<_i7.FirebaseAuth>(),
          gh<_i9.FirebaseStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i18.RealtimeUsecase>(() => _i18.RealtimeUsecase(
          gh<_i7.FirebaseAuth>(),
          gh<_i9.FirebaseStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i19.ReportUsecase>(() => _i19.ReportUsecase(
          gh<_i7.FirebaseAuth>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.singleton<_i20.SecureDataStorage>(
        () => _i20.SecureDataStorage(gh<_i12.FlutterSecureStorage>()));
    gh.factory<_i21.SnackBarService>(() => _i21.SnackBarService());
    gh.singleton<_i22.SplashBloc>(() => _i22.SplashBloc());
    gh.factory<_i23.SplashUseCase>(() => const _i23.SplashUseCase());
    gh.factory<_i24.TemplateGenerateUsecase>(() => _i24.TemplateGenerateUsecase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.factory<_i25.TextToImageUsecase>(() => _i25.TextToImageUsecase(
          gh<_i7.FirebaseAuth>(),
          gh<_i9.FirebaseStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i26.ThemeService>(() => _i26.ThemeService());
    gh.factory<_i27.VideoGenerateUsecase>(() => _i27.VideoGenerateUsecase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.factory<_i28.AppUseCase>(() => _i28.AppUseCase(
          gh<_i20.SecureDataStorage>(),
          firestore: gh<_i8.FirebaseFirestore>(),
        ));
    gh.factory<_i29.ClosetUseCase>(() => _i29.ClosetUseCase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.factory<_i30.CreateAccountUseCase>(() => _i30.CreateAccountUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i13.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
          bonusService: gh<_i10.FirstInstallBonusService>(),
        ));
    gh.factory<_i31.FalAiUsecase>(() => _i31.FalAiUsecase(
          firestore: gh<_i8.FirebaseFirestore>(),
          auth: gh<_i7.FirebaseAuth>(),
          storage: gh<_i9.FirebaseStorage>(),
        ));
    gh.singleton<_i32.LibraryBloc>(() => _i32.LibraryBloc(
          generateUseCase: gh<_i15.LibraryUsecase>(),
          videoGenerateUsecase: gh<_i27.VideoGenerateUsecase>(),
        ));
    gh.singleton<_i33.LoginBloc>(() => _i33.LoginBloc(
          loginUseCase: gh<_i16.LoginUseCase>(),
          createAccountUseCase: gh<_i30.CreateAccountUseCase>(),
        ));
    gh.singleton<_i34.PaymentBloc>(
        () => _i34.PaymentBloc(generateUseCase: gh<_i17.PaymentUsecase>()));
    gh.factory<_i35.ProfileUseCase>(() => _i35.ProfileUseCase(
          auth: gh<_i7.FirebaseAuth>(),
          googleSignIn: gh<_i13.GoogleSignIn>(),
          firestore: gh<_i8.FirebaseFirestore>(),
          secureDataStorage: gh<_i20.SecureDataStorage>(),
        ));
    gh.singleton<_i36.RealtimeBloc>(
        () => _i36.RealtimeBloc(generateUseCase: gh<_i18.RealtimeUsecase>()));
    gh.singleton<_i37.ReportBloc>(
        () => _i37.ReportBloc(reportUsecase: gh<_i19.ReportUsecase>()));
    gh.singleton<_i38.TemplateGenerateBloc>(() => _i38.TemplateGenerateBloc(
          templateUseCase: gh<_i24.TemplateGenerateUsecase>(),
          falAiUsecase: gh<_i31.FalAiUsecase>(),
          videoGenerateUsecase: gh<_i27.VideoGenerateUsecase>(),
        ));
    gh.singleton<_i39.TextToImageBloc>(() =>
        _i39.TextToImageBloc(generateUseCase: gh<_i25.TextToImageUsecase>()));
    gh.singleton<_i40.VideoGenerateBloc>(() => _i40.VideoGenerateBloc(
          generateUseCase: gh<_i27.VideoGenerateUsecase>(),
          falAiUsecase: gh<_i31.FalAiUsecase>(),
        ));
    gh.singleton<_i41.AppBloc>(
        () => _i41.AppBloc(appUsecase: gh<_i28.AppUseCase>()));
    gh.singleton<_i42.ClosetBloc>(
        () => _i42.ClosetBloc(closetUseCase: gh<_i29.ClosetUseCase>()));
    gh.singleton<_i43.CreateAccountBloc>(() => _i43.CreateAccountBloc(
        createAccountUseCase: gh<_i30.CreateAccountUseCase>()));
    gh.singleton<_i44.ProfileBloc>(() => _i44.ProfileBloc(
          loginUseCase: gh<_i16.LoginUseCase>(),
          createAccountUseCase: gh<_i30.CreateAccountUseCase>(),
          profileUseCase: gh<_i35.ProfileUseCase>(),
        ));
    return this;
  }
}

class _$DioModule extends _i45.DioModule {}

class _$FirebaseModule extends _i16.FirebaseModule {}

class _$FirebaseModuleFirestore extends _i46.FirebaseModuleFirestore {}

class _$RegisterModule extends _i45.RegisterModule {}

class _$SecureStorageModule extends _i47.SecureStorageModule {}
