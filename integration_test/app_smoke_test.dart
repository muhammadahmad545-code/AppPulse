import 'package:app_pulse/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Smoke placeholder — expand with device-bound flows as needed.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppPulse constants are configured', (tester) async {
    expect(AppConstants.appName, 'AppPulse');
    expect(AppConstants.tagline.isNotEmpty, isTrue);
  });
}
