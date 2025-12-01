part of 'app_bloc.dart';

// Custom AI Models Configuration
class CustomAIModels {
  final String imageToVideo;
  final String textToVideo;

  const CustomAIModels({
    this.imageToVideo = 'pixverse',
    this.textToVideo = 'pixverse',
  });

  CustomAIModels copyWith({
    String? imageToVideo,
    String? textToVideo,
  }) {
    return CustomAIModels(
      imageToVideo: imageToVideo ?? this.imageToVideo,
      textToVideo: textToVideo ?? this.textToVideo,
    );
  }
}

class AppState extends Equatable {
  const AppState({
    this.themeMode = ThemeMode.light,
    this.languageLocale = const Locale('en'),
    this.appDocs,
    this.appDashboardTrendingTemplates,
    this.trendingTemplates,
    this.appDocuments,
    this.generateCreditRequirements,
    this.customAIModels = const CustomAIModels(),
    this.gettingAppDocsStatus = EventStatus.idle,
    this.gettingTrendingTemplateStatus = EventStatus.idle,
    this.getAppDocumentsStatus = EventStatus.idle,
    this.isCheckedTermsAndPolicy = true,
    this.submitFeedbackStatus = EventStatus.idle,
    this.searchQuery = '',
    this.filteredAppDocs,
    this.filteredTemplates,
    this.plans,
    this.purchasedInfo,
    this.currentVersionFromFirestore,
    this.currentVersionAndroid,
    this.currentVersionIOS,
    this.forceUpdate = false,
  });

  final ThemeMode themeMode;
  final Locale? languageLocale;
  final List<FeaturesDocModel>? appDocs;
  final List<VideoTemplate>? appDashboardTrendingTemplates;
  final List<VideoTemplate>? trendingTemplates;
  final AppDocumentModel? appDocuments;
  final GenerateCreditRequirements? generateCreditRequirements;
  final CustomAIModels customAIModels;
  final EventStatus gettingAppDocsStatus;
  final EventStatus gettingTrendingTemplateStatus;
  final EventStatus getAppDocumentsStatus;
  final bool isCheckedTermsAndPolicy;
  final EventStatus submitFeedbackStatus;
  final String? searchQuery;
  final List<FeaturesDocModel>? filteredAppDocs;
  final List<VideoTemplate>? filteredTemplates;
  final List<PlanModel>? plans; // Tüm planların listesi
  final PurchasedInfo? purchasedInfo; // Kullanıcının satın alma bilgileri
  final String?
      currentVersionFromFirestore; // Firestore'dan gelen current_version (deprecated)
  final String? currentVersionAndroid; // Android için current_version
  final String? currentVersionIOS; // iOS için current_version
  final bool forceUpdate; // Zorunlu güncelleme gerekli mi?

  AppState copyWith({
    ThemeMode? themeMode,
    Locale? languageLocale,
    List<FeaturesDocModel>? appDocs,
    List<VideoTemplate>? appDashboardTrendingTemplates,
    List<VideoTemplate>? trendingTemplates,
    AppDocumentModel? appDocuments,
    GenerateCreditRequirements? generateCreditRequirements,
    CustomAIModels? customAIModels,
    EventStatus? gettingAppDocsStatus,
    EventStatus? gettingTrendingTemplateStatus,
    EventStatus? getAppDocumentsStatus,
    bool isCheckedTermsAndPolicy = true,
    EventStatus? submitFeedbackStatus,
    String? searchQuery,
    List<FeaturesDocModel>? filteredAppDocs,
    List<VideoTemplate>? filteredTemplates,
    List<PlanModel>? plans,
    PurchasedInfo? purchasedInfo,
    String? currentVersionFromFirestore,
    String? currentVersionAndroid,
    String? currentVersionIOS,
    bool? forceUpdate,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      languageLocale: languageLocale ?? this.languageLocale,
      appDocs: appDocs ?? this.appDocs,
      appDashboardTrendingTemplates:
          appDashboardTrendingTemplates ?? this.appDashboardTrendingTemplates,
      trendingTemplates: trendingTemplates ?? this.trendingTemplates,
      appDocuments: appDocuments ?? this.appDocuments,
      generateCreditRequirements:
          generateCreditRequirements ?? this.generateCreditRequirements,
      customAIModels: customAIModels ?? this.customAIModels,
      gettingAppDocsStatus: gettingAppDocsStatus ?? this.gettingAppDocsStatus,
      gettingTrendingTemplateStatus:
          gettingTrendingTemplateStatus ?? this.gettingTrendingTemplateStatus,
      getAppDocumentsStatus:
          getAppDocumentsStatus ?? this.getAppDocumentsStatus,
      isCheckedTermsAndPolicy: isCheckedTermsAndPolicy,
      submitFeedbackStatus: submitFeedbackStatus ?? this.submitFeedbackStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredAppDocs: filteredAppDocs ?? this.filteredAppDocs,
      filteredTemplates: filteredTemplates ?? this.filteredTemplates,
      plans: plans ?? this.plans,
      purchasedInfo: purchasedInfo ?? this.purchasedInfo,
      currentVersionFromFirestore:
          currentVersionFromFirestore ?? this.currentVersionFromFirestore,
      currentVersionAndroid:
          currentVersionAndroid ?? this.currentVersionAndroid,
      currentVersionIOS: currentVersionIOS ?? this.currentVersionIOS,
      forceUpdate: forceUpdate ?? this.forceUpdate,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        languageLocale,
        appDashboardTrendingTemplates,
        trendingTemplates,
        appDocuments,
        appDocs,
        generateCreditRequirements,
        customAIModels,
        gettingAppDocsStatus,
        gettingTrendingTemplateStatus,
        getAppDocumentsStatus,
        isCheckedTermsAndPolicy,
        submitFeedbackStatus,
        searchQuery,
        filteredAppDocs,
        filteredTemplates,
        plans,
        purchasedInfo,
        currentVersionFromFirestore,
        currentVersionAndroid,
        currentVersionIOS,
        forceUpdate,
      ];
}
