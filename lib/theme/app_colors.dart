import 'package:flutter/material.dart';

/// Brand palette used when Material You / dynamic color is unavailable.
///
/// Direction: cool slate surfaces with teal pulse accents — distinct from
/// generic purple/indigo AI themes and warm cream/serif looks.
abstract final class AppColors {
  static const Color seed = Color(0xFF0D9488);

  static const Color lightSurface = Color(0xFFF4F7F8);
  static const Color lightSurfaceContainer = Color(0xFFE8EEF0);
  static const Color darkSurface = Color(0xFF0B1214);
  static const Color darkSurfaceContainer = Color(0xFF152025);

  static const Color pulseTeal = Color(0xFF14B8A6);
  static const Color pulseCoral = Color(0xFFF97366);
  static const Color pulseAmber = Color(0xFFFBBF24);
  static const Color pulseSky = Color(0xFF38BDF8);

  static const List<Color> chartPalette = [
    Color(0xFF14B8A6),
    Color(0xFF38BDF8),
    Color(0xFFF97366),
    Color(0xFFFBBF24),
    Color(0xFFA78BFA),
    Color(0xFF34D399),
    Color(0xFFFB7185),
    Color(0xFF60A5FA),
  ];
}
