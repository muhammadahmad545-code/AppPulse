import 'package:app_pulse/ui/widgets.dart';
import 'package:basalt/basalt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HourlyChart renders 24 hours and its axis', (tester) async {
    final semantics = tester.ensureSemantics();
    final hours = List.generate(24, (h) => Duration(minutes: h == 14 ? 40 : h % 3));
    await tester.pumpWidget(
      MaterialApp(
        theme: basaltTheme(Brightness.light, BasaltAccent.sky),
        home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: HourlyChart(hours: hours))),
      ),
    );
    expect(find.text('12 PM'), findsOneWidget);
    expect(find.bySemanticsLabel('Busiest hour 2 PM'), findsOneWidget);
    semantics.dispose();
  });
}
