import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import 'recurring_payment_card.dart';
import '../../../model/recurring_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/default_container.dart';

class RecurringPaymentSection extends ConsumerWidget {
  const RecurringPaymentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var recurringTransactionsAsync = ref.watch(recurringTransactionsProvider);

    void addRecurringPayment() {
      ref.read(selectedRecurringPayProvider.notifier).setValue(true);
      ref.read(selectedBankAccountProvider.notifier).setAccount(null);
      ref.read(selectedCategoryProvider.notifier).setCategory(null);
      ref.read(intervalProvider.notifier).setValue(Recurrence.monthly);
      ref.read(endDateProvider.notifier).setDate(null);
      Navigator.of(context).pushNamed(
        "/add-page",
        arguments: {'recurrencyEditingPermitted': false},
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.xxl),
      child: recurringTransactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return SizedBox(
              width: double.infinity,
              child: DefaultContainer(
                margin: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: Sizes.lg,
                  children: [
                    Text(
                      "All recurring payments will be displayed here",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Sizes.borderRadius),
                        boxShadow: [defaultShadow],
                      ),
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.add_circle,
                          color: Theme.of(context).colorScheme.secondary,
                          size: Sizes.xl,
                        ),
                        onPressed: addRecurringPayment,
                        label: Text(
                          "Add recurring payment",
                          style: Theme.of(context).textTheme.titleLarge!.apply(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.md,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            spacing: Sizes.xxl,
            children: [
              ListView.separated(
                itemCount: transactions.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    ref
                        .read(recurringTransactionsProvider.notifier)
                        .transactionSelect(transactions[index])
                        .whenComplete(() {
                          if (context.mounted) {
                            Navigator.of(
                              context,
                            ).pushNamed("/edit-recurring-transaction");
                          }
                        });
                  },
                  child: RecurringPaymentCard(transaction: transactions[index]),
                ),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: Sizes.lg),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_circle, size: 32),
                onPressed: addRecurringPayment,
                label: const Text("Add recurring payment"),
              ),
            ],
          );
        },
        loading: () {
          return const CircularProgressIndicator();
        },
        error: (error, _) {
          return Text('Error: $error');
        },
      ),
    );
  }
}
