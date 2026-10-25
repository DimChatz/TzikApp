import 'package:flutter/material.dart';

/// Colours of the logo.
const brandNavy = Color(0xFF0B2A5E);
const brandGreen = Color(0xFFB9F5D0);
const brandBlue = Color(0xFFAEDCFA);

/// Background of the logo, splash and home screens. Fixed (not
/// theme-dependent) so they match the app icon in light and dark mode.
const brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [brandGreen, brandBlue],
);

ThemeData buildTheme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: brandNavy,
    brightness: brightness,
    // Keeps the primary colour close to the logo's navy.
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  ),
);
