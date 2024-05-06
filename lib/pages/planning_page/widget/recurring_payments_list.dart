import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/pages/planning_page/widget/recurring_payment_card.dart';
import 'package:sossoldi/providers/transactions_provider.dart';

import '../../../model/recurring_transaction.dart';
import '../../../model/transaction.dart';

class RecurringPaymentSection extends ConsumerStatefulWidget {
  const RecurringPaymentSection({super.key});

  @override
  ConsumerState<RecurringPaymentSection> createState() =>
      _RecurringPaymentSectionState();
}

class _RecurringPaymentSectionState extends ConsumerState<RecurringPaymentSection> {
  Future<List<RecurringTransaction>> recurringTransactions = RecurringTransactionMethods().selectAllActive();

  _refreshData() {
    recurringTransactions = RecurringTransactionMethods().selectAllActive();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
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
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
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
                                Navigator.of(context).pushNamed("/edit-recurring-transaction").then((value) => setState(() { _refreshData(); }));
                              });
                        },
                        child: RecurringPaymentCard(
                            transaction: transactions[index])),
                    separatorBuilder: (context, index) => const Divider(),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(
                Icons.add_circle,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () => {
                ref.read(selectedRecurringPayProvider.notifier).state = true,
                ref.read(intervalProvider.notifier).state = Recurrence.weekly,
                Navigator.of(context).pushNamed("/add-page").then((value) => setState(() { _refreshData(); }))
              },
              label: Text(
                "Add recurring payment",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .apply(color: Theme.of(context).colorScheme.secondary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: const Size(330, 50),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
