import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../shared/providers/transactions_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../../ui/widgets/account_selector.dart';
import '../../../ui/widgets/amount_widget.dart';
import '../../../ui/widgets/details_list_disabled_tile.dart';
import '../../../ui/widgets/details_list_tile.dart';
import '../../../ui/widgets/label_list_tile.dart';
import '../../../ui/widgets/recurrence_list_tile_edit.dart';

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

  @override
  void initState() {
    amountController.text = ref
            .read(selectedRecurringTransactionUpdateProvider)
            ?.amount
            .toCurrency() ??
        '';
    noteController.text =
        ref.read(selectedRecurringTransactionUpdateProvider)?.note ?? '';

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
    final selectedRecurringTransaction =
        ref.watch(selectedRecurringTransactionUpdateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit recurring transaction"),
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
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
                          .deleteRecurringTransaction(
                              selectedRecurringTransaction.id!)
                          .whenComplete(() {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      });
                    },
                  ),
                )
              : const SizedBox(),
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
                      left: Sizes.lg, top: Sizes.xxl, bottom: Sizes.sm),
                  child: Text(
                    "DETAILS (any change will affect only future transactions)",
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
                                topLeft: Radius.circular(Sizes.borderRadius),
                                topRight: Radius.circular(Sizes.borderRadius),
                              ),
                            ),
                            builder: (_) => DraggableScrollableSheet(
                              expand: false,
                              minChildSize: 0.5,
                              initialChildSize: 0.7,
                              maxChildSize: 0.9,
                              builder: (_, controller) => AccountSelector(
                                scrollController: controller,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: grey1),
                      NonEditableDetailsListTile(
                        title: "Category",
                        icon: Icons.list_alt,
                        value: ref.watch(categoryProvider)?.name,
                      ),
                      const Divider(height: 1, color: grey1),
                      NonEditableDetailsListTile(
                          title: "Date Start",
                          icon: Icons.calendar_month,
                          value: ref.watch(dateProvider).formatEDMY()),
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
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    blurRadius: 5.0,
                    offset: const Offset(0, -1.0),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.xl, vertical: Sizes.sm),
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
                        .read(transactionsProvider.notifier)
                        .updateRecurringTransaction(
                            amountController.text.toNum(), noteController.text)
                        .whenComplete(() {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Sizes.borderRadius)),
                  ),
                  child: Text(
                    "UPDATE TRANSACTION",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
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
