import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Compact Lottie accent for empty / waiting states.
class LottieEmptyAccent extends StatelessWidget {
  const LottieEmptyAccent({super.key, this.size = 140});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/lottie/pulse_empty.json',
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.graphic_eq_rounded,
          size: size * 0.45,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
