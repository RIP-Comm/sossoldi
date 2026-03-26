import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/style.dart';
import '../../../services/csv/csv_file_picker.dart';
import '../../../services/database/sossoldi_database.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../transactions/create_transaction/widgets/details_list_tile.dart';


class ExportOption {
  final IconData icon;
  final String label;
  final Color color;

  ExportOption(this.icon, this.label, this.color);
}

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final DateTime _firstValidDate = DateTime.fromMillisecondsSinceEpoch(0);
  final DateTime _lastValidDate = DateTime(2100);

  DateTime selectedFromDate = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime selectedToDate = DateTime.now();
  int selectedFormatIndex = 0;

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


  List<ExportOption> exportFormats = [
    ExportOption(
        Icons.assignment,
        'Sossoldi CSV',
        Colors.green),
  ];

  void exportPressed() async
  {
    switch(selectedFormatIndex)
    {
      case 0:
        CSVFilePicker.showLoading(context, 'Exporting data...');

        final csv = await SossoldiDatabase.instance.exportToCSV(selectedFromDate, selectedToDate);

        await CSVFilePicker.saveCSVFile(csv, context);
        CSVFilePicker.hideLoading(context);
        break;
      default:
        return;
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...exportFormats.asMap().entries.map((entry) {
              int index = entry.key;
              ExportOption option = entry.value;

              return RadioListTile<int>(
                value: index,
                groupValue: selectedFormatIndex,
                title: Text(option.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                secondary: RoundedIcon(
                  icon: option.icon,
                  backgroundColor: option.color,
                ),
                activeColor: Theme.of(context).primaryColor,
                onChanged: (int? value) {
                  setState(() => selectedFormatIndex = value!);
                },
                controlAffinity: ListTileControlAffinity.trailing,
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
              onPressed: exportPressed,
              child: const Text(
                'EXPORT'
              ),
            ),
          ),
        ),
      ],
    );
  }
}