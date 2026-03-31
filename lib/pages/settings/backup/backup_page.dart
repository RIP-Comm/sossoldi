import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/csv/general_file_picker.dart';
import '../../../services/database/sossoldi_database.dart';
import '../../../ui/device.dart';
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

  Future<void> _handleRestore() async {
    try
    {
      FilePickerResult? result= await FilePicker.platform.pickFiles(type: FileType.custom, dialogTitle: 'Pick Database',allowMultiple: false, allowedExtensions: ['sqlite','db']);
      if(result == null)
      {
        // User declined
        return;
      }
      String? filePath = result.files.single.path;

      if(filePath == null){
        return;
      }

      if(!await SossoldiDatabase.instance.importDatabase(File(filePath)))
      {
        throw Exception('Failed to import database, table not found');
      }
      GeneralFilePicker.hideLoading(context);

      await GeneralFilePicker.showSuccess(
        context,
        'Data imported successfully',
      );

      if (mounted) Phoenix.rebirth(context);
    }
    catch(e)
    {
      if (!mounted) return;
      GeneralFilePicker.hideLoading(context);

      showSnackBar(context, message: 'Import failed: ${e.toString()}');
    }
  }


  Future<void> _handleBackup() async {
    try {
      GeneralFilePicker.showLoading(context, 'Exporting data...');
      Uint8List bytes =  await SossoldiDatabase.instance.exportDatabase();
      await FilePicker.platform.saveFile(
          dialogTitle: 'Salva backup database',
          fileName: 'backup.db',
          bytes: bytes
      );
      GeneralFilePicker.hideLoading(context);

    } catch (e) {
      if (!mounted) return;
      GeneralFilePicker.hideLoading(context);
      showSnackBar(context, message: 'Export failed: ${e.toString()}');
    }
  }



  @override
  void initState() {
    super.initState();
  }

  void showImportAlert(BuildContext context)
  {
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
                _handleRestore();
              },
              child: const Text('Proceed with Import'),
            ),
          ],
        ),
      );
  }


  @override
  Widget build(BuildContext context) {

  // It updates with the right context
  List<BackupOption> options = [
    BackupOption(
      title: 'Restore data',
      description: 'Import from Sossoldi sqlite database file',
      icon: Icons.storage,
      action: () async => showImportAlert(context),
    ),
    BackupOption(
      title: 'Import data',
      description: 'Import data from file',
      icon: Icons.upload_file,
      action: () async {
        Navigator.of(context).pushNamed('/import-page');
      },
    ),
    BackupOption(
      title: 'Backup data',
      description: 'Export your personal Sossoldi sqlite database file',
      icon: Icons.storage,
      action: () => _handleBackup(),
    ),
    BackupOption(
      title: 'Export data',
      description: 'Export only some of your data into a file',
      icon: Icons.download,
      action: () async {
        Navigator.of(context).pushNamed('/export-page');
      },
    ),
    /*
    BackupOption(
      title: 'Import data',
      description: 'Import a CSV file to update your database',
      icon: Icons.upload_file,
      action: () async => showImportAlert(context, Source.sossoldiCsv),
    ),
    BackupOption(
      title: 'Import data',
      description: 'Import from Money Manager DB\n to update your database',
      icon: Icons.savings,
      action: () async => showImportAlert(context, Source.moneyManagerDb),
    ),
    BackupOption(
      title: 'Import database',
      description: 'Import from DB\n',
      icon: Icons.storage,
      action: () async => showImportAlert(context, Source.sossoldiDb),
    ),
    BackupOption(
      title: 'Import Money Manager CSV',
      description: 'Make sure the CSV is in english language\n',
      icon: Icons.upload_file,
      action: () async => showImportAlert(context, Source.moneyManagerCsv),
    ),
    BackupOption(
      title: 'Import Wallet CSV',
      description: 'Make sure the CSV is in english language\n',
      icon: Icons.upload_file,
      action: () async => showImportAlert(context, Source.moneyManagerCsv),
    ),
    BackupOption(
      title: 'Export data',
      description: 'Save your data as a CSV file',
      icon: Icons.download,
      action: () => _handleExport(source: Source.sossoldiCsv),
    ),
    BackupOption(
      title: 'Export database',
      description: 'Export your DB\n',
      icon: Icons.storage,
      action: () => _handleExport(source: Source.sossoldiDb),
    ),
    */
  ];

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
              if(option.action !=  null)
              {
                option.action?.call();
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
