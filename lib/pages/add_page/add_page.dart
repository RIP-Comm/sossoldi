import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/functions.dart';
import '../../constants/style.dart';
import '../../model/transaction.dart';
import '../../providers/transactions_provider.dart';
import "widgets/account_selector.dart";
import 'widgets/amount_section.dart';
import "widgets/category_selector.dart";
import 'widgets/details_list_tile.dart';
import 'widgets/label_list_tile.dart';
import 'widgets/recurrence_list_tile.dart';

class AddPage extends ConsumerStatefulWidget {
  final bool recurrencyEditingPermitted;

  const AddPage({super.key, this.recurrencyEditingPermitted = true});

  @override
  ConsumerState<AddPage> createState() => _AddPageState();
}

class _AddPageState extends ConsumerState<AddPage> with Functions {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  bool? recurrencyEditingPermittedFromRoute;

  @override
  void initState() {
    amountController.text = numToCurrency(ref.read(selectedTransactionUpdateProvider)?.amount);
    noteController.text = ref.read(selectedTransactionUpdateProvider)?.note ?? '';

    amountController.addListener(_updateAmount);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if arguments are being passed
    final args = ModalRoute.of(context)?.settings.arguments;

    if (recurrencyEditingPermittedFromRoute == null) {
      final argsMap = args as Map<String, dynamic>?;
      recurrencyEditingPermittedFromRoute = argsMap?['recurrencyEditingPermitted'] ?? widget.recurrencyEditingPermitted;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String getCleanAmountString() {
    // Remove all non-numeric characters
    var cleanNumberString = amountController.text.replaceAll(RegExp(r'[^0-9\.]'), '');

    // Remove leading zeros only if the number does not start with "0."
    if (!cleanNumberString.startsWith('0.')) {
      cleanNumberString = cleanNumberString.replaceAll(RegExp(r'^0+(?!\.)'), '');
    }

    if (cleanNumberString.startsWith('.')) {
      cleanNumberString = '0$cleanNumberString';
    }

    return cleanNumberString;
  }

  void _updateAmount() {
    final selectedType = ref.read(transactionTypeProvider);

    var toBeWritten = getCleanAmountString();

    if (selectedType == TransactionType.expense) {
      // apply the minus sign if it's an expense
      if (toBeWritten.isNotEmpty) {
        toBeWritten = "-$toBeWritten";
      }
    }

    if (toBeWritten != amountController.text) {
      // only update the controller if the value is different
      amountController.text = toBeWritten;
      amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: toBeWritten.length),
      );
    }
  }

  void _createOrUpdateTransaction() {
    final selectedType = ref.read(transactionTypeProvider);
    final selectedTransaction = ref.read(selectedTransactionUpdateProvider);

    final cleanAmount = getCleanAmountString();

    // Check that an amount has been provided
    if (cleanAmount != '') {
      if (selectedTransaction != null) {
        // if the original transaction is not recurrent, but user sets a recurrency, add the corrispondent record
        // and edit the original transaction
        if(ref.read(selectedRecurringPayProvider) && !selectedTransaction.recurring) {
          ref
              .read(transactionsProvider.notifier)
              .addRecurringTransaction(currencyToNum(cleanAmount), noteController.text)
              .then((value) {
                if (value != null) {
                  ref
                      .read(transactionsProvider.notifier)
                      .updateTransaction(currencyToNum(cleanAmount), noteController.text, value.id)
                      .whenComplete(() => Navigator.of(context).pop());
                }
              });
        } else {
          ref
              .read(transactionsProvider.notifier)
              .updateTransaction(currencyToNum(cleanAmount), noteController.text, selectedTransaction.idRecurringTransaction)
              .whenComplete(() => Navigator.of(context).pop());
        }


      } else {
        if (selectedType == TransactionType.transfer) {
          if (ref.read(bankAccountTransferProvider) != null) {
            ref
                .read(transactionsProvider.notifier)
                .addTransaction(currencyToNum(cleanAmount), noteController.text)
                .whenComplete(() => Navigator.of(context).pop());
          }
        } else {
          // It's an income or an expense
          if (ref.read(categoryProvider) != null) {
            if(ref.read(selectedRecurringPayProvider)) {
              ref
                .read(transactionsProvider.notifier)
                .addRecurringTransaction(currencyToNum(cleanAmount), noteController.text)
                .whenComplete(() => Navigator.of(context).pop());
            } else {
              ref
                .read(transactionsProvider.notifier)
                .addTransaction(currencyToNum(cleanAmount), noteController.text)
                .whenComplete(() => Navigator.of(context).pop());
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(transactionTypeProvider);
    final selectedTransaction = ref.watch(selectedTransactionUpdateProvider);

    _updateAmount();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (selectedTransaction != null) ? "Editing transaction" : "New transaction",
        ),
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: blue5),
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
                AmountSection(amountController),
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
                      if (selectedType != TransactionType.transfer) ...[
                        DetailsListTile(
                          title: "Account",
                          icon: Icons.account_balance_wallet,
                          value: ref.watch(bankAccountProvider)?.name,
                          callback: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            showModalBottomSheet(
                              context: context,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              isScrollControlled: true,
                              useSafeArea: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                ),
                              ),
                              builder: (_) => DraggableScrollableSheet(
                                expand: false,
                                minChildSize: 0.5,
                                initialChildSize: 0.7,
                                maxChildSize: 0.9,
                                builder: (_, controller) => AccountSelector(
                                  provider: bankAccountProvider,
                                  scrollController: controller,
                                ),
                              ),
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
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              isScrollControlled: true,
                              useSafeArea: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                ),
                              ),
                              builder: (_) => DraggableScrollableSheet(
                                expand: false,
                                minChildSize: 0.5,
                                initialChildSize: 0.7,
                                maxChildSize: 0.9,
                                builder: (_, controller) => CategorySelector(
                                  scrollController: controller,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, color: grey1),
                      ],
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
                      if (selectedType == TransactionType.expense) ...[
                        RecurrenceListTile(
                            recurrencyEditingPermitted: widget.recurrencyEditingPermitted,
                            selectedTransaction: ref.read(selectedTransactionUpdateProvider)
                        )
                      ],
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
                  onPressed: _createOrUpdateTransaction,
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    selectedTransaction != null ? "UPDATE TRANSACTION" : "ADD TRANSACTION",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Theme.of(context).colorScheme.onPrimary),
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
