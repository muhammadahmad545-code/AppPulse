import 'package:app_pulse/core/extensions/datetime_extensions.dart';
import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/shared/widgets/app_icon_avatar.dart';
import 'package:flutter/material.dart';

/// Chronological session row for timeline and app details.
class SessionTimelineTile extends StatelessWidget {
  const SessionTimelineTile({
    required this.appName,
    required this.packageName,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    this.iconCacheKey,
    this.isOngoing = false,
    this.use24h = false,
    this.onTap,
    super.key,
  });

  final String appName;
  final String packageName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Duration duration;
  final String? iconCacheKey;
  final bool isOngoing;
  final bool use24h;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final closedLabel = endedAt == null
        ? (isOngoing ? 'Now' : '—')
        : endedAt!.formatTime(use24h: use24h);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIconAvatar(
                packageName: packageName,
                cacheKey: iconCacheKey,
                size: 48,
                hero: false,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appName, style: textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _MetaRow(
                      label: 'Opened',
                      value: startedAt.formatTime(use24h: use24h),
                    ),
                    const SizedBox(height: 4),
                    _MetaRow(label: 'Closed', value: closedLabel),
                    const SizedBox(height: 4),
                    _MetaRow(
                      label: 'Duration',
                      value: isOngoing
                          ? '${duration.compactLabel} (ongoing)'
                          : duration.longLabel,
                      emphasize: true,
                    ),
                  ],
                ),
              ),
              if (isOngoing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Live',
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onTertiaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: emphasize
                ? textTheme.titleSmall?.copyWith(color: scheme.primary)
                : textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
