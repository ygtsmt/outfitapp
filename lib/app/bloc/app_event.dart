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
