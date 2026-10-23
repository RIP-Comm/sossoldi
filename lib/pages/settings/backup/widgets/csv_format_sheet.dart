import 'package:flutter/material.dart';

import '../../../../services/csv/csv_file_picker.dart';
import '../../../../services/csv/csv_format.dart';
import '../../../../services/database/sossoldi_database.dart';
import '../../../../ui/device.dart';

class CsvFormatSheet extends StatefulWidget {
  const CsvFormatSheet({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<CsvFormatSheet> createState() => _CsvFormatSheetState();
}

class _CsvFormatSheetState extends State<CsvFormatSheet> {
  late final Future<Map<String, List<CsvColumn>>> _columns = SossoldiDatabase
      .instance
      .database
      .then(CsvFormat.columns);

  static const List<(String, String)> _formats = [
    ('Dates', 'ISO 8601, e.g. 2026-01-31T12:00:00.000'),
    ('Transaction type', 'OUT (expense), IN (income), TRSF (transfer)'),
    ('Category type', 'OUT (expense), IN (income)'),
    ('Yes/No columns', '1 or 0 (e.g. active, recurring, mainAccount)'),
    ('Empty cell', 'no value'),
    (
      'Links',
      'idBankAccount and idBankAccountTransfer use the id of a bankAccount '
          'row, idCategory and parent the id of a categoryTransaction row',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(Sizes.lg),
      children: [
        Text(
          'CSV file format',
          style: textTheme.titleLarge!.copyWith(color: primary),
        ),
        const SizedBox(height: Sizes.md),
        Text(
          'The file is a full backup of your data with one row per record. '
          'The first column, ${CsvFormat.tableNameColumn}, says which table '
          'the row belongs to. Every table found in the file replaces your '
          'current data for that table.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: Sizes.sm),
        Text(
          'Tip: the easiest way to start is to export your data, edit the '
          'file and import it again.',
          style: textTheme.bodyMedium!.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: Sizes.lg),
        Text('FORMATS', style: textTheme.labelLarge!.copyWith(color: primary)),
        const SizedBox(height: Sizes.sm),
        for (final (title, description) in _formats)
          Padding(
            padding: const EdgeInsets.only(bottom: Sizes.xs),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
              style: textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: Sizes.lg),
        Text('COLUMNS', style: textTheme.labelLarge!.copyWith(color: primary)),
        const SizedBox(height: Sizes.sm),
        Text('* required', style: textTheme.bodySmall),
        const SizedBox(height: Sizes.sm),
        FutureBuilder(
          future: _columns,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final MapEntry(key: table, value: columns)
                    in snapshot.data!.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sizes.md),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$table\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: columns
                                .map((c) => c.required ? '${c.name}*' : c.name)
                                .join(', '),
                          ),
                        ],
                      ),
                      style: textTheme.bodyMedium,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: Sizes.md),
        ElevatedButton(
          onPressed: () => CSVFilePicker.saveCSVFile(
            CsvFormat.template(),
            context,
            fileName: 'sossoldi_template',
          ),
          child: const Text('DOWNLOAD TEMPLATE'),
        ),
      ],
    );
  }
}
