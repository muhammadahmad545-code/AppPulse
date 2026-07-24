import 'package:app_pulse/infrastructure/di/providers.dart';
import 'package:app_pulse/services/updates/app_update_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService(platform: ref.watch(usageStatsPlatformProvider));
});

/// Checks GitHub Releases and offers an in-app APK update.
Future<void> checkAndPromptForAppUpdate(
  BuildContext context,
  WidgetRef ref, {
  bool silentIfNone = true,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (!silentIfNone) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Checking for updates…')),
    );
  }

  final service = ref.read(appUpdateServiceProvider);
  final update = await service.checkForUpdate();
  if (!context.mounted) return;

  if (update == null) {
    if (!silentIfNone) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('You are on the latest version')),
      );
    }
    return;
  }

  final shouldUpdate = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Update available'),
      content: Text(
        'Version ${update.remoteVersionName} '
        '(build ${update.remoteVersionCode}) is ready.\n'
        'Installed: ${update.localVersionName} '
        '(build ${update.localVersionCode}).\n\n'
        'Tap Update to download and install. '
        'Allow “install unknown apps” for AppPulse if Android asks.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Update'),
        ),
      ],
    ),
  );

  if (shouldUpdate != true || !context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _DownloadUpdateDialog(
        service: service,
        update: update,
        onDone: () => Navigator.of(dialogContext).pop(),
      );
    },
  );
}

class _DownloadUpdateDialog extends StatefulWidget {
  const _DownloadUpdateDialog({
    required this.service,
    required this.update,
    required this.onDone,
  });

  final AppUpdateService service;
  final AppUpdateInfo update;
  final VoidCallback onDone;

  @override
  State<_DownloadUpdateDialog> createState() => _DownloadUpdateDialogState();
}

class _DownloadUpdateDialogState extends State<_DownloadUpdateDialog> {
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final file = await widget.service.downloadApk(
        widget.update,
        onProgress: (value) {
          if (mounted) setState(() => _progress = value);
        },
      );
      await widget.service.installApk(file);
      if (mounted) widget.onDone();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_error == null ? 'Downloading update' : 'Update failed'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error == null) ...[
            LinearProgressIndicator(value: _progress <= 0 ? null : _progress),
            const SizedBox(height: 12),
            Text('${(_progress * 100).clamp(0, 100).toStringAsFixed(0)}%'),
          ] else
            Text(_error!),
        ],
      ),
      actions: [
        if (_error != null)
          TextButton(
            onPressed: widget.onDone,
            child: const Text('Close'),
          ),
      ],
    );
  }
}
