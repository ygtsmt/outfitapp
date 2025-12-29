import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginfit/app/data/app_usecase.dart';
import 'package:ginfit/app/data/models/app_document_model.dart';
import 'package:ginfit/app/data/models/features_doc_model.dart';
import 'package:ginfit/app/data/models/feedback_model.dart';
import 'package:ginfit/app/data/models/credit_model.dart';
import 'package:ginfit/app/data/models/plan_model.dart';
import 'package:ginfit/app/data/models/purchased_info_model.dart';
import 'package:ginfit/core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';
import 'dart:developer';

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

    on<GetAllAppDocsEvent>((event, emit) async {
      // CACHE KONTROLÜ: Eğer zaten appDocs varsa ve force değilse, tekrar çekme!
      if (state.appDocs != null &&
          state.appDocs!.isNotEmpty &&
          !event.forceRefresh) {
        log('📦 Using cached appDocs (${state.appDocs!.length} docs) - skipping Firestore read');
        return; // Firestore'a gitme, mevcut cache'i kullan
      }

      emit(state.copyWith(gettingAppDocsStatus: EventStatus.processing));
      try {
        log('🔥 Fetching appDocs from Firestore (cache miss or force refresh)');
        final docs = await appUsecase.getAllAppDocs();

        final filteredDocs = docs.where((doc) {
          if (doc.dont_use_doc == false) {
            log('⛔ Doc kalıcı olarak gizlendi (dont_use_doc=false): ${doc.id}');
            return false;
          }
          return true;
        }).toList();

        final finalFilteredDocs = filteredDocs.map((doc) {
          final filteredTemplates = <String, List<VideoTemplate>>{};

          doc.templates.forEach((key, templateList) {
            final filteredList = templateList.where((template) {
              if (template.dont_use_template == false) {
                log('⛔ Template kalıcı olarak gizlendi (dont_use_template=false): ${template.id}');
                return false;
              }
              return true;
            }).toList();

            if (filteredList.isNotEmpty) {
              filteredTemplates[key] = filteredList;
            }
          });

          return FeaturesDocModel(
            id: doc.id,
            title: doc.title,
            title_tr: doc.title_tr,
            title_de: doc.title_de,
            title_fr: doc.title_fr,
            title_ar: doc.title_ar,
            title_ru: doc.title_ru,
            title_zh: doc.title_zh,
            title_es: doc.title_es,
            title_hi: doc.title_hi,
            title_pt: doc.title_pt,
            title_id: doc.title_id,
            templates: filteredTemplates,
            showOnAppleTemplates: doc.showOnAppleTemplates,
            showOnAndroidTemplates: doc.showOnAndroidTemplates,
          );
        }).toList();

        final trendingTemplates = finalFilteredDocs
            .expand(
                (doc) => doc.templates.values.expand((templates) => templates))
            .where((template) => template.isTrend == true)
            .toList();

        emit(state.copyWith(
          gettingAppDocsStatus: EventStatus.success,
          appDocs: finalFilteredDocs,
          trendingTemplates: trendingTemplates,
        ));
      } catch (e) {
        emit(state.copyWith(gettingAppDocsStatus: EventStatus.failure));
      }
      emit(state.copyWith(gettingAppDocsStatus: EventStatus.idle));
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

    on<SearchEffectsEvent>((event, emit) async {
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(state.copyWith(
          searchQuery: '',
          filteredAppDocs: null,
          filteredTemplates: null,
        ));
        return;
      }

      final appDocs = state.appDocs;
      if (appDocs == null) return;

      final matchingTemplates = <VideoTemplate>[];

      // Tüm template'lerde arama yap
      for (final doc in appDocs) {
        for (final templates in doc.templates.values) {
          for (final template in templates) {
            // Title'larda arama
            final templateTitles = [
              template.title ?? '',
              template.titleTr ?? '',
              template.titleDe ?? '',
              template.titleFr ?? '',
              template.titleAr ?? '',
              template.titleRu ?? '',
              template.titleZh ?? '',
              template.titleEs ?? '',
              template.titleHi ?? '',
              template.titlePt ?? '',
              template.titleId ?? '',
            ];

            // Label'larda arama
            final templateLabels = [
              template.label ?? '',
              template.labelTr ?? '',
              template.labelFr ?? '',
              template.labelDe ?? '',
              template.labelAr ?? '',
              template.labelRu ?? '',
              template.labelZh ?? '',
              template.labelEs ?? '',
              template.labelHi ?? '',
              template.labelPt ?? '',
              template.labelId ?? '',
            ];

            // Title veya label'da bulundu mu?
            final titleMatch = templateTitles
                .any((title) => title.toLowerCase().contains(query));

            final labelMatch = templateLabels
                .any((label) => label.toLowerCase().contains(query));

            if (titleMatch || labelMatch) {
              matchingTemplates.add(template);
            }
          }
        }
      }

      emit(state.copyWith(
        searchQuery: query,
        filteredAppDocs: null, // Artık kullanmıyoruz
        filteredTemplates: matchingTemplates,
      ));
    });

    on<ClearSearchEvent>((event, emit) {
      emit(state.copyWith(
        searchQuery: '',
        filteredAppDocs: null,
        filteredTemplates: null,
      ));
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
