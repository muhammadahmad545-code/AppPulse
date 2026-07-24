import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:app_pulse/core/logging/app_logger.dart';
import 'package:app_pulse/database/app_database.dart';
import 'package:app_pulse/services/limits/limit_models.dart';
import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local notifications with optional Drift history logging.
final class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    AppDatabase? database,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _database = database;

  final FlutterLocalNotificationsPlugin _plugin;
  AppDatabase? _database;
  bool _initialized = false;

  void attachDatabase(AppDatabase database) {
    _database = database;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);

    try {
      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (_) {},
      );
      await _createChannels();
      AppLogger.i('NotificationService initialized');
    } catch (error, stack) {
      // Unit tests / non-Android hosts may lack a notifications plugin.
      AppLogger.w('NotificationService initialize skipped', error, stack);
    }
    _initialized = true;
  }

  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.notificationChannelTracking,
        'Usage tracking',
        description: 'Persistent status while AppPulse is tracking screen time',
        importance: Importance.low,
        playSound: false,
        showBadge: false,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.notificationChannelLimits,
        'App limits',
        description: 'Alerts when an app is near or over its time limit',
        importance: Importance.high,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.notificationChannelFocus,
        'Focus mode',
        description: 'Focus session timers and reminders',
        importance: Importance.defaultImportance,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.notificationChannelGeneral,
        'General',
        description: 'General AppPulse notifications',
        importance: Importance.defaultImportance,
      ),
    );
  }

  Future<void> showSilent({
    required int id,
    required String title,
    required String body,
    String channelId = AppConstants.notificationChannelGeneral,
    String category = 'general',
    String? packageName,
  }) async {
    await _show(
      id: id,
      title: title,
      body: body,
      channelId: channelId,
      importance: Importance.low,
      priority: Priority.low,
      silent: true,
      category: category,
      packageName: packageName,
    );
  }

  Future<void> showLimitAlert(
    LimitAlert alert, {
    bool fullScreen = false,
    bool silent = false,
  }) async {
    await _show(
      id: 4000 + alert.limitId * 10 + alert.kind.index,
      title: alert.title,
      body: alert.body,
      channelId: AppConstants.notificationChannelLimits,
      importance: fullScreen ? Importance.max : Importance.high,
      priority: fullScreen ? Priority.max : Priority.high,
      silent: silent,
      fullScreenIntent: fullScreen,
      category: 'limit',
      packageName: alert.packageName,
      actions: fullScreen || alert.action == LimitAction.confirm
          ? [
              const AndroidNotificationAction(
                'ack',
                'Got it',
                showsUserInterface: true,
              ),
            ]
          : null,
    );
  }

  Future<void> showFocusAlert({
    required String title,
    required String body,
    int id = 5001,
  }) async {
    await _show(
      id: id,
      title: title,
      body: body,
      channelId: AppConstants.notificationChannelFocus,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      category: 'focus',
    );
  }

  Future<void> _show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required Importance importance,
    required Priority priority,
    required String category,
    bool silent = false,
    bool fullScreenIntent = false,
    String? packageName,
    List<AndroidNotificationAction>? actions,
  }) async {
    await initialize();
    try {
      await _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId,
            channelDescription: channelId,
            importance: importance,
            priority: priority,
            playSound: !silent,
            silent: silent,
            fullScreenIntent: fullScreenIntent,
            category: AndroidNotificationCategory.reminder,
            actions: actions,
          ),
        ),
      );
    } catch (error) {
      AppLogger.w('Notification show skipped: $error');
    }

    final db = _database;
    if (db != null) {
      await db.notificationsDao.insert(
        NotificationHistoryCompanion.insert(
          title: title,
          body: body,
          category: category,
          packageName: Value(packageName),
        ),
      );
    }
  }
}
