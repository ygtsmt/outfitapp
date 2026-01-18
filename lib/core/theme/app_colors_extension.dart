import 'package:flutter/material.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // High Fashion & Editorial
  final Color fashionBlack;
  final Color offWhite;
  final Color beige;
  final Color editorialGray;
  final Color burgundy;

  // Try-On (Soft Tech)
  final Color softBlue;
  final Color lavender;
  final Color gradientStart;
  final Color gradientEnd;

  // Wardrobe (Daily & Natural)
  final Color woodBrown;
  final Color camel;
  final Color oliveGreen;
  final Color matteGray;

  const AppColorsExtension({
    required this.fashionBlack,
    required this.offWhite,
    required this.beige,
    required this.editorialGray,
    required this.burgundy,
    required this.softBlue,
    required this.lavender,
    required this.gradientStart,
    required this.gradientEnd,
    required this.woodBrown,
    required this.camel,
    required this.oliveGreen,
    required this.matteGray,
  });

  @override
  AppColorsExtension copyWith({
    Color? fashionBlack,
    Color? offWhite,
    Color? beige,
    Color? editorialGray,
    Color? burgundy,
    Color? softBlue,
    Color? lavender,
    Color? gradientStart,
    Color? gradientEnd,
    Color? woodBrown,
    Color? camel,
    Color? oliveGreen,
    Color? matteGray,
  }) {
    return AppColorsExtension(
      fashionBlack: fashionBlack ?? this.fashionBlack,
      offWhite: offWhite ?? this.offWhite,
      beige: beige ?? this.beige,
      editorialGray: editorialGray ?? this.editorialGray,
      burgundy: burgundy ?? this.burgundy,
      softBlue: softBlue ?? this.softBlue,
      lavender: lavender ?? this.lavender,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      woodBrown: woodBrown ?? this.woodBrown,
      camel: camel ?? this.camel,
      oliveGreen: oliveGreen ?? this.oliveGreen,
      matteGray: matteGray ?? this.matteGray,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      fashionBlack: Color.lerp(fashionBlack, other.fashionBlack, t)!,
      offWhite: Color.lerp(offWhite, other.offWhite, t)!,
      beige: Color.lerp(beige, other.beige, t)!,
      editorialGray: Color.lerp(editorialGray, other.editorialGray, t)!,
      burgundy: Color.lerp(burgundy, other.burgundy, t)!,
      softBlue: Color.lerp(softBlue, other.softBlue, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      woodBrown: Color.lerp(woodBrown, other.woodBrown, t)!,
      camel: Color.lerp(camel, other.camel, t)!,
      oliveGreen: Color.lerp(oliveGreen, other.oliveGreen, t)!,
      matteGray: Color.lerp(matteGray, other.matteGray, t)!,
    );
  }

  // Define static instances for easy usage in theme registration
  static const light = AppColorsExtension(
    fashionBlack: Color(0xFF000000),
    offWhite: Color(0xFFFAF9F6),
    beige: Color(0xFFD2B48C),
    editorialGray: Color(0xFFA9A9A9),
    burgundy: Color(0xFF4E0707),
    softBlue: Color(0xFF4682B4),
    lavender: Color(0xFF967BB6),
    gradientStart: Color(0xFF4682B4),
    gradientEnd: Color(0xFF967BB6),
    woodBrown: Color(0xFF6F4E37),
    camel: Color(0xFFC19A6B),
    oliveGreen: Color(0xFF556B2F),
    matteGray: Color(0xFF708090),
  );

  static const dark = AppColorsExtension(
    fashionBlack: Color(0xFFE0E0E0), // Adjusted for dark mode text
    offWhite: Color(0xFF1E1E1E), // Dark background
    beige: Color(0xFFD2B48C),
    editorialGray: Color(0xFF808080),
    burgundy: Color(0xFFFF80AB), // Pink accent for burgundy in dark
    softBlue: Color(0xFF90CAF9), // Lighter blue
    lavender: Color(0xFFB39DDB), // Lighter lavender
    gradientStart: Color(0xFF4682B4),
    gradientEnd: Color(0xFF967BB6),
    woodBrown: Color(0xFFA1887F),
    camel: Color(0xFFD7CCC8),
    oliveGreen: Color(0xFFAED581),
    matteGray: Color(0xFFB0BEC5),
  );
}

// Extension on BuildContext for easy access
extension AppThemeContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light;
}
