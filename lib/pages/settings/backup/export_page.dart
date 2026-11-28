import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../services/backup/backup_file_picker.dart';
import '../../../services/backup/backup_service.dart';
import '../../../services/database/sossoldi_database.dart';
import '../../../ui/snack_bars/snack_bar.dart';
import 'widgets/backup_option_card.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  Future<void> _export({
    required String extension,
    required Future<List<int>> Function() export,
  }) async {
    BackupFilePicker.showLoading(context, 'Exporting data...');
    try {
      final bytes = await export();
      if (!mounted) return;
      BackupFilePicker.hideLoading(context);
      await BackupFilePicker.saveFile(bytes, extension, context);
    } catch (e) {
      if (!mounted) return;
      BackupFilePicker.hideLoading(context);
      showSnackBar(context, message: 'Export failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackupOptionsScaffold(
      title: 'Export',
      options: [
        BackupOptionCard(
          title: 'Sossoldi database',
          description: 'Full backup (.db) to restore Sossoldi on any device',
          icon: Icons.storage,
          onTap: () => _export(
            extension: 'db',
            export: () => BackupService().exportDatabase(),
          ),
        ),
        BackupOptionCard(
          title: 'Sossoldi CSV',
          description: 'All your data as a CSV file',
          icon: Icons.description,
          onTap: () => _export(
            extension: 'csv',
            export: () async =>
                utf8.encode(await SossoldiDatabase.instance.exportToCSV()),
          ),
        ),
      ],
    );
  }
}
