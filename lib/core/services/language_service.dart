import "package:injectable/injectable.dart";
import "package:comby/app/bloc/app_bloc.dart";
import "package:comby/core/data_sources/local_data_source/secure_data_storage.dart";
import "package:comby/core/injection/injection.dart";
import "package:flutter/material.dart";
import "dart:io";

@injectable
class LanguageService {
  // Desteklenen diller listesi
  static const List<String> supportedLanguages = [
    'tr',
    'en',
    'de',
    'fr',
    'ru',
    'ar',
    'zh',
    'es',
    'hi',
    'pt',
    'id'
  ];

  Future<void> setSavedLanuage() async {
    // Önce kaydedilmiş dili kontrol et
    final savedLocale = await getIt<SecureDataStorage>().getLocaleLanguage();

    // Eğer kaydedilmiş dil varsa onu kullan
    if (savedLocale != null) {
      getIt<AppBloc>().add(SetLanguageEvent(savedLocale));
      return;
    }

    // Kaydedilmiş dil yoksa telefon dilini kontrol et
    final deviceLocale = _getDeviceLocale();

    // Telefon dili desteklenen diller arasında mı kontrol et
    if (supportedLanguages.contains(deviceLocale.languageCode)) {
      // Telefon dili ne ise onu kullan
      getIt<AppBloc>().add(SetLanguageEvent(deviceLocale));
      return;
    }

    // Telefon dili desteklenmiyorsa İngilizce kullan
    getIt<AppBloc>().add(SetLanguageEvent(const Locale('en')));
  }

  /// Telefon dilini al
  Locale _getDeviceLocale() {
    try {
      // Platform locale'ini al
      final platformLocaleString = Platform.localeName;
      final languageCode = platformLocaleString.split('_')[0];
      return Locale(languageCode);
    } catch (e) {
      // Hata durumunda İngilizce döndür
      return const Locale('en');
    }
  }
}
