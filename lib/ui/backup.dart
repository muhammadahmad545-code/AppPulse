import 'dart:convert';
import 'dart:typed_data';

import 'package:basalt/basalt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/format.dart';
import '../data/backup.dart';
import '../state.dart';

/// The choice made in the password dialog: null when cancelled, an empty password for none.
typedef _Choice = ({String password})?;

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.create, this.error});

  /// true: choosing a password for a new backup (optional, asked twice). false: opening one.
  final bool create;
  final String? error;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  String? _problem;

  @override
  void initState() {
    super.initState();
    _problem = widget.error;
  }

  @override
  void dispose() {
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  void _submit() {
    final p = _password.text;
    if (!widget.create) {
      if (p.isEmpty) return setState(() => _problem = 'Enter the backup\'s password.');
      Navigator.pop<_Choice>(context, (password: p));
      return;
    }
    if (p.isEmpty) return Navigator.pop<_Choice>(context, (password: ''));
    if (p.length < ClockedBackup.minPasswordLength) {
      return setState(() => _problem = 'Use at least ${ClockedBackup.minPasswordLength} characters, or leave both fields empty.');
    }
    if (p != _repeat.text) return setState(() => _problem = 'The two passwords do not match.');
    Navigator.pop<_Choice>(context, (password: p));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.basalt;
    return AlertDialog(
      title: Text(widget.create ? 'Protect this backup?' : 'Backup password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.create
                  ? 'The backup shows which apps you used and when. Add a password if you will keep it somewhere shared, '
                      'like Drive or email. A forgotten password cannot be recovered.'
                  : 'This backup is protected. Enter the password you chose when you made it.',
              style: TextStyle(color: p.textMuted),
            ),
            // Above the fields, so the keyboard never hides it.
            if (_problem != null) ...[
              const SizedBox(height: Gap.sm),
              Text(_problem!, style: TextStyle(color: p.danger, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: Gap.md),
            TextField(
              controller: _password,
              autofocus: !widget.create,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (_) => setState(() => _problem = null),
              onSubmitted: widget.create ? null : (_) => _submit(),
              decoration: InputDecoration(labelText: 'Password', hintText: widget.create ? 'Optional' : null),
            ),
            if (widget.create) ...[
              const SizedBox(height: Gap.sm),
              TextField(
                controller: _repeat,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                onChanged: (_) => setState(() => _problem = null),
                decoration: const InputDecoration(labelText: 'Repeat password'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop<_Choice>(context, null), child: const Text('Cancel')),
        ListenableBuilder(
          listenable: _password,
          builder: (context, _) => TextButton(
            onPressed: _submit,
            child: Text(widget.create ? (_password.text.isEmpty ? 'Save without password' : 'Save with password') : 'Open backup'),
          ),
        ),
      ],
    );
  }
}

Future<void> _message(BuildContext context, String title, String message) => showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );

String _count(int n, String one, [String? many]) => '$n ${n == 1 ? one : (many ?? '${one}s')}';

/// Settings → Back up to a file.
Future<void> backUp(BuildContext context, WidgetRef ref) async {
  final choice = await showDialog<_Choice>(context: context, builder: (_) => const _PasswordDialog(create: true));
  if (choice == null || !context.mounted) return;
  final repo = ref.read(repoProvider);
  try {
    final data = await repo.backupData();
    final text = await ClockedBackup.seal(data, choice.password);
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Clocked backup',
      fileName: ClockedBackup.fileName(DateTime.now()),
      bytes: Uint8List.fromList(utf8.encode(text)),
    );
    if (path == null || !context.mounted) return;
    final days = data.days.where((d) => d.sessions.isNotEmpty).length;
    await _message(
      context,
      'Backup saved',
      '${_count(days, 'day')} of screen time, ${_count(data.limits.length, 'app limit')}, '
          '${_count(data.focus.length, 'focus session')} and your settings are in the file.'
          '${choice.password.isEmpty ? '' : ' It is protected with your password.'}\n\n'
          'On a new phone, install Clocked, allow usage access, then use Restore from a backup.',
    );
  } catch (e) {
    if (context.mounted) await _message(context, 'Could not save the backup', '$e');
  }
}

/// Settings → Restore from a backup.
Future<void> restoreBackup(BuildContext context, WidgetRef ref) async {
  final FilePickerResult? picked;
  try {
    picked = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
  } catch (e) {
    if (context.mounted) await _message(context, 'Could not open the file', '$e');
    return;
  }
  final bytes = picked?.files.single.bytes;
  if (bytes == null || !context.mounted) return;
  String text;
  try {
    text = utf8.decode(bytes);
  } on FormatException {
    await _message(context, 'Not a Clocked backup', 'This file is not a Clocked backup.');
    return;
  }

  BackupData? data;
  String? password;
  String? error;
  while (data == null) {
    try {
      data = await ClockedBackup.open(text, password);
    } on BackupNeedsPassword {
      if (!context.mounted) return;
      final choice = await showDialog<_Choice>(context: context, builder: (_) => _PasswordDialog(create: false, error: error));
      if (choice == null) return;
      password = choice.password;
    } on BackupWrongPassword {
      error = 'That password is not right for this backup.';
      password = null;
    } on BackupFormatException catch (e) {
      if (context.mounted) await _message(context, 'Cannot restore this file', e.message);
      return;
    }
  }
  if (!context.mounted) return;

  final made = data.exportedAt.millisecondsSinceEpoch > 0 ? '${DateFormat('d MMM yyyy').format(data.exportedAt)} at ${fmtTime(data.exportedAt)}' : 'an unknown date';
  final days = data.days.where((d) => d.sessions.isNotEmpty).length;
  final ok = await bConfirm(
    context,
    title: 'Restore this backup?',
    message: 'Made $made, with ${_count(days, 'day')} of screen time and ${_count(data.limits.length, 'app limit')}.\n\n'
        'Days already on this phone are kept as they are, so nothing is counted twice. Limits are added to yours; '
        'goal, downtime and the weekly summary are set from the backup.',
    confirmLabel: 'Restore',
  );
  if (!ok || !context.mounted) return;
  try {
    final restored = data;
    final plan = await withRepo(ref, (r) => r.restore(restored));
    final prefs = ref.read(prefsProvider);
    ref.read(goalProvider.notifier).state = prefs.goalMinutes;
    ref.read(themeModeProvider.notifier).state = prefs.themeMode;
    ref.read(downtimeProvider.notifier).state = prefs.downtime;
    ref.read(weeklySummaryProvider.notifier).state = prefs.weeklySummary;
    if (!context.mounted) return;
    final added = plan.days.where((d) => d.sessions.isNotEmpty).length;
    await _message(
      context,
      'Restore finished',
      '${_count(added, 'day')} of screen time added'
          '${plan.skippedDays > 0 ? ' (${_count(plan.skippedDays, 'day was', 'days were')} already here)' : ''}, '
          '${_count(plan.limits.length, 'app limit')} added, ${_count(plan.focus.length, 'focus session')} added.',
    );
  } catch (e) {
    if (context.mounted) await _message(context, 'Could not restore the backup', '$e');
  }
}
