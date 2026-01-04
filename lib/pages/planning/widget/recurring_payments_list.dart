import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'recurring_payment_card.dart';
import '../../../model/recurring_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';

class RecurringPaymentSection extends ConsumerStatefulWidget {
  const RecurringPaymentSection({super.key});

  @override
  ConsumerState<RecurringPaymentSection> createState() =>
      _RecurringPaymentSectionState();
}

class _RecurringPaymentSectionState
    extends ConsumerState<RecurringPaymentSection> {
  @override
  Widget build(BuildContext context) {
    var recurringTransactionsAsync = ref.watch(recurringTransactionsProvider);

    return Column(
      children: [
        recurringTransactionsAsync.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return const Text(
                "All recurring payments will be displayed here",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              );
            }
            return ListView.separated(
              itemCount: transactions.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  ref
                      .read(recurringTransactionProvider.notifier)
                      .transactionSelect(transactions[index])
                      .whenComplete(() {
                        if (context.mounted) {
                          Navigator.of(context)
                              .pushNamed("/edit-recurring-transaction")
                              .then(
                                (value) =>
                                    ref.refresh(recurringTransactionProvider),
                              );
                        }
                      });
                },
                child: RecurringPaymentCard(transaction: transactions[index]),
              ),
              separatorBuilder: (context, index) =>
                  const SizedBox(height: Sizes.lg),
            );
          },
          loading: () {
            return const CircularProgressIndicator();
          },
          error: (error, _) {
            return Text('Error: $error');
          },
        ),
        const SizedBox(height: Sizes.xxl),
        TextButton.icon(
          icon: const Icon(Icons.add_circle, size: 32),
          onPressed: () => {
            ref.read(selectedRecurringPayProvider.notifier).setValue(true),
            ref.read(selectedBankAccountProvider.notifier).setAccount(null),
            ref.read(selectedCategoryProvider.notifier).setCategory(null),
            ref.read(intervalProvider.notifier).setValue(Recurrence.monthly),
            ref.read(endDateProvider.notifier).setDate(null),
            Navigator.of(context)
                .pushNamed(
                  "/add-page",
                  arguments: {'recurrencyEditingPermitted': false},
                )
                .then((value) => ref.refresh(recurringTransactionProvider)),
          },
          label: const Text("Add recurring payment"),
        ),
        const SizedBox(height: Sizes.xxl),
      ],
    );
  }
}
