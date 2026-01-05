import "package:flutter/material.dart";
import "package:intl/intl.dart";

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension DurationFormatter on Duration {
  String get toFormattedString {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

extension ColorSheme on BuildContext {
  Color get baseColor => Theme.of(this).colorScheme.primary;

  Color get white => Theme.of(this).colorScheme.onPrimary;
  Color get gray3 => Theme.of(this).colorScheme.onPrimary;

  Color get lightBlack => Theme.of(this).colorScheme.onSecondary;
  Color get black => Theme.of(this).colorScheme.scrim;
  Color get lightRed => Theme.of(this).colorScheme.onTertiary;
  Color get red => Theme.of(this).colorScheme.tertiaryContainer;
}

extension PrettyDateTimeTR on String {
  String get toShortDateTimeTR {
    try {
      final dateTime = DateTime.parse(this).toLocal();
      final time = DateFormat.Hm('en_EN').format(dateTime); // "18:53"
      final date = DateFormat('d MMM', 'en_EN').format(dateTime); // "19 May"
      return '$time, $date';
    } catch (e) {
      return this;
    }
  }
}

extension AspectRatioParser on String {
  double get toAspectRatioDouble {
    try {
      final parts = split(':');
      final width = double.parse(parts[0]);
      final height = double.parse(parts[1]);
      return width / height;
    } catch (e) {
      return 1.0; // Geçersizse 1:1 default
    }
  }
}

String resolveByLocale(
  Locale? locale,
  String base, {
  String? tr,
  String? de,
  String? fr,
  String? ar,
  String? ru,
  String? zh,
  String? es,
  String? hi,
  String? pt,
  String? id,
}) {
  switch (locale?.languageCode ?? 'tr') {
    case 'tr':
      return tr ?? base;
    case 'de':
      return de ?? base;
    case 'fr':
      return fr ?? base;
    case 'ar':
      return ar ?? base;
    case 'ru':
      return ru ?? base;
    case 'zh':
      return zh ?? base;
    case 'es':
      return es ?? base;
    case 'hi':
      return hi ?? base;
    case 'pt':
      return pt ?? base;
    case 'id':
      return id ?? base;
    default:
      return base;
  }
}
