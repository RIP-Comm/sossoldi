import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/intl.dart';
import '../../../constants/style.dart';
import '../../../services/csv/csv_file_picker.dart';
import '../../../services/database/sossoldi_database.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../transactions/create_transaction/widgets/details_list_tile.dart';

class ImportOption {
  final IconData icon;
  final String label;
  final Color color;

  ImportOption(this.icon, this.label, this.color,);
}


class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final DateTime _firstValidDate = DateTime.fromMillisecondsSinceEpoch(0);
  final DateTime _lastValidDate = DateTime(2100);

  DateTime selectedFromDate = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime selectedToDate = DateTime.now();
  int selectedFormatIndex = 0;
  bool resetDatabase = false;

  void setFromDate(DateTime dt)
  {
    setState(() {
      selectedFromDate = dt;
    });
  }

  void setToDate(DateTime dt)
  {
    setState(() {
      selectedToDate = dt;
    });
  }

  void setDates(DateTime dateTime, bool isFromDate)
  {
    if(isFromDate)
    {
      setFromDate(dateTime);
    }
    else
    {
      setToDate(dateTime);
    }
  }

  void showContextDatePicker(DateTime dateTime, bool isFromDate) async
  {
    FocusManager.instance.primaryFocus?.unfocus();
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
          height: 300,
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondarySystemBackground,
            context,
          ),
          child: CupertinoDatePicker(
            initialDateTime: dateTime,
            minimumYear: _firstValidDate.year,
            maximumYear: _lastValidDate.year,
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (date) {
              setDates(date, isFromDate);
            },
          ),
        ),
      );
    } else if (Platform.isAndroid) {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: _firstValidDate,
        lastDate: _lastValidDate,
      );
      if (pickedDate != null) {
        setDates(pickedDate, isFromDate);
      }
    }
  }

  List<ImportOption> importFormats = [
    // [
    //   Icons.storage,
    //   'Sossoldi Database',
    //       () {
    //
    //   },
    //   Colors.lightBlue,
    // ],
    ImportOption(
      Icons.assignment,
      'Sossoldi CSV',
      Colors.lightGreen
    ),
    ImportOption(
      Icons.wallet,
      'Wallet CSV',
      Colors.green
    ),
    ImportOption(
      Icons.savings,
      'Money Manager DB',
      Colors.redAccent
    ),
    ImportOption(
      Icons.assignment,
      'Money Manager CSV',
      Colors.redAccent
    ),

  ];

  Future<bool> importSossoldiCsv() async
  {
    final file = await CSVFilePicker.pickCSVFile(context);
    if (file == null) {
      return false;
    }
    final results = await SossoldiDatabase.instance.importFromCSV(
      file.path,selectedFromDate, selectedToDate, resetDatabase
    );

    if (!mounted) return false;

    if (!results.values.every((success) => success)) {
      final failedTables = results.entries
          .where((e) => !e.value)
          .map((e) => e.key)
          .join(', ');

      throw Exception('Failed to import some tables: $failedTables');
    }

    return true;
  }

  Future<bool> importMoneyManagerDatabase() async
  {
    FilePickerResult? result= await FilePicker.platform.pickFiles(type: FileType.custom, dialogTitle: 'Pick Database',allowMultiple: false, allowedExtensions: ['sqlite','db']);

    if(result == null)
    {
      return false;
    }
    String? filePath = result.files.single.path;

    if(filePath == null){
      return false;
    }

    final res = await SossoldiDatabase.instance.importDBFromMoneyManager(filePath, selectedFromDate, selectedToDate, resetDatabase);

    if(!res) {
      throw Exception('Failed to import data from DB');
    }

    return true;
  }

  Future<bool> importMoneyManagerCsv() async{
    final file = await CSVFilePicker.pickCSVFile(context);
    if (file == null) {
      return false;
    }
    final result = await SossoldiDatabase.instance.importCsvFromMoneyManager(
      file.path,selectedFromDate, selectedToDate, resetDatabase
    );

    if(!result) {
      throw Exception('Failed to import data from CSV');
    }

    return true;
  }

  Future<bool> importWalletCsv() async
  {
    return true;
  }

  void importPressed() async
  {
    bool result = false;

    CSVFilePicker.showLoading(context, 'Importing data');

    switch(selectedFormatIndex)
    {
      case 0:
        result = await importSossoldiCsv();
        break;
      case 1:
        result = await importWalletCsv();
        break;
      case 2:
        result = await importMoneyManagerDatabase();
        break;
      case 3:
        result = await importMoneyManagerCsv();
        break;
      default:
        return;
    }

    CSVFilePicker.hideLoading(context);

    if(result)
    {
      await CSVFilePicker.showSuccess(
        context,
        'Data imported successfully',
      );
    }

    if (mounted) Phoenix.rebirth(context);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...importFormats.asMap().entries.map((entry) {
              int index = entry.key;
              ImportOption option = entry.value;

              return RadioListTile<int>(
                value: index,
                groupValue: selectedFormatIndex,
                title: Text(option.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                secondary:  RoundedIcon(
                  icon: option.icon,
                  backgroundColor: option.color,
                ),
                activeColor: Theme.of(context).primaryColor,
                onChanged: (int? value) {
                  setState(() {
                    selectedFormatIndex = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing, // Put radio on the right
              );
            }),
            const Divider(),
            DetailsListTile(
                title: "From",
                icon: Icons.calendar_month,
                value: DateFormat('yyyy/MM/dd').format(selectedFromDate),
                callback: () => showContextDatePicker(selectedFromDate, true)
            ),
            DetailsListTile(
                title: "To",
                icon: Icons.calendar_month,
                value: DateFormat('yyyy/MM/dd').format(selectedToDate),
                callback: () => showContextDatePicker(selectedToDate, false)
            ),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.start,children: [
              Checkbox(value: resetDatabase, onChanged: (status)
              {
                setState(() {
                  resetDatabase = status!;
                });
              }),
              const Text('Reset Database'),
            ],)
          ],
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Sizes.sm,
            Sizes.xs,
            Sizes.sm,
            Sizes.sm,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [defaultShadow],
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
            ),
            child: ElevatedButton(
              onPressed: importPressed,
              child: const Text(
                  'Import'
              ),
            ),
          ),
        ),
      ],
    );
  }
}