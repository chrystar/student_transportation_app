import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color dividerColor;
  final Color cardBackgroundColor;
  final Color shadowColor;
  final Color successColor;
  final Color errorColor;
  final Color warningColor;
  final Color infoColor;

  const AppThemeExtension({
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.dividerColor,
    required this.cardBackgroundColor,
    required this.shadowColor,
    required this.successColor,
    required this.errorColor,
    required this.warningColor,
    required this.infoColor,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? dividerColor,
    Color? cardBackgroundColor,
    Color? shadowColor,
    Color? successColor,
    Color? errorColor,
    Color? warningColor,
    Color? infoColor,
  }) {
    return AppThemeExtension(
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      dividerColor: dividerColor ?? this.dividerColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return AppThemeExtension(
      primaryTextColor:
          Color.lerp(primaryTextColor, other.primaryTextColor, t)!,
      secondaryTextColor:
          Color.lerp(secondaryTextColor, other.secondaryTextColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      cardBackgroundColor:
          Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
    );
  }

  static const light = AppThemeExtension(
    primaryTextColor: Color(0xFF1A1A1A),
    secondaryTextColor: Color(0xFF757575),
    dividerColor: Color(0xFFE0E0E0),
    cardBackgroundColor: Colors.white,
    shadowColor: Color(0x1A000000),
    successColor: Color(0xFF4CAF50),
    errorColor: Color(0xFFF44336),
    warningColor: Color(0xFFFF9800),
    infoColor: Color(0xFF2196F3),
  );

  static const dark = AppThemeExtension(
    primaryTextColor: Color(0xFFFFFFFF),
    secondaryTextColor: Color(0xFFB3B3B3),
    dividerColor: Color(0xFF424242),
    cardBackgroundColor: Color(0xFF2C2C2C),
    shadowColor: Color(0x3D000000),
    successColor: Color(0xFF81C784),
    errorColor: Color(0xFFE57373),
    warningColor: Color(0xFFFFB74D),
    infoColor: Color(0xFF64B5F6),
  );
}
