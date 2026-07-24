/// Formatting helpers for screen-time durations.
extension DurationFormatting on Duration {
  /// Compact human-readable form, e.g. `2h 15m`, `45m`, `12s`.
  String get compactLabel {
    if (inSeconds < 60) return '${inSeconds}s';
    if (inMinutes < 60) {
      final seconds = inSeconds % 60;
      if (seconds == 0) return '${inMinutes}m';
      return '${inMinutes}m ${seconds}s';
    }
    final hours = inHours;
    final minutes = inMinutes % 60;
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  /// Longer label for detail screens, e.g. `2 hours 15 minutes`.
  String get longLabel {
    if (inSeconds < 60) {
      return inSeconds == 1 ? '1 second' : '$inSeconds seconds';
    }
    if (inMinutes < 60) {
      return inMinutes == 1 ? '1 minute' : '$inMinutes minutes';
    }
    final hours = inHours;
    final minutes = inMinutes % 60;
    final hourPart = hours == 1 ? '1 hour' : '$hours hours';
    if (minutes == 0) return hourPart;
    final minutePart = minutes == 1 ? '1 minute' : '$minutes minutes';
    return '$hourPart $minutePart';
  }

  int get totalMilliseconds => inMilliseconds;
}
