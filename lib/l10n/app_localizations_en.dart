// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AppPulse';

  @override
  String get tagline => 'Know Where Your Time Goes.';

  @override
  String get navHome => 'Home';

  @override
  String get navApps => 'Apps';

  @override
  String get navTimeline => 'Timeline';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navSettings => 'Settings';
}
