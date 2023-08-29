import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/style.dart';
import '../../constants/functions.dart';
import '../../model/transaction.dart';
import '../../providers/transactions_provider.dart';
import "widgets/account_selector.dart";
import 'widgets/amount_section.dart';
import "widgets/category_selector.dart";
import 'widgets/details_list_tile.dart';
import 'widgets/label_list_tile.dart';
import 'widgets/recurrence_list_tile.dart';

class AddPage extends ConsumerStatefulWidget {
  const AddPage({super.key});

  @override
  ConsumerState<AddPage> createState() => _AddPageState();
}

class _AddPageState extends ConsumerState<AddPage> with Functions {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    amountController.text =
        numToCurrency(ref.read(selectedTransactionUpdateProvider)?.amount);
    noteController.text =
        ref.read(selectedTransactionUpdateProvider)?.note ?? '';
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    ref.invalidate(selectedTransactionUpdateProvider);
    ref.invalidate(transactionTypesProvider);
    ref.invalidate(bankAccountProvider);
    ref.invalidate(dateProvider);
    ref.invalidate(categoryProvider);
    ref.invalidate(amountProvider);
    ref.invalidate(noteProvider);
    ref.invalidate(selectedRecurringPayProvider);
    ref.invalidate(intervalProvider);
    ref.invalidate(repetitionProvider);
    ref.invalidate(transactionTypesProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trsncTypeList = ref.watch(transactionTypeList);
    final trnscTypes = ref.watch(transactionTypesProvider);
    final selectedTransaction = ref.watch(selectedTransactionUpdateProvider);
    final selectedType = trsncTypeList[trnscTypes.indexOf(true)];
    final selectedRecurringPay = ref.watch(selectedRecurringPayProvider);
    // I listen servono a evitare che il provider faccia il dispose subito dopo essere stato aggiornato
    ref.listen(amountProvider, (_, __) {});
    ref.listen(noteProvider, (_, __) {});

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (selectedTransaction != null)
              ? "Editing transaction"
              : "New transaction",
        ),
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
          selectedTransaction != null
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
                          .deleteTransaction(selectedTransaction.id!)
                          .whenComplete(() => Navigator.of(context).pop());
                    },
                  ),
                )
              : const SizedBox(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AmountSection(
              amountController: amountController,
            ),
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
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  LabelListTile(
                    labelController: noteController,
                    labelProvider: noteProvider,
                  ),
                  const Divider(height: 1, color: grey1),
                  if (selectedType != Type.transfer) ...[
                    DetailsListTile(
                      title: "Account",
                      icon: Icons.account_balance_wallet,
                      value: ref.watch(bankAccountProvider)?.name,
                      callback: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => AccountSelector(bankAccountProvider),
                        );
                      },
                    ),
                    const Divider(height: 1, color: grey1),
                    DetailsListTile(
                      title: "Category",
                      icon: Icons.list_alt,
                      value: ref.watch(categoryProvider)?.name,
                      callback: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => const CategorySelector(),
                        );
                      },
                    ),
                  ],
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
                              onDateTimeChanged: (date) =>
                                  ref.read(dateProvider.notifier).state = date,
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
                          ref.read(dateProvider.notifier).state = pickedDate;
                        }
                      }
                    },
                  ),
                  if (selectedType == Type.expense) ...[
                    RecurrenceListTile(
                      isRecurring: selectedRecurringPay,
                      recurringProvider: selectedRecurringPayProvider,
                      intervalProvider: intervalProvider,
                    ),
                  ],
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
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    boxShadow: [defaultShadow],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      // Check that an amount it's inserted
                      if (ref.read(amountProvider) != 0) {
                        if (selectedTransaction != null) {
                          ref
                              .read(transactionsProvider.notifier)
                              .updateTransaction()
                              .whenComplete(() => Navigator.of(context).pop());
                        } else {
                          if (selectedType == Type.transfer) {
                            if (ref.read(bankAccountTransferProvider) != null) {
                              ref
                                  .read(transactionsProvider.notifier)
                                  .addTransaction()
                                  .whenComplete(
                                      () => Navigator.of(context).pop());
                            }
                          } else {
                            // It's an income or an expense
                            if (ref.read(categoryProvider) != null) {
                              ref
                                  .read(transactionsProvider.notifier)
                                  .addTransaction()
                                  .whenComplete(
                                      () => Navigator.of(context).pop());
                            }
                          }
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      selectedTransaction != null
                          ? "UPDATE TRANSACTION"
                          : "ADD TRANSACTION",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.background),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
