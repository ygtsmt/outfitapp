import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ginly/app/data/app_usecase.dart';
import 'package:ginly/app/data/models/app_document_model.dart';
import 'package:ginly/app/data/models/features_doc_model.dart';
import 'package:ginly/app/data/models/feedback_model.dart';
import 'package:ginly/app/data/models/credit_model.dart';
import 'package:ginly/app/data/models/plan_model.dart';
import 'package:ginly/app/data/models/purchased_info_model.dart';
import 'package:ginly/core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import 'dart:developer';

part 'app_event.dart';
part 'app_state.dart';

@singleton
class AppBloc extends Bloc<AppEvent, AppState> {
  final AppUseCase appUsecase;
  AppBloc({required this.appUsecase}) : super(const AppState()) {
    // Firestore'dan custom AI models'i dinle
    _listenToCustomAIModels();

    /// Version karşılaştırma fonksiyonu
    /// Returns:
    /// - Negatif değer: version1 < version2
    /// - 0: version1 == version2
    /// - Pozitif değer: version1 > version2
    int _compareVersions(String version1, String version2) {
      final v1Parts =
          version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final v2Parts =
          version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLength =
          v1Parts.length > v2Parts.length ? v1Parts.length : v2Parts.length;

      for (int i = 0; i < maxLength; i++) {
        final v1 = i < v1Parts.length ? v1Parts[i] : 0;
        final v2 = i < v2Parts.length ? v2Parts[i] : 0;

        if (v1 != v2) {
          return v1 - v2;
        }
      }

      return 0;
    }

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

        // App versiyonunu al
        final packageInfo = await PackageInfo.fromPlatform();
        final appVersion = packageInfo.version;

        // Platform bazlı version kontrolü
        String? platformVersion;
        bool shouldDisableFilters = false;

        if (kIsWeb) {
          // Web için version kontrolü yok - filtreleri devre dışı bırak
          shouldDisableFilters = true;
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          platformVersion = state.currentVersionIOS;
          if (platformVersion?.isNotEmpty == true) {
            // App version <= Firebase version ise filtreleri devre dışı bırak
            // App version > Firebase version ise filtreleri etkinleştir
            final comparison = _compareVersions(appVersion, platformVersion!);
            shouldDisableFilters =
                comparison <= 0; // appVersion <= platformVersion
          } else {
            // Firebase'de version yoksa filtreleri devre dışı bırak
            shouldDisableFilters = true;
          }
        } else if (defaultTargetPlatform == TargetPlatform.android) {
          platformVersion = state.currentVersionAndroid;
          if (platformVersion?.isNotEmpty == true) {
            // App version <= Firebase version ise filtreleri devre dışı bırak
            // App version > Firebase version ise filtreleri etkinleştir
            final comparison = _compareVersions(appVersion, platformVersion!);
            shouldDisableFilters =
                comparison <= 0; // appVersion <= platformVersion
          } else {
            // Firebase'de version yoksa filtreleri devre dışı bırak
            shouldDisableFilters = true;
          }
        }

        log('📱 App Version: $appVersion');
        log('🔥 Platform: ${kIsWeb ? 'Web' : defaultTargetPlatform.name}');
        log('🔥 Firebase Version: $platformVersion');
        log('✅ Should Disable Filters: $shouldDisableFilters ${shouldDisableFilters ? "(Show All Templates)" : "(Apply Filters - App > Firebase)"}');

        // Platform bazında doc filtreleme
        List<FeaturesDocModel> filteredDocs;

        // ÖNCELİKLİ: dont_use_doc kontrolü - Bu doc'ları HİÇBİR ZAMAN gösterme
        final availableDocs = docs.where((doc) {
          if (doc.dont_use_doc == false) {
            log('⛔ Doc kalıcı olarak gizlendi (dont_use_doc=false): ${doc.id}');
            return false;
          }
          return true;
        }).toList();

        if (kIsWeb) {
          filteredDocs = availableDocs; // Web için tüm docs
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          if (shouldDisableFilters) {
            // App version <= Firebase version - TÜM DOC'LARI GÖSTER
            filteredDocs = availableDocs;
            log('🔓 Tüm doc\'lar gösteriliyor (App version <= Firebase version - iOS)');
          } else {
            // App version > Firebase version - FİLTRELEME YAP
            filteredDocs = availableDocs
                .where((doc) => doc.showOnAppleTemplates != false)
                .toList();
            log('🚫 Doc filtreleme aktif (App version > Firebase version - iOS)');
          }
        } else if (defaultTargetPlatform == TargetPlatform.android) {
          if (shouldDisableFilters) {
            // App version <= Firebase version - TÜM DOC'LARI GÖSTER
            filteredDocs = availableDocs;
            log('🔓 Tüm doc\'lar gösteriliyor (App version <= Firebase version - Android)');
          } else {
            // App version > Firebase version - FİLTRELEME YAP
            filteredDocs = availableDocs
                .where((doc) => doc.showOnAndroidTemplates != false)
                .toList();
            log('🚫 Doc filtreleme aktif (App version > Firebase version - Android)');
          }
        } else {
          filteredDocs = availableDocs;
        }

        // Template'leri platform bazında filtrele
        final finalFilteredDocs = filteredDocs.map((doc) {
          final filteredTemplates = <String, List<VideoTemplate>>{};

          doc.templates.forEach((key, templateList) {
            final filteredList = templateList.where((template) {
              // ÖNCELİKLİ: dont_use_template kontrolü - Bu template'ı HİÇBİR ZAMAN gösterme
              if (template.dont_use_template == false) {
                log('⛔ Template kalıcı olarak gizlendi (dont_use_template=false): ${template.id}');
                return false;
              }

              // Platform bazlı filtreleme
              if (kIsWeb) {
                return true; // Web'de tüm template'leri göster
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                // iOS için version kontrolü
                if (shouldDisableFilters) {
                  // App version <= Firebase version - TÜM TEMPLATE'LARI GÖSTER
                  log('🔓 Template gösteriliyor (App version <= Firebase version): ${template.id}');
                  return true;
                }

                // App version > Firebase version - FİLTRELEME YAP
                final shouldShow = template.showThisTemplateIOS != false;
                if (!shouldShow) {
                  log('🚫 Template filtrelendi (iOS filter - App > Firebase): ${template.id}');
                }
                return shouldShow;
              } else if (defaultTargetPlatform == TargetPlatform.android) {
                // Android için version kontrolü
                if (shouldDisableFilters) {
                  // App version <= Firebase version - TÜM TEMPLATE'LARI GÖSTER
                  return true;
                }

                // App version > Firebase version - FİLTRELEME YAP
                return template.showThisTemplateAndroid != false;
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
          appDocs: finalFilteredDocs, // Filtrelenmiş docs
          trendingTemplates: trendingTemplates,
        ));
      } catch (e) {
        emit(state.copyWith(gettingAppDocsStatus: EventStatus.failure));
      }
      emit(state.copyWith(gettingAppDocsStatus: EventStatus.idle));
    });

    //kdflkmsdf

    on<GetAllAppDocumentsEvent>((event, emit) async {
      emit(state.copyWith(getAppDocumentsStatus: EventStatus.processing));
      try {
        final appDocumentsRepsonse = await appUsecase.getAppDocuments();
        emit(state.copyWith(
          getAppDocumentsStatus: EventStatus.success,
          appDocuments: appDocumentsRepsonse,
        ));
      } catch (e) {
        emit(state.copyWith(getAppDocumentsStatus: EventStatus.failure));
      }
      emit(state.copyWith(getAppDocumentsStatus: EventStatus.idle));
    });

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

    on<GetPlansEvent>((event, emit) async {
      try {
        final plans = await _getPlansFromFirebase();
        emit(state.copyWith(plans: plans));
      } catch (e) {
        log('Error getting plans: $e');
      }
    });

    on<GetGenerateCreditRequirementsEvent>((event, emit) async {
      try {
        final requirements = await appUsecase.getGenerateCreditRequirements();
        emit(state.copyWith(generateCreditRequirements: requirements));
      } catch (e) {
        log('Error getting generate credit requirements: $e');
      }
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
    on<FetchPurchasedInfoEvent>((event, emit) async {
      try {
        final purchasedInfo = await _getPurchasedInfoFromFirebase(event.userId);
        emit(state.copyWith(purchasedInfo: purchasedInfo));
      } catch (e) {
        log('Error getting purchased info: $e');
      }
    });

    on<_UpdateCustomAIModelsEvent>((event, emit) {
      emit(state.copyWith(customAIModels: event.customAIModels));
    });

    on<_UpdateVersionInfoEvent>((event, emit) {
      emit(state.copyWith(
        currentVersionAndroid: event.currentVersionAndroid,
        currentVersionIOS: event.currentVersionIOS,
        forceUpdate: event.forceUpdate,
      ));
    });
  }

  // Firebase'den plan'ları çek
  Future<List<PlanModel>> _getPlansFromFirebase() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final plansCollection = firestore.collection('plans');

      final querySnapshot = await plansCollection.get();
      final plans = <PlanModel>[];

      for (final doc in querySnapshot.docs) {
        final planData = doc.data();
        final plan = PlanModel.fromMap(planData, doc.id);
        plans.add(plan);
      }

      return plans;
    } catch (e) {
      log('Error getting plans from Firebase: $e');
      return [];
    }
  }

  // Firebase'den kullanıcının satın alma bilgilerini çek
  Future<PurchasedInfo?> _getPurchasedInfoFromFirebase(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['purchased_info'] != null) {
          return PurchasedInfo.fromJson(data['purchased_info']);
        }
      }
      return null;
    } catch (e) {
      log('Error getting purchased info from Firebase: $e');
      return null;
    }
  }

  // Custom AI Models'i Firestore'dan al (tek seferlik - listener YOK!)
  void _listenToCustomAIModels() async {
    try {
      // custom_models'i AL (dinleme yok!)
      final customModelsSnapshot = await FirebaseFirestore.instance
          .collection('systems')
          .doc('custom_models')
          .get();

      if (customModelsSnapshot.exists) {
        final data = customModelsSnapshot.data();
        final imageToVideo = data?['image_to_video'] as String? ?? 'pixverse';
        final textToVideo = data?['text_to_video'] as String? ?? 'pixverse';

        final customModels = CustomAIModels(
          imageToVideo: imageToVideo,
          textToVideo: textToVideo,
        );

        add(_UpdateCustomAIModelsEvent(customModels));
        log('✅ Custom AI Models loaded (one-time read): image_to_video=$imageToVideo, text_to_video=$textToVideo');
      } else {
        log('⚠️ custom_models document not found, using defaults');
      }
    } catch (error) {
      log('❌ Error fetching custom_models: $error');
    }

    try {
      // versions'ı AL (dinleme yok!)
      final versionsSnapshot = await FirebaseFirestore.instance
          .collection('systems')
          .doc('versions')
          .get();

      if (versionsSnapshot.exists) {
        final data = versionsSnapshot.data();
        final currentVersionAndroid =
            data?['current_version_android'] as String? ?? '';
        final currentVersionIOS = data?['current_version_ios'] as String? ?? '';
        final forceUpdate = data?['force_update'] as bool? ?? false;

        add(_UpdateVersionInfoEvent(
            currentVersionAndroid, currentVersionIOS, forceUpdate));
        log('✅ Version Info loaded (one-time read):');
        log('  📱 Android: $currentVersionAndroid');
        log('  🍎 iOS: $currentVersionIOS');
        log('  🔒 Force Update: $forceUpdate');
      } else {
        log('⚠️ versions document not found, using defaults');
      }
    } catch (error) {
      log('❌ Error fetching versions: $error');
    }
  }
}
