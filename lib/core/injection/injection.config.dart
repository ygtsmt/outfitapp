// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i7;
import 'package:dio/dio.dart' as _i5;
import 'package:firebase_auth/firebase_auth.dart' as _i6;
import 'package:firebase_storage/firebase_storage.dart' as _i8;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:ginly/app/bloc/app_bloc.dart' as _i38;
import 'package:ginly/app/core/services/first_install_bonus_service.dart'
    as _i9;
import 'package:ginly/app/data/app_usecase.dart' as _i26;
import 'package:ginly/app/features/auth/features/create_account/bloc/create_account_bloc.dart'
    as _i39;
import 'package:ginly/app/features/auth/features/create_account/data/create_account_usecase.dart'
    as _i27;
import 'package:ginly/app/features/auth/features/login/bloc/login_bloc.dart'
    as _i30;
import 'package:ginly/app/features/auth/features/login/data/login_usecase.dart'
    as _i14;
import 'package:ginly/app/features/auth/features/profile/bloc/profile_bloc.dart'
    as _i40;
import 'package:ginly/app/features/auth/features/profile/data/profile_usecase.dart'
    as _i32;
import 'package:ginly/app/features/auth/features/splash/bloc/splash_bloc.dart'
    as _i20;
import 'package:ginly/app/features/auth/features/splash/data/splash_usecase.dart'
    as _i21;
import 'package:ginly/app/features/fal_ai/data/fal_ai_usecase.dart' as _i28;
import 'package:ginly/app/features/library/bloc/library_bloc.dart' as _i29;
import 'package:ginly/app/features/library/data/library_usecase.dart' as _i13;
import 'package:ginly/app/features/payment/bloc/payment_bloc.dart' as _i31;
import 'package:ginly/app/features/payment/data/payment_usecase.dart' as _i15;
import 'package:ginly/app/features/realtime/bloc/realtime_bloc.dart' as _i33;
import 'package:ginly/app/features/realtime/data/realtime_usecase.dart' as _i16;
import 'package:ginly/app/features/report/bloc/report_bloc.dart' as _i34;
import 'package:ginly/app/features/report/data/report_usecase.dart' as _i17;
import 'package:ginly/app/features/template_generate/bloc/template_generate_bloc.dart'
    as _i35;
import 'package:ginly/app/features/template_generate/data/template_generate_usecase.dart'
    as _i22;
import 'package:ginly/app/features/text_to_image/bloc/text_to_image_bloc.dart'
    as _i36;
import 'package:ginly/app/features/text_to_image/data/text_to_image_usecase.dart'
    as _i23;
import 'package:ginly/app/features/video_generate/bloc/video_generate_bloc.dart'
    as _i37;
import 'package:ginly/app/features/video_generate/data/video_generate_usecase.dart'
    as _i25;
import 'package:ginly/core/data_sources/firebase_module_firestore.dart' as _i42;
import 'package:ginly/core/data_sources/local_data_source/secure_data_storage.dart'
    as _i18;
import 'package:ginly/core/injection/modules/dio_module.dart' as _i41;
import 'package:ginly/core/injection/modules/secure_storage_module.dart'
    as _i43;
