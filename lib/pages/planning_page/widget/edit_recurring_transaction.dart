import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../providers/transactions_provider.dart';
import '../../add_page/widgets/amount_widget.dart';
import '../../add_page/widgets/details_list_tile.dart';
import '../../add_page/widgets/label_list_tile.dart';
import '../../add_page/widgets/recurrence_list_tile.dart';

class EditRecurringTransaction extends ConsumerStatefulWidget {
  const EditRecurringTransaction({super.key});

  @override
  ConsumerState<EditRecurringTransaction> createState() =>
      _EditRecurringTransactionState();
}

class _EditRecurringTransactionState
    extends ConsumerState<EditRecurringTransaction> with Functions {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    amountController.text = numToCurrency(ref.read(selectedRecurringTransactionUpdateProvider)?.amount);
    noteController.text = ref.read(selectedRecurringTransactionUpdateProvider)?.note ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedRecurringTransaction = ref.watch(selectedRecurringTransactionUpdateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editing recurring transaction"),
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style:
                Theme.of(context).textTheme.titleMedium!.copyWith(color: blue5),
          ),
        ),
        actions: [
          selectedRecurringTransaction != null
              ? Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      ref
                          .read(transactionsProvider.notifier)
                          .deleteRecurringTransaction(selectedRecurringTransaction.id!)
                          .whenComplete(() => Navigator.pop(context));
                    },
                  ),
                )
              : const SizedBox(),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 72),
            child: Column(
              children: [
                AmountWidget(amountController),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16, top: 32, bottom: 8),
                  child: Text(
                    "DETAILS",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      LabelListTile(noteController),
                      const Divider(height: 1, color: grey1),
                      DetailsListTile(
                        title: "Date",
                        icon: Icons.calendar_month,
                        value: dateToString(ref.watch(dateProvider)),
                        callback: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (Platform.isIOS) {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (_) => Container(
                                height: 300,
                                color: white,
                                child: CupertinoDatePicker(
                                  initialDateTime: ref.watch(dateProvider),
                                  minimumYear: 2015,
                                  maximumYear: 2050,
                                  mode: CupertinoDatePickerMode.date,
                                  onDateTimeChanged: (date) => ref
                                      .read(dateProvider.notifier)
                                      .state = date,
                                ),
                              ),
                            );
                          } else if (Platform.isAndroid) {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: ref.watch(dateProvider),
                              firstDate: DateTime(2015),
                              lastDate: DateTime(2050),
                            );
                            if (pickedDate != null) {
                              ref.read(dateProvider.notifier).state =
                                  pickedDate;
                            }
                          }
                        },
                      ),
                      const RecurrenceListTile(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: blue1.withOpacity(0.15),
                    blurRadius: 5.0,
                    offset: const Offset(0, -1.0),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  boxShadow: [defaultShadow],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () => {
                    ref
                        .read(transactionsProvider.notifier)
                        .updateRecurringTransaction(
                            currencyToNum(amountController.text),
                            noteController.text)
                        .whenComplete(() => Navigator.of(context).pop())
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "UPDATE TRANSACTION",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.background),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
