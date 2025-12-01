part of 'app_bloc.dart';

class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class SetThemeEvent extends AppEvent {
  const SetThemeEvent(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object> get props => [themeMode];
}

class CheckedTermsAndPolicyEvent extends AppEvent {
  const CheckedTermsAndPolicyEvent(this.isCheked);

  final bool isCheked;

  @override
  List<Object> get props => [isCheked];
}

class SetLanguageEvent extends AppEvent {
  const SetLanguageEvent(this.locale);

  final Locale locale;

  @override
  List<Object> get props => [locale];
}

class GetAllAppDocsEvent extends AppEvent {
  const GetAllAppDocsEvent({this.forceRefresh = false});

  final bool forceRefresh; // true ise cache'i yok say ve yeniden çek

  @override
  List<Object> get props => [forceRefresh];
}

class GetAllAppDocumentsEvent extends AppEvent {
  const GetAllAppDocumentsEvent();

  @override
  List<Object> get props => [];
}

class SubmitFeedbackEvent extends AppEvent {
  const SubmitFeedbackEvent(this.message, {this.imageFile});

  final String message;
  final File? imageFile;

  @override
  List<Object?> get props => [message, imageFile];
}

class InitializeLanguageEvent extends AppEvent {
  const InitializeLanguageEvent();

  @override
  List<Object?> get props => [];
}

class GetGenerateCreditRequirementsEvent extends AppEvent {
  const GetGenerateCreditRequirementsEvent();

  @override
  List<Object?> get props => [];
}

class SearchEffectsEvent extends AppEvent {
  const SearchEffectsEvent(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

class ClearSearchEvent extends AppEvent {
  const ClearSearchEvent();

  @override
  List<Object> get props => [];
}

class GetPlansEvent extends AppEvent {
  const GetPlansEvent();

  @override
  List<Object> get props => [];
}

class FetchPurchasedInfoEvent extends AppEvent {
  const FetchPurchasedInfoEvent(this.userId);

  final String userId;

  @override
  List<Object> get props => [userId];
}

// Internal event to update custom AI models
class _UpdateCustomAIModelsEvent extends AppEvent {
  const _UpdateCustomAIModelsEvent(this.customAIModels);

  final CustomAIModels customAIModels;

  @override
  List<Object> get props => [customAIModels];
}

// Internal event to update version info
class _UpdateVersionInfoEvent extends AppEvent {
  const _UpdateVersionInfoEvent(
    this.currentVersionAndroid,
    this.currentVersionIOS,
    this.forceUpdate,
  );

  final String currentVersionAndroid;
  final String currentVersionIOS;
  final bool forceUpdate;

  @override
  List<Object> get props => [currentVersionAndroid, currentVersionIOS, forceUpdate];
}