import 'package:ginly/core/routes/app_router.dart' as _i3;
import 'package:ginly/core/services/bottom_sheet_service.dart' as _i4;
import 'package:ginly/core/services/language_service.dart' as _i12;
import 'package:ginly/core/services/snackbar_service.dart' as _i19;
import 'package:ginly/core/services/theme_service.dart' as _i24;
import 'package:google_sign_in/google_sign_in.dart' as _i11;
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
    gh.singleton<_i5.Dio>(() => dioModule.dio());
    gh.lazySingleton<_i6.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i7.FirebaseFirestore>(
        () => firebaseModuleFirestore.firebaseAuth);
    gh.singleton<_i8.FirebaseStorage>(() => registerModule.firebaseStorage);
    gh.factory<_i9.FirstInstallBonusService>(
        () => _i9.FirstInstallBonusService(gh<_i7.FirebaseFirestore>()));
    gh.singleton<_i10.FlutterSecureStorage>(
        () => secureStorageModule.storage());
    gh.lazySingleton<_i11.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.factory<_i12.LanguageService>(() => _i12.LanguageService());
    gh.factory<_i13.LibraryUsecase>(() => _i13.LibraryUsecase(
          firestore: gh<_i7.FirebaseFirestore>(),
          auth: gh<_i6.FirebaseAuth>(),
        ));
    gh.factory<_i14.LoginUseCase>(() => _i14.LoginUseCase(
          auth: gh<_i6.FirebaseAuth>(),
          googleSignIn: gh<_i11.GoogleSignIn>(),
        ));
    gh.factory<_i15.PaymentUsecase>(() => _i15.PaymentUsecase(
          gh<_i6.FirebaseAuth>(),
          gh<_i8.FirebaseStorage>(),
          firestore: gh<_i7.FirebaseFirestore>(),
        ));
    gh.factory<_i16.RealtimeUsecase>(() => _i16.RealtimeUsecase(
          gh<_i6.FirebaseAuth>(),
          gh<_i8.FirebaseStorage>(),
          firestore: gh<_i7.FirebaseFirestore>(),
        ));
    gh.factory<_i17.ReportUsecase>(() => _i17.ReportUsecase(
          gh<_i6.FirebaseAuth>(),
          firestore: gh<_i7.FirebaseFirestore>(),
        ));
    gh.singleton<_i18.SecureDataStorage>(
        () => _i18.SecureDataStorage(gh<_i10.FlutterSecureStorage>()));
    gh.factory<_i19.SnackBarService>(() => _i19.SnackBarService());
    gh.singleton<_i20.SplashBloc>(() => _i20.SplashBloc());
    gh.factory<_i21.SplashUseCase>(() => const _i21.SplashUseCase());
    gh.factory<_i22.TemplateGenerateUsecase>(() => _i22.TemplateGenerateUsecase(
          firestore: gh<_i7.FirebaseFirestore>(),
          auth: gh<_i6.FirebaseAuth>(),
          storage: gh<_i8.FirebaseStorage>(),
        ));
    gh.factory<_i23.TextToImageUsecase>(() => _i23.TextToImageUsecase(
          gh<_i6.FirebaseAuth>(),
          gh<_i8.FirebaseStorage>(),
          firestore: gh<_i7.FirebaseFirestore>(),
        ));
    gh.factory<_i24.ThemeService>(() => _i24.ThemeService());
    gh.factory<_i25.VideoGenerateUsecase>(() => _i25.VideoGenerateUsecase(
          firestore: gh<_i7.FirebaseFirestore>(),
          auth: gh<_i6.FirebaseAuth>(),
          storage: gh<_i8.FirebaseStorage>(),
        ));
    gh.factory<_i26.AppUseCase>(() => _i26.AppUseCase(
          gh<_i18.SecureDataStorage>(),
          firestore: gh<_i7.FirebaseFirestore>(),
        ));
    gh.factory<_i27.CreateAccountUseCase>(() => _i27.CreateAccountUseCase(
          auth: gh<_i6.FirebaseAuth>(),
          googleSignIn: gh<_i11.GoogleSignIn>(),
          firestore: gh<_i7.FirebaseFirestore>(),
          bonusService: gh<_i9.FirstInstallBonusService>(),
        ));
    gh.factory<_i28.FalAiUsecase>(() => _i28.FalAiUsecase(
          firestore: gh<_i7.FirebaseFirestore>(),
          auth: gh<_i6.FirebaseAuth>(),
          storage: gh<_i8.FirebaseStorage>(),
        ));
    gh.singleton<_i29.LibraryBloc>(() => _i29.LibraryBloc(
          generateUseCase: gh<_i13.LibraryUsecase>(),
          videoGenerateUsecase: gh<_i25.VideoGenerateUsecase>(),
        ));
    gh.singleton<_i30.LoginBloc>(() => _i30.LoginBloc(
          loginUseCase: gh<_i14.LoginUseCase>(),
          createAccountUseCase: gh<_i27.CreateAccountUseCase>(),
        ));
    gh.singleton<_i31.PaymentBloc>(
        () => _i31.PaymentBloc(generateUseCase: gh<_i15.PaymentUsecase>()));
    gh.factory<_i32.ProfileUseCase>(() => _i32.ProfileUseCase(
          auth: gh<_i6.FirebaseAuth>(),
          googleSignIn: gh<_i11.GoogleSignIn>(),
          firestore: gh<_i7.FirebaseFirestore>(),
          secureDataStorage: gh<_i18.SecureDataStorage>(),
        ));
    gh.singleton<_i33.RealtimeBloc>(
        () => _i33.RealtimeBloc(generateUseCase: gh<_i16.RealtimeUsecase>()));
    gh.singleton<_i34.ReportBloc>(
        () => _i34.ReportBloc(reportUsecase: gh<_i17.ReportUsecase>()));
    gh.singleton<_i35.TemplateGenerateBloc>(() => _i35.TemplateGenerateBloc(
          templateUseCase: gh<_i22.TemplateGenerateUsecase>(),
          falAiUsecase: gh<_i28.FalAiUsecase>(),
          videoGenerateUsecase: gh<_i25.VideoGenerateUsecase>(),
        ));
    gh.singleton<_i36.TextToImageBloc>(() =>
        _i36.TextToImageBloc(generateUseCase: gh<_i23.TextToImageUsecase>()));
    gh.singleton<_i37.VideoGenerateBloc>(() => _i37.VideoGenerateBloc(
          generateUseCase: gh<_i25.VideoGenerateUsecase>(),
          falAiUsecase: gh<_i28.FalAiUsecase>(),
        ));
    gh.singleton<_i38.AppBloc>(
        () => _i38.AppBloc(appUsecase: gh<_i26.AppUseCase>()));
    gh.singleton<_i39.CreateAccountBloc>(() => _i39.CreateAccountBloc(
        createAccountUseCase: gh<_i27.CreateAccountUseCase>()));
    gh.singleton<_i40.ProfileBloc>(() => _i40.ProfileBloc(
          loginUseCase: gh<_i14.LoginUseCase>(),
          createAccountUseCase: gh<_i27.CreateAccountUseCase>(),
          profileUseCase: gh<_i32.ProfileUseCase>(),
        ));
    return this;
  }
}

class _$DioModule extends _i41.DioModule {}

class _$FirebaseModule extends _i14.FirebaseModule {}

class _$FirebaseModuleFirestore extends _i42.FirebaseModuleFirestore {}

class _$RegisterModule extends _i41.RegisterModule {}

class _$SecureStorageModule extends _i43.SecureStorageModule {}
