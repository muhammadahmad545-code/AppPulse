import 'dart:io';

import 'package:flutter/material.dart';

/// Cached on-disk app icon with Hero support and Material fallback.
class AppIconAvatar extends StatelessWidget {
  const AppIconAvatar({
    required this.packageName,
    this.cacheKey,
    this.size = 40,
    this.hero = true,
    super.key,
  });

  final String packageName;
  final String? cacheKey;
  final double size;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget child = ColoredBox(
      color: scheme.primaryContainer,
      child: Icon(
        Icons.android_rounded,
        color: scheme.onPrimaryContainer,
        size: size * 0.55,
      ),
    );

    if (cacheKey != null && File(cacheKey!).existsSync()) {
      child = Image.file(
        File(cacheKey!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => child,
      );
    }

    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: SizedBox(width: size, height: size, child: child),
    );

    if (!hero) return clipped;
    return Hero(tag: 'app-icon-$packageName', child: clipped);
  }
}
