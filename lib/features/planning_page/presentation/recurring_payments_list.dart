import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ui/device.dart';
import 'recurring_payment_card.dart';
import '../../../providers/transactions_provider.dart';

import '../../../model/recurring_transaction.dart';
import '../../../model/transaction.dart';

class RecurringPaymentSection extends ConsumerStatefulWidget {
  const RecurringPaymentSection({super.key});

  @override
  ConsumerState<RecurringPaymentSection> createState() =>
      _RecurringPaymentSectionState();
}

class _RecurringPaymentSectionState
    extends ConsumerState<RecurringPaymentSection> {
  Future<List<RecurringTransaction>> recurringTransactions =
      RecurringTransactionMethods().selectAllActive();

  _refreshData() {
    setState(() {
      recurringTransactions = RecurringTransactionMethods().selectAllActive();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<RecurringTransaction>>(
          future: recurringTransactions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData) {
              return const Text(
                "All recurring payments will be displayed here",
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              );
            } else {
              final transactions = snapshot.data;
              return ListView.separated(
                itemCount: transactions!.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    ref
                        .read(transactionsProvider.notifier)
                        .transactionUpdateState(transactions[index])
                        .whenComplete(() {
                      if (context.mounted) {
                        Navigator.of(context)
                            .pushNamed("/edit-recurring-transaction")
                            .then((value) => _refreshData());
                      }
                    });
                  },
                  child: RecurringPaymentCard(transaction: transactions[index]),
                ),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: Sizes.lg),
              );
            }
          },
        ),
        const SizedBox(height: Sizes.xxl),
        TextButton.icon(
          icon: Icon(Icons.add_circle, size: 32),
          onPressed: () => {
            ref.read(selectedTransactionUpdateProvider.notifier).state = null,
            ref.read(selectedRecurringPayProvider.notifier).state = true,
            ref.read(bankAccountProvider.notifier).state = null,
            ref.read(categoryProvider.notifier).state = null,
            ref.read(intervalProvider.notifier).state = Recurrence.monthly,
            ref.read(endDateProvider.notifier).state = null,
            Navigator.of(context).pushNamed(
              "/add-page",
              arguments: {'recurrencyEditingPermitted': false},
            ).then((value) => _refreshData())
          },
          label: Text("Add recurring payment"),
        ),
        const SizedBox(height: Sizes.xxl),
      ],
    );
  }
}
