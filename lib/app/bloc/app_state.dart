part of 'app_bloc.dart';

class AppState extends Equatable {
  const AppState({
    this.themeMode = ThemeMode.light,
    this.languageLocale = const Locale('en'),
    this.isCheckedTermsAndPolicy = true,
    this.submitFeedbackStatus = EventStatus.idle,
    this.plans,
  });

  final ThemeMode themeMode;
  final Locale? languageLocale;
  final bool isCheckedTermsAndPolicy;
  final EventStatus submitFeedbackStatus;
  final List<PlanModel>? plans; // Tüm planların listesi

  AppState copyWith({
    ThemeMode? themeMode,
    Locale? languageLocale,
    bool isCheckedTermsAndPolicy = true,
    EventStatus? submitFeedbackStatus,
    List<PlanModel>? plans,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      languageLocale: languageLocale ?? this.languageLocale,
      isCheckedTermsAndPolicy: isCheckedTermsAndPolicy,
      submitFeedbackStatus: submitFeedbackStatus ?? this.submitFeedbackStatus,
      plans: plans ?? this.plans,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        languageLocale,
        isCheckedTermsAndPolicy,
        submitFeedbackStatus,
        plans,
      ];
}
