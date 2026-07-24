import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_pulse/core/extensions/duration_extensions.dart';
import 'package:app_pulse/features/reports/domain/usage_report.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Serializes [UsageReport] to files and shares via the system sheet.
final class ReportExporter {
  Future<File> export(UsageReport report, ReportExportFormat format) async {
    final bytes = switch (format) {
      ReportExportFormat.csv => Uint8List.fromList(utf8.encode(_toCsv(report))),
      ReportExportFormat.json =>
        Uint8List.fromList(utf8.encode(_toJson(report))),
      ReportExportFormat.pdf => await _toPdf(report),
    };

    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(report.generatedAt);
    final extension = switch (format) {
      ReportExportFormat.csv => 'csv',
      ReportExportFormat.json => 'json',
      ReportExportFormat.pdf => 'pdf',
    };
    final file = File(
      p.join(dir.path, 'apppulse_${report.period.name}_$stamp.$extension'),
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<void> exportAndShare(
    UsageReport report,
    ReportExportFormat format,
  ) async {
    final file = await export(report, format);
    final mime = switch (format) {
      ReportExportFormat.csv => 'text/csv',
      ReportExportFormat.json => 'application/json',
      ReportExportFormat.pdf => 'application/pdf',
    };
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mime, name: p.basename(file.path))],
        subject: report.title,
        text: 'AppPulse offline usage report',
      ),
    );
  }

  String _toCsv(UsageReport report) {
    final rows = <List<dynamic>>[
      ['AppPulse Usage Report'],
      ['Title', report.title],
      ['Generated', report.generatedAt.toIso8601String()],
      ['Range start', report.rangeStart.toIso8601String()],
      ['Range end', report.rangeEnd.toIso8601String()],
      ['Total ms', report.totalDurationMs],
      ['Sessions', report.sessionCount],
      ['Launches', report.launchCount],
      [],
      ['App', 'Package', 'Category', 'Duration ms', 'Launches'],
      for (final app in report.appRows)
        [
          app.appName,
          app.packageName,
          app.category,
          app.durationMs,
          app.launchCount,
        ],
      [],
      ['Category', 'Duration ms', 'Percent'],
      for (final category in report.categoryRows)
        [category.category, category.durationMs, category.percent],
    ];
    return Csv().encode(rows);
  }

  String _toJson(UsageReport report) {
    return const JsonEncoder.withIndent('  ').convert(report.toJson());
  }

  Future<Uint8List> _toPdf(UsageReport report) async {
    final doc = pw.Document();
    final dateFmt = DateFormat('MMM d, y HH:mm');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            'AppPulse',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            report.title,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Generated ${dateFmt.format(report.generatedAt)}'),
          pw.Text(
            'Range ${dateFmt.format(report.rangeStart)} – '
            '${dateFmt.format(report.rangeEnd)}',
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Summary',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Bullet(
            text:
                'Total screen time: ${Duration(milliseconds: report.totalDurationMs).compactLabel}',
          ),
          pw.Bullet(text: 'Sessions: ${report.sessionCount}'),
          pw.Bullet(text: 'Launches: ${report.launchCount}'),
          pw.Bullet(
            text:
                'Average session: ${Duration(milliseconds: report.averageSessionMs).compactLabel}',
          ),
          pw.Bullet(
            text:
                'Longest session: ${Duration(milliseconds: report.longestSessionMs).compactLabel}',
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Top apps',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['App', 'Category', 'Time', 'Launches'],
            data: [
              for (final app in report.appRows.take(25))
                [
                  app.appName,
                  app.category,
                  Duration(milliseconds: app.durationMs).compactLabel,
                  '${app.launchCount}',
                ],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFE8EEF0),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Categories',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['Category', 'Time', '%'],
            data: [
              for (final category in report.categoryRows)
                [
                  category.category,
                  Duration(milliseconds: category.durationMs).compactLabel,
                  '${category.percent.toStringAsFixed(1)}%',
                ],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFE8EEF0),
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Generated offline by AppPulse. No data left this device until you shared this file.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    return doc.save();
  }
}
