import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import '../../../services/backup/backup_file_picker.dart';
import '../../../services/backup/backup_service.dart';
import '../../../services/database/sossoldi_database.dart';
import '../../../ui/snack_bars/snack_bar.dart';
import 'widgets/backup_option_card.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  Future<bool> _confirmOverwrite() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning: Data Overwrite'),
        content: const Text(
          'Importing this file will permanently replace your existing data. '
          'This action cannot be undone. Ensure you have a backup before '
          'proceeding.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Proceed with Import'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Confirms, lets the user pick a file and runs [import] on it.
  /// [import] returns the message shown when it succeeds.
  Future<void> _import({
    List<String>? extensions,
    required Future<String> Function(File file) import,
  }) async {
    if (!await _confirmOverwrite() || !mounted) return;
    final file = await BackupFilePicker.pickFile(
      context,
      extensions: extensions,
    );
    if (file == null || !mounted) return;

    BackupFilePicker.showLoading(context, 'Importing data...');
    try {
      final message = await import(file);
      if (!mounted) return;
      BackupFilePicker.hideLoading(context);
      await BackupFilePicker.showSuccess(context, message);
      if (mounted) Phoenix.rebirth(context);
    } catch (e) {
      if (!mounted) return;
      BackupFilePicker.hideLoading(context);
      showSnackBar(context, message: 'Import failed: $e');
    }
  }

  Future<String> _importMoneyManager(File file) async {
    final skipped = await BackupService().importMoneyManager(file);
    return skipped == 0
        ? 'Data imported successfully'
        : 'Data imported. $skipped rows could not be read and were skipped.';
  }

  Future<String> _importSossoldiCsv(File file) async {
    await SossoldiDatabase.instance.importFromCSV(file.path);
    return 'Data imported successfully';
  }

  Future<String> _importSossoldiDatabase(File file) async {
    await BackupService().importDatabase(file);
    return 'Data imported successfully';
  }

  @override
  Widget build(BuildContext context) {
    return BackupOptionsScaffold(
      title: 'Import',
      options: [
        BackupOptionCard(
          title: 'From Money Manager',
          description:
              'Excel (.xlsx) or CSV export of Money Manager, in English',
          icon: Icons.savings,
          onTap: () =>
              _import(extensions: ['xlsx', 'csv'], import: _importMoneyManager),
        ),
        BackupOptionCard(
          title: 'From Sossoldi CSV',
          description: 'CSV file exported from Sossoldi',
          icon: Icons.description,
          onTap: () => _import(extensions: ['csv'], import: _importSossoldiCsv),
        ),
        BackupOptionCard(
          title: 'From Sossoldi database',
          description: 'Database backup (.db) exported from Sossoldi',
          icon: Icons.storage,
          onTap: () => _import(import: _importSossoldiDatabase),
        ),
      ],
    );
  }
}
