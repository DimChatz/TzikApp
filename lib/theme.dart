import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Colours of the logo.
const brandNavy = Color(0xFF0B2A5E);
const brandGreen = Color(0xFFB9F5D0);
const brandBlue = Color(0xFFAEDCFA);

/// Background of every screen. Fixed (not theme-dependent) so the app
/// matches the app icon in light and dark mode.
const brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [brandGreen, brandBlue],
);

/// Navy text and controls, made to sit on [brandGradient].
ThemeData buildTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: brandNavy,
        // Keeps the primary colour close to the logo's navy.
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      ).copyWith(
        primary: brandNavy,
        onSurface: brandNavy,
        onSurfaceVariant: brandNavy.withValues(alpha: 0.7),
        outline: brandNavy.withValues(alpha: 0.5),
      );
  final base = ThemeData(colorScheme: colorScheme);

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: brandNavy,
      displayColor: brandNavy,
    ),
    iconTheme: const IconThemeData(color: brandNavy),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: brandNavy,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.6),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.5),
    ),
    // For pop-ups that don't use BrandDialog.
    dialogTheme: const DialogThemeData(
      backgroundColor: brandGreen,
      titleTextStyle: TextStyle(
        color: brandNavy,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(color: brandNavy, fontSize: 16),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: brandNavy,
      contentTextStyle: TextStyle(color: Colors.white),
      actionTextColor: brandGreen,
      behavior: SnackBarBehavior.floating,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brandNavy,
        side: BorderSide(color: brandNavy.withValues(alpha: 0.35)),
      ),
    ),
  );
}
