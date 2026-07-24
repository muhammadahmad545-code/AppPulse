import 'dart:convert';
import 'dart:io';

import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/infrastructure/platform/usage_stats_platform.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Checks GitHub Releases for a newer APK and installs it on request.
///
/// Network is used only for this optional update path.
final class AppUpdateService {
  AppUpdateService({
    http.Client? client,
    UsageStatsPlatform? platform,
  })  : _client = client ?? http.Client(),
        _platform = platform ?? UsageStatsPlatform();

  final http.Client _client;
  final UsageStatsPlatform _platform;

  Future<AppUpdateInfo?> checkForUpdate() async {
    if (!_platform.isAndroid) return null;
    try {
      final info = await PackageInfo.fromPlatform();
      final localCode = int.tryParse(info.buildNumber) ?? 0;

      final response = await _client.get(
        Uri.parse(AppConstants.githubReleasesApi),
        headers: const {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'AppPulse-Updater',
        },
      );
      if (response.statusCode != 200) {
        AppLogger.w('Update check HTTP ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tag = '${json['tag_name'] ?? ''}';
      final body = '${json['body'] ?? ''}';
      final assets = (json['assets'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();

      var remoteCode = _parseVersionCode(tag, body);
      String? apkUrl;
      for (final asset in assets) {
        final name = '${asset['name'] ?? ''}';
        final url = '${asset['browser_download_url'] ?? ''}';
        if (name == 'version.json' && url.isNotEmpty) {
          final versionRes = await _client.get(Uri.parse(url));
          if (versionRes.statusCode == 200) {
            final versionJson =
                jsonDecode(versionRes.body) as Map<String, dynamic>;
            remoteCode = (versionJson['versionCode'] as num?)?.toInt() ??
                remoteCode;
          }
        }
        if (name == 'AppPulse.apk' && url.isNotEmpty) {
          apkUrl = url;
        } else if (name.endsWith('.apk') && url.isNotEmpty && apkUrl == null) {
          apkUrl = url;
        }
      }

      if (apkUrl == null || remoteCode <= localCode) return null;

      return AppUpdateInfo(
        localVersionCode: localCode,
        localVersionName: info.version,
        remoteVersionCode: remoteCode,
        remoteVersionName: tag.replaceFirst(RegExp(r'^v'), ''),
        apkUrl: apkUrl,
        releaseNotes: body.trim(),
      );
    } catch (error, stack) {
      AppLogger.w('Update check failed', error, stack);
      return null;
    }
  }

  Future<File> downloadApk(
    AppUpdateInfo update, {
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(update.apkUrl));
    final streamed = await _client.send(request);
    if (streamed.statusCode != 200) {
      throw StateError('Download failed (${streamed.statusCode})');
    }

    final total = streamed.contentLength ?? 0;
    var received = 0;
    final dir = await getTemporaryDirectory();
    final file = File(
      p.join(dir.path, 'AppPulse-${update.remoteVersionCode}.apk'),
    );
    final sink = file.openWrite();
    await for (final chunk in streamed.stream) {
      received += chunk.length;
      sink.add(chunk);
      if (total > 0) {
        onProgress?.call(received / total);
      }
    }
    await sink.close();
    AppLogger.i('Downloaded update to ${file.path}');
    return file;
  }

  Future<void> installApk(File file) {
    return _platform.installApk(file.path);
  }

  int _parseVersionCode(String tag, String body) {
    final plus = RegExp(r'\+(\d+)').firstMatch(tag);
    if (plus != null) return int.parse(plus.group(1)!);
    final codeLine = RegExp(r'versionCode\s*[:=]\s*(\d+)', caseSensitive: false)
        .firstMatch(body);
    if (codeLine != null) return int.parse(codeLine.group(1)!);
    final digits = RegExp(r'(\d+)$').firstMatch(tag.replaceAll('.', ''));
    if (digits != null) return int.parse(digits.group(1)!);
    return 0;
  }
}

final class AppUpdateInfo extends Equatable {
  const AppUpdateInfo({
    required this.localVersionCode,
    required this.localVersionName,
    required this.remoteVersionCode,
    required this.remoteVersionName,
    required this.apkUrl,
    required this.releaseNotes,
  });

  final int localVersionCode;
  final String localVersionName;
  final int remoteVersionCode;
  final String remoteVersionName;
  final String apkUrl;
  final String releaseNotes;

  @override
  List<Object?> get props => [remoteVersionCode, apkUrl];
}
