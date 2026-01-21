import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../model/transaction.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/recurring_transactions_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import "widgets/account_selector.dart";
import 'widgets/amount_section.dart';
import "widgets/category_selector.dart";
import 'widgets/details_list_tile.dart';
import 'widgets/duplicate_transaction_dialog.dart';
import 'widgets/label_list_tile.dart';
import 'widgets/recurrence_list_tile.dart';

class CreateTransactionPage extends ConsumerStatefulWidget {
  const CreateTransactionPage({super.key, this.transaction});

  final Transaction? transaction;

  @override
  ConsumerState<CreateTransactionPage> createState() =>
      _CreateTransactionPage();
}

class _CreateTransactionPage extends ConsumerState<CreateTransactionPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  bool recurrencyEditingPermitted = true;
  bool _isSaveEnabled = false;

  @override
  void initState() {
    if (widget.transaction != null) {
      _isSaveEnabled = true;
      recurrencyEditingPermitted = !widget.transaction!.recurring;
      amountController.text = widget.transaction?.amount.toCurrency() ?? '';
      noteController.text = widget.transaction?.note ?? '';
    }
    amountController.addListener(_updateAmount);

    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String getCleanAmountString() {
    // Remove all non-numeric characters
    var cleanNumberString = amountController.text.replaceAll(
      RegExp(r'[^0-9\.]'),
      '',
    );

    // Remove leading zeros only if the number does not start with "0."
    if (!cleanNumberString.startsWith('0.')) {
      cleanNumberString = cleanNumberString.replaceAll(
        RegExp(r'^0+(?!\.)'),
        '',
      );
    }

    if (cleanNumberString.startsWith('.')) {
      cleanNumberString = '0$cleanNumberString';
    }

    return cleanNumberString;
  }

  void _updateAmount() {
    final selectedType = ref.read(selectedTransactionTypeProvider);

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
    final selectedAccount = ref.read(selectedBankAccountProvider) != null;
    final selectedAccountTransfer =
        ref.read(bankAccountTransferProvider) != null;
    final selectedCategory = ref.read(selectedCategoryProvider) != null;
    setState(() {
      _isSaveEnabled = amountController.text.isNotEmpty && selectedAccount;
      switch (selectedType) {
        case TransactionType.expense:
        case TransactionType.income:
          _isSaveEnabled &= selectedCategory;
          break;
        case TransactionType.transfer:
          _isSaveEnabled &= selectedAccountTransfer;
          break;
      }
    });
  }

  void _refreshAccountAndNavigateBack() async {
    ref
        .read(accountsProvider.notifier)
        .refreshAccount(ref.read(selectedBankAccountProvider)!)
        .whenComplete(() {
          if (mounted) Navigator.of(context).pop();
        });
  }

  void _createOrUpdateTransaction() async {
    final selectedType = ref.read(selectedTransactionTypeProvider);

    final cleanAmount = getCleanAmountString();

    // Check that an amount has been provided
    if (cleanAmount != '') {
      if (widget.transaction != null) {
        // if the original transaction is not recurrent, but user sets a recurrency, add the corrispondent record
        // and edit the original transaction
        if (ref.read(selectedRecurringPayProvider) &&
            !widget.transaction!.recurring) {
          await ref
              .read(recurringTransactionsProvider.notifier)
              .create(cleanAmount.toNum(), noteController.text, selectedType)
              .then((value) async {
                if (value != null) {
                  await ref
                      .read(transactionsProvider.notifier)
                      .updateTransaction(
                        widget.transaction!,
                        cleanAmount.toNum(),
                        noteController.text,
                        value.id,
                      )
                      .whenComplete(() => _refreshAccountAndNavigateBack());
                }
              });
        } else {
          await ref
              .read(transactionsProvider.notifier)
              .updateTransaction(
                widget.transaction!,
                cleanAmount.toNum(),
                noteController.text,
                widget.transaction!.idRecurringTransaction,
              )
              .whenComplete(() => _refreshAccountAndNavigateBack());
        }
      } else {
        if (selectedType == TransactionType.transfer) {
          if (ref.read(bankAccountTransferProvider) != null) {
            await ref
                .read(transactionsProvider.notifier)
                .create(cleanAmount.toNum(), noteController.text)
                .whenComplete(() => _refreshAccountAndNavigateBack());
          }
        } else {
          // It's an income or an expense
          if (ref.read(selectedCategoryProvider) != null) {
            if (ref.read(selectedRecurringPayProvider)) {
              await ref
                  .read(recurringTransactionsProvider.notifier)
                  .create(
                    cleanAmount.toNum(),
                    noteController.text,
                    selectedType,
                  );
            } else {
              await ref
                  .read(transactionsProvider.notifier)
                  .create(cleanAmount.toNum(), noteController.text);
            }
            _refreshAccountAndNavigateBack();
          }
        }
      }
    }
  }

  void _deleteTransaction() async {
    await ref
        .read(transactionsProvider.notifier)
        .delete(widget.transaction!.id!)
        .whenComplete(() => _refreshAccountAndNavigateBack());
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(selectedTransactionTypeProvider);

    _updateAmount();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (widget.transaction != null)
              ? "Editing transaction"
              : "New transaction",
        ),
        actions: [
          if (widget.transaction != null) ...[
            IconButton(
              icon: Icon(
                Icons.copy,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => DuplicateTransactionDialog(
                  transaction: widget.transaction!,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: _deleteTransaction,
            ),
          ],
        ],
      ),
      persistentFooterDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 5.0,
            offset: const Offset(0, -1.0),
          ),
        ],
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
              onPressed: _isSaveEnabled ? _createOrUpdateTransaction : null,
              child: Text(
                widget.transaction != null
                    ? "UPDATE TRANSACTION"
                    : "ADD TRANSACTION",
              ),
            ),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: Sizes.md * 6),
        child: Column(
          children: [
            AmountSection(amountController),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(
                left: Sizes.lg,
                top: Sizes.xxl,
                bottom: Sizes.sm,
              ),
              child: Text(
                "DETAILS",
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  LabelListTile(noteController),
                  const Divider(),
                  if (selectedType != TransactionType.transfer) ...[
                    DetailsListTile(
                      title: "Account",
                      icon: Icons.account_balance_wallet,
                      value: ref.watch(selectedBankAccountProvider)?.name,
                      callback: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        showModalBottomSheet(
                          context: context,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          isScrollControlled: true,
                          useSafeArea: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(Sizes.borderRadius),
                              topRight: Radius.circular(Sizes.borderRadius),
                            ),
                          ),
                          builder: (_) => DraggableScrollableSheet(
                            expand: false,
                            minChildSize: 0.5,
                            initialChildSize: 0.7,
                            maxChildSize: 0.9,
                            builder: (_, controller) =>
                                AccountSelector(scrollController: controller),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    DetailsListTile(
                      title: "Category",
                      icon: Icons.list_alt,
                      value: ref.watch(selectedCategoryProvider)?.name,
                      callback: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        showModalBottomSheet(
                          context: context,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          isScrollControlled: true,
                          useSafeArea: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(Sizes.borderRadius),
                              topRight: Radius.circular(Sizes.borderRadius),
                            ),
                          ),
                          builder: (_) => DraggableScrollableSheet(
                            expand: false,
                            minChildSize: 0.5,
                            initialChildSize: 0.7,
                            maxChildSize: 0.9,
                            builder: (_, controller) =>
                                CategorySelector(scrollController: controller),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                  DetailsListTile(
                    title: "Date",
                    icon: Icons.calendar_month,
                    value: ref.watch(selectedDateProvider).formatEDMY(),
                    callback: () async {
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
                              initialDateTime: ref.watch(selectedDateProvider),
                              minimumYear: 2015,
                              maximumYear: 2050,
                              mode: CupertinoDatePickerMode.date,
                              onDateTimeChanged: (date) => ref
                                  .read(selectedDateProvider.notifier)
                                  .setDate(date),
                            ),
                          ),
                        );
                      } else if (Platform.isAndroid) {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: ref.watch(selectedDateProvider),
                          firstDate: DateTime(2015),
                          lastDate: DateTime(2050),
                        );
                        if (pickedDate != null) {
                          ref
                              .read(selectedDateProvider.notifier)
                              .setDate(pickedDate);
                        }
                      }
                    },
                  ),
                  RecurrenceListTile(
                    recurrencyEditingPermitted: recurrencyEditingPermitted,
                    selectedTransaction: widget.transaction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
