import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Future<void> _handleImport() async {
    try {
      final file = await CSVFilePicker.pickCSVFile(context);
      if (file != null) {
        if (!mounted) return;
        CSVFilePicker.showLoading(context, 'Importing data...');
        final results = await SossoldiDatabase.instance.importFromCSV(
          file.path,
        );
        if (!mounted) return;
        CSVFilePicker.hideLoading(context);

        if (results.values.every((success) => success)) {
          await CSVFilePicker.showSuccess(
            context,
            'Data imported successfully',
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
            message: 'Failed to import some tables: $failedTables',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);

      showSnackBar(context, message: 'Import failed: ${e.toString()}');
    }
  }

  Future<void> _handleExport() async {
    try {
      CSVFilePicker.showLoading(context, 'Exporting data...');

      final csv = await SossoldiDatabase.instance.exportToCSV();

      if (!mounted) return;
      CSVFilePicker.hideLoading(context);

      await CSVFilePicker.saveCSVFile(csv, context);
    } catch (e) {
      if (!mounted) return;
      CSVFilePicker.hideLoading(context);
      showSnackBar(context, message: 'Export failed: ${e.toString()}');
    }
  }

  late final List<BackupOption> options = [
    BackupOption(
      title: 'Import data',
      description: 'Import a CSV file to update your database',
      icon: Icons.upload_file,
    ),
    BackupOption(
      title: 'Export data',
      description: 'Save your data as a CSV file',
      icon: Icons.download,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Import/Export'),
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
                    title: const Text('Warning: Data Overwrite'),
                    content: const Text(
                      'Importing this file will permanently replace your existing data. This action cannot be undone. Ensure you have a backup before proceeding.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _handleImport();
                        },
                        child: const Text('Proceed with Import'),
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
