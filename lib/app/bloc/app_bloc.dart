import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginfit/app/data/app_usecase.dart';
import 'package:ginfit/app/data/models/app_document_model.dart';
import 'package:ginfit/app/data/models/feedback_model.dart';
import 'package:ginfit/app/data/models/credit_model.dart';
import 'package:ginfit/app/data/models/plan_model.dart';
import 'package:ginfit/app/data/models/purchased_info_model.dart';
import 'package:ginfit/core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';

part 'app_event.dart';
part 'app_state.dart';

@singleton
class AppBloc extends Bloc<AppEvent, AppState> {
  final AppUseCase appUsecase;
  AppBloc({required this.appUsecase}) : super(const AppState()) {
    on<SetThemeEvent>((event, emit) {
      emit(state.copyWith(themeMode: event.themeMode));
    });
    on<CheckedTermsAndPolicyEvent>((event, emit) {
      emit(state.copyWith(isCheckedTermsAndPolicy: event.isCheked));
    });
    on<SetLanguageEvent>((event, emit) async {
      await appUsecase.setAppLanguage(event.locale);
      emit(state.copyWith(languageLocale: event.locale));
    });

    //kdflkmsdf

    on<SubmitFeedbackEvent>((event, emit) async {
      emit(state.copyWith(submitFeedbackStatus: EventStatus.processing));
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(state.copyWith(submitFeedbackStatus: EventStatus.failure));
          return;
        }

        String? imageUrl;
        if (event.imageFile != null) {
          imageUrl = await appUsecase.uploadFeedbackImage(event.imageFile!);
        }

        final feedback = FeedbackModel(
          userId: user.uid,
          message: event.message,
          createdAt: DateTime.now(),
          imageUrl: imageUrl,
        );

        await appUsecase.submitFeedback(feedback);
        emit(state.copyWith(submitFeedbackStatus: EventStatus.success));
      } catch (e) {
        emit(state.copyWith(submitFeedbackStatus: EventStatus.failure));
      }
      emit(state.copyWith(submitFeedbackStatus: EventStatus.idle));
    });

    on<InitializeLanguageEvent>((event, emit) async {
      try {
        // Kullanıcının telefon dilini al
        final deviceLocale = Platform.localeName.split('_')[0];
        print('🌍 Device locale: $deviceLocale');

        // Desteklenen dilleri kontrol et
        final supportedLanguages = ['tr', 'en', 'de', 'fr', 'ru', 'ar', 'zh'];
        final defaultLanguage =
            supportedLanguages.contains(deviceLocale) ? deviceLocale : 'en';

        print('🎯 Selected language: $defaultLanguage');

        // Her zaman telefon dilini kullan (kullanıcı seçimi yok)
        final locale = Locale(defaultLanguage);
        await appUsecase.setAppLanguage(locale);
        emit(state.copyWith(languageLocale: locale));

        print('✅ Language set to: $locale');
      } catch (e) {
        // Hata durumunda İngilizce'yi default yap
        final locale = const Locale('en');
        await appUsecase.setAppLanguage(locale);
        emit(state.copyWith(languageLocale: locale));
      }
    });
  }
}
