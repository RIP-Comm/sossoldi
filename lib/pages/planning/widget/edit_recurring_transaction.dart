import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/recurring_transactions_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../transactions/create_transaction/widgets/account_selector.dart';
import '../../transactions/create_transaction/widgets/amount_widget.dart';
import '../../transactions/create_transaction/widgets/details_list_tile.dart';
import '../../transactions/create_transaction/widgets/details_list_disabled_tile.dart';
import '../../transactions/create_transaction/widgets/label_list_tile.dart';
import '../../transactions/create_transaction/widgets/recurrence_list_tile_edit.dart';

class EditRecurringTransaction extends ConsumerStatefulWidget {
  const EditRecurringTransaction({super.key});

  @override
  ConsumerState<EditRecurringTransaction> createState() =>
      _EditRecurringTransactionState();
}

class _EditRecurringTransactionState
    extends ConsumerState<EditRecurringTransaction> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  late DateTime startDate;

  @override
  void initState() {
    amountController.text =
        ref
            .read(selectedRecurringTransactionUpdateProvider)
            ?.amount
            .toCurrency() ??
        '';
    noteController.text =
        ref.read(selectedRecurringTransactionUpdateProvider)?.note ?? '';
    startDate =
        ref.read(selectedRecurringTransactionUpdateProvider)?.fromDate ??
        DateTime.now();

    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedRecurringTransaction = ref.watch(
      selectedRecurringTransactionUpdateProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editRecurringTransaction),
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        actions: [
          if (selectedRecurringTransaction != null)
            Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () async {
                  ref
                      .read(recurringTransactionsProvider.notifier)
                      .delete(selectedRecurringTransaction.id!)
                      .whenComplete(() {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      });
                },
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: Sizes.md * 6),
            child: Column(
              children: [
                AmountWidget(amountController),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    left: Sizes.lg,
                    top: Sizes.xxl,
                    bottom: Sizes.sm,
                  ),
                  child: Text(
                    "DETAILS (any change will affect only future transactions)",
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
                      const Divider(height: 1, color: grey1),
                      DetailsListTile(
                        title: l10n.account,
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
                      const Divider(height: 1, color: grey1),
                      NonEditableDetailsListTile(
                        title: l10n.category,
                        icon: Icons.list_alt,
                        value: ref.watch(selectedCategoryProvider)?.name,
                      ),
                      const Divider(height: 1, color: grey1),
                      NonEditableDetailsListTile(
                        title: l10n.dateStart,
                        icon: Icons.calendar_month,
                        value: startDate.formatEDMY(),
                      ),
                      const RecurrenceListTileEdit(),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 5.0,
                    offset: const Offset(0, -1.0),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.xl,
                vertical: Sizes.sm,
              ),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  boxShadow: [defaultShadow],
                  borderRadius: BorderRadius.circular(Sizes.borderRadius),
                ),
                child: TextButton(
                  onPressed: () {
                    ref
                        .read(recurringTransactionsProvider.notifier)
                        .updateTransaction(
                          amountController.text.toNum(),
                          noteController.text,
                        )
                        .whenComplete(() {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Sizes.borderRadius),
                    ),
                  ),
                  child: Text(
                    "UPDATE TRANSACTION",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
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
