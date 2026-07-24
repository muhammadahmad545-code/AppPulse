/// Central route path constants.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String permissions = '/permissions';
  static const String permissionsSetup = '/permissions?setup=1';
  static const String dashboard = '/dashboard';
  static const String apps = '/apps';
  static const String appDetails = '/apps/:packageName';
  static const String timeline = '/timeline';
  static const String analytics = '/analytics';
  static const String reports = '/reports';
  static const String focus = '/focus';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String limits = '/limits';

  static String appDetailsPath(String packageName) =>
      '/apps/${Uri.encodeComponent(packageName)}';
}
