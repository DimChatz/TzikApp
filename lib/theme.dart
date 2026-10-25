import 'package:flutter/material.dart';

const brandSeed = Color(0xFF5B3CC4);

/// Background of the splash and home screens. Fixed (not theme-dependent) so
/// white text stays readable in both light and dark mode.
const brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF4527A0), Color(0xFFAD1457)],
);

ThemeData buildTheme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: brandSeed,
    brightness: brightness,
  ),
);
