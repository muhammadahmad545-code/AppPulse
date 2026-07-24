import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography built on Space Grotesk (display) + DM Sans (body).
abstract final class AppTypography {
  static TextTheme textTheme(ColorScheme scheme) {
    final display = GoogleFonts.spaceGroteskTextTheme();
    final body = GoogleFonts.dmSansTextTheme();

    return body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: scheme.onSurface,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: scheme.onSurface,
      ),
      displaySmall: display.displaySmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: scheme.onSurface,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: scheme.onSurface,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: display.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: body.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: body.bodyLarge?.copyWith(color: scheme.onSurface),
      bodyMedium: body.bodyMedium?.copyWith(color: scheme.onSurface),
      bodySmall: body.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: body.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: body.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: body.labelSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
