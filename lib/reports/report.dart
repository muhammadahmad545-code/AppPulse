import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/format.dart';
import '../data/models.dart';
import '../data/repo.dart';

class ReportApp {
  const ReportApp({required this.package, required this.name, required this.category, required this.time, required this.opens});

  final String package;
  final String name;
  final String category;
  final Duration time;
  final int opens;
}

class UsageReport {
  const UsageReport({
    required this.title,
    required this.from,
    required this.to,
    required this.total,
    required this.dailyAverage,
    required this.days,
    required this.apps,
    required this.unlocks,
    required this.focusSessions,
    required this.focusTime,
    required this.created,
  });

  final String title;

  /// Period [from, to): [to] is the midnight after the last day.
  final DateTime from;
  final DateTime to;
  final Duration total;
  final Duration dailyAverage;
  final List<(DateTime, Duration)> days;
  final List<ReportApp> apps;
  final int unlocks;
  final int focusSessions;
  final Duration focusTime;
  final DateTime created;

  DateTime get lastDay => addDays(to, -1);

  String get period => '${DateFormat('d MMM yyyy').format(from)} - ${DateFormat('d MMM yyyy').format(lastDay)}';
}

UsageReport buildReport({required String title, required RangeUsage range, required Map<String, AppInfo> apps, DateTime? created}) {
  final opens = range.opens();
  return UsageReport(
    title: title,
    from: range.from,
    to: range.to,
    total: range.total,
    dailyAverage: range.dailyAverage,
    days: [for (final d in range.days) (d, range.perDay[dayKey(d)] ?? Duration.zero)],
    apps: [
      for (final e in range.totals)
        ReportApp(
          package: e.key,
          name: (apps[e.key] ?? AppInfo.fallback(e.key)).name,
          category: (apps[e.key] ?? AppInfo.fallback(e.key)).categoryLabel,
          time: e.value,
          opens: opens[e.key] ?? 0,
        ),
    ],
    unlocks: range.unlocks.values.fold(0, (a, b) => a + b),
    focusSessions: range.focus.where((f) => f.status == FocusStatus.completed).length,
    focusTime: range.focus.fold(Duration.zero, (a, f) => a + f.actual),
    created: created ?? DateTime.now(),
  );
}

String _csvField(String v) {
  if (v.contains(',') || v.contains('"') || v.contains('\n')) return '"${v.replaceAll('"', '""')}"';
  return v;
}

String _minutes(Duration d) => (d.inSeconds / 60).toStringAsFixed(1);

/// Spreadsheet-friendly CSV: a short summary, then one row per app, then one row per day.
String reportCsv(UsageReport r) {
  final b = StringBuffer();
  void row(List<Object> cells) => b.writeln(cells.map((c) => _csvField(c.toString())).join(','));
  row(['Clocked report', r.title]);
  row(['Period', dayKey(r.from), dayKey(r.lastDay)]);
  row(['Total minutes', _minutes(r.total)]);
  row(['Daily average minutes', _minutes(r.dailyAverage)]);
  row(['Unlocks', r.unlocks]);
  row(['Focus sessions completed', r.focusSessions]);
  b.writeln();
  row(['App', 'Package', 'Category', 'Minutes', 'Opens']);
  for (final a in r.apps) {
    row([a.name, a.package, a.category, _minutes(a.time), a.opens]);
  }
  b.writeln();
  row(['Day', 'Minutes']);
  for (final (day, time) in r.days) {
    row([dayKey(day), _minutes(time)]);
  }
  return b.toString();
}

/// The built-in PDF fonts only cover Latin-1; replace anything else so names never break the file.
String _latin1(String s) => String.fromCharCodes(s.runes.map((r) => r <= 0xFF ? r : 0x3F));

Future<Uint8List> reportPdf(UsageReport r) {
  final doc = pw.Document(title: 'Clocked report', author: 'Clocked');
  final accent = PdfColor.fromInt(0xFF0369A1);
  final muted = PdfColor.fromInt(0xFF5A606C);
  final line = PdfColor.fromInt(0xFFE3E5E9);
  pw.Widget stat(String label, String value) => pw.Expanded(
        child: pw.Container(
          margin: const pw.EdgeInsets.only(right: 8),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: line), borderRadius: pw.BorderRadius.circular(6)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: pw.TextStyle(fontSize: 9, color: muted)),
              pw.SizedBox(height: 4),
              pw.Text(value, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );
  pw.TableRow tableRow(List<String> cells, {bool header = false}) => pw.TableRow(
        decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: line, width: 0.5))),
        children: [
          for (var i = 0; i < cells.length; i++)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
              child: pw.Text(
                _latin1(cells[i]),
                textAlign: i == 0 ? pw.TextAlign.left : pw.TextAlign.right,
                style: pw.TextStyle(fontSize: 10, fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal, color: header ? muted : null),
              ),
            ),
        ],
      );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => [
        pw.Text('Clocked report', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: accent)),
        pw.SizedBox(height: 4),
        pw.Text(_latin1('${r.title}  |  ${r.period}'), style: pw.TextStyle(fontSize: 11, color: muted)),
        pw.SizedBox(height: 18),
        pw.Row(
          children: [
            stat('Screen time', fmtDuration(r.total)),
            stat('Daily average', fmtDuration(r.dailyAverage)),
            stat('Unlocks', '${r.unlocks}'),
            stat('Focus sessions', '${r.focusSessions}'),
          ],
        ),
        pw.SizedBox(height: 22),
        pw.Text('Apps', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        if (r.apps.isEmpty)
          pw.Text('No app usage in this period.', style: pw.TextStyle(fontSize: 10, color: muted))
        else
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1.2),
              3: pw.FlexColumnWidth(1),
            },
            children: [
              tableRow(['App', 'Category', 'Time', 'Opens'], header: true),
              for (final a in r.apps.take(60)) tableRow([a.name, a.category, fmtDuration(a.time), '${a.opens}']),
            ],
          ),
        pw.SizedBox(height: 22),
        pw.Text('Days', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Table(
          columnWidths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(1)},
          children: [
            tableRow(['Day', 'Screen time'], header: true),
            for (final (day, time) in r.days) tableRow([DateFormat('EEE d MMM').format(day), fmtDuration(time)]),
          ],
        ),
        pw.SizedBox(height: 18),
        pw.Text(
          'Created ${DateFormat('d MMM yyyy, HH:mm').format(r.created)} by Clocked. Data from Android usage records on this phone.',
          style: pw.TextStyle(fontSize: 8, color: muted),
        ),
      ],
    ),
  );
  return doc.save();
}
