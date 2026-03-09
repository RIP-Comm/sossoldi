

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

enum CsvSource{
  sossoldi,
  moneyManager
}
void _showLocalizedError(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context)!;
  String message = '';

  if (error is CsvExportingErrorException) {
    message = l10n.errorExporting(error.tableName);
  } else if (error is CsvImportGeneralErrorException) {
    message = l10n.errorCsvImportGeneral(error.text);
  } else if (error is CsvNotFoundException) {
    message = l10n.errorCsvNotFound;
  } else if (error is CsvEmptyException) {
    message = l10n.errorCsvEmpty;
  } else if (error is CsvExpectedColumnException) {
    message = l10n.errorCsvExpectedColumn(error.column);
  } else if (error is CsvUnexpectedValueException) {
    message = l10n.errorCsvUnexpectedValue(error.value);
  } else if (error is CsvTransactionImportErrorException) {
    message = l10n.errorCsvTransactionImport(error.date);
  } else if (error is CleanDatabaseException) {
    message = l10n.errorCleanDatabase(error.text);
  } else if (error is ResetDatabaseException) {
    message = l10n.errorCleanDatabase(error.text);
  }

  showSnackBar(context, message: message);
}

class _BackupPageState extends ConsumerState<BackupPage> {

  Future<void> _handleImport({required CsvSource source}) async {
    try {
      final file = await CSVFilePicker.pickCSVFile(context);
      if (file == null) {
        return;
      }

      if (!mounted) return;

      CSVFilePicker.showLoading(context, AppLocalizations.of(context)!.importData);

      switch(source)
      {
        case CsvSource.sossoldi:
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

            throw CsvImportGeneralErrorException(text: '$failedTables');
          }
          break;

        case CsvSource.moneyManager:
          final result = await SossoldiDatabase.instance.importFromCsvFromMoneyManager(
            file.path,
          );

          if(!result) {
            throw CsvImportGeneralErrorException(text: '');
          }

          await CSVFilePicker.showSuccess(
            context,
              AppLocalizations.of(context)!.dataImportedSuccessfully);
          if (mounted) Phoenix.rebirth(context);

          break;
      }


    } catch (e) {
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);
      _showLocalizedError(context, e);
    }
  }

  Future<void> _handleExport() async {
    try {
      CSVFilePicker.showLoading(context,  AppLocalizations.of(context)!.exportData);

      final csv = await SossoldiDatabase.instance.exportToCSV();

      if (!mounted) return;
      CSVFilePicker.hideLoading(context);

      await CSVFilePicker.saveCSVFile(csv, context);
    } catch (e) {
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);
      showSnackBar(context, message:  AppLocalizations.of(context)!.exportFailed(e.toString()));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void showImportAlert(context, function)
  {
    var l10n = AppLocalizations.of(context)!;
     showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.warningOverwrite),
                    content: Text(
                    l10n.warningOverwriteContent,
                    ),
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
                          function();
                        },
                        child: Text(l10n.proceedImport),
                      ),
                    ],
                  ),
                );
  }

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;

    final List<BackupOption> options = [
      BackupOption(
        title: l10n.importData,
        description: l10n.importDataDescription,
        icon: Icons.upload_file,
      ),
      BackupOption(
        title: l10n.importData,
        description: l10n.importMoneyManager,
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
              switch(index)
              {
                case 0:
                  showImportAlert(context, () => _handleImport(source:  CsvSource.sossoldi));
                  break;
                case 1:
                  showImportAlert(context, () => _handleImport(source: CsvSource.moneyManager));
                  break;
                case 2:
                  _handleExport();
                  break;
                default:
                  throw UnimplementedError();
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
