import 'package:flutter/material.dart';

abstract final class SorgvryColors {
  static const primary = Color(0xFF5BA8A0);
  static const cardDone = Color(0xFF27AE60);
  static const cardPending = Color(0xFF95A5A6);
  static const waterPending = Color(0xFFEBF5FB);
  static const cardLate = Color(0xFFE67E22);
  static const cardAlert = Color(0xFFE07A5F);
  static const background = Color(0xFFF5F2EA);
  static const surface = Color(0xFFFFFFFF);
}

/// Shared app bar logo used across all screens.
class SorgvryLogo extends StatelessWidget {
  final double height;
  const SorgvryLogo({super.key, this.height = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo_with_title.png',
      height: height,
      semanticLabel: 'Sorgvry',
    );
  }
}

abstract final class SorgvrySpacing {
  static const cardPadding = 24.0;
  static const buttonHeight = 72.0;
  static const gridGap = 12.0;
  static const cardRadius = 16.0;
  static const buttonRadius = 12.0;
}

final sorgvryTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: SorgvryColors.primary,
    primary: SorgvryColors.primary,
    onPrimary: Colors.white,
    surface: SorgvryColors.surface,
  ),
  scaffoldBackgroundColor: SorgvryColors.background,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 18),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SorgvrySpacing.cardRadius),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: SorgvryColors.background,
    surfaceTintColor: Colors.transparent,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(SorgvrySpacing.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SorgvrySpacing.buttonRadius),
      ),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
);
