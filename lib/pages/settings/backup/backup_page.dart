import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/exceptions.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/database/sossoldi_database.dart';
import '../../../ui/device.dart';
import '../../../services/csv/csv_file_picker.dart';
import '../../../ui/snack_bars/snack_bar.dart';
import '../../../ui/widgets/default_card.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class BackupOption {
  final String title;
  final String description;
  final Future<void> Function()? action;
  final IconData icon;

  BackupOption({
    required this.title,
    required this.description,
    this.action,
    required this.icon,
  });

  BackupOption copyWith({
    String? title,
    String? description,
    Future<void> Function()? action,
    IconData? icon,
  }) {
    return BackupOption(
      title: title ?? this.title,
      description: description ?? this.description,
      action: action ?? this.action,
      icon: icon ?? this.icon,
    );
  }
}

class _BackupPageState extends ConsumerState<BackupPage> {
  void _showImportError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    final String message = switch (error) {
      CsvNotFoundException() => l10n.errorCsvNotFound,
      CsvEmptyException() => l10n.errorCsvEmpty,
      CsvExpectedColumnException(:final column) => l10n.errorCsvExpectedColumn(
        column,
      ),
      CsvImportTableException(:final tableName) => l10n.errorCsvImportTable(
        tableName,
      ),
      _ => l10n.errorCsvImportGeneral(error.toString()),
    };
    showSnackBar(context, message: message);
  }

  Future<void> _handleImport() async {
    try {
      final file = await CSVFilePicker.pickCSVFile(context);
      if (file != null) {
        if (!mounted) return;
        CSVFilePicker.showLoading(
          context,
          AppLocalizations.of(context)!.importingData,
        );
        final results = await SossoldiDatabase.instance.importFromCSV(
          file.path,
        );
        if (!mounted) return;
        CSVFilePicker.hideLoading(context);

        if (results.values.every((success) => success)) {
          await CSVFilePicker.showSuccess(
            context,
            AppLocalizations.of(context)!.dataImportedSuccessfully,
          );
          if (mounted) Phoenix.rebirth(context);
        } else {
          final failedTables = results.entries
              .where((e) => !e.value)
              .map((e) => e.key)
              .join(', ');

          if (!mounted) return;

          showSnackBar(
            context,
            message: AppLocalizations.of(
              context,
            )!.importFailedTables(failedTables),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);
      _showImportError(e);
    }
  }

  Future<void> _handleExport() async {
    try {
      CSVFilePicker.showLoading(
        context,
        AppLocalizations.of(context)!.exportingData,
      );

      final csv = await SossoldiDatabase.instance.exportToCSV();

      if (!mounted) return;
      CSVFilePicker.hideLoading(context);

      await CSVFilePicker.saveCSVFile(csv, context);
    } catch (e) {
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);
      showSnackBar(
        context,
        message: AppLocalizations.of(context)!.exportFailed(e.toString()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<BackupOption> options = [
      BackupOption(
        title: l10n.importData,
        description: l10n.importDataDescription,
        icon: Icons.upload_file,
      ),
      BackupOption(
        title: l10n.exportData,
        description: l10n.exportDataDescription,
        icon: Icons.download,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.importExport),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: Sizes.xl),
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(height: Sizes.lg),
        itemBuilder: (context, index) {
          final option = options[index];
          return DefaultCard(
            onTap: () {
              if (index == 0) {
                // Show confirmation dialog for the first option
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.warningOverwrite),
                    content: Text(l10n.warningOverwriteContent),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _handleImport();
                        },
                        child: Text(l10n.proceedImport),
                      ),
                    ],
                  ),
                );
              } else {
                _handleExport();
              }
            },
            child: Row(
              children: [
                Icon(
                  option.icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: Sizes.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: Sizes.xs),
                      Text(
                        option.description,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
