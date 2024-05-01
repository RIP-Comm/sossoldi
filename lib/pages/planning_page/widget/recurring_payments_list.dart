import 'package:flutter/material.dart';
import 'package:sossoldi/pages/planning_page/widget/recurring_payment_card.dart';

import '../../../model/recurring_transaction.dart';

class RecurringPaymentSection extends StatefulWidget {
  const RecurringPaymentSection({super.key});

  @override
  State<RecurringPaymentSection> createState() =>
      _RecurringPaymentSectionState();
}

class _RecurringPaymentSectionState extends State<RecurringPaymentSection> {
  Future<List<RecurringTransaction>> recurringTransactions =
      RecurringTransactionMethods().selectAllActive();

  void addRecurringPayment() {
    print("addRecurringPayment");
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
                    itemBuilder: (context, index) =>
                        RecurringPaymentCard(transaction: transactions[index]),
                    separatorBuilder: (context, index) => const Divider(),
                  );
                }
              },
            ),
            ElevatedButton.icon(
              icon: Icon(
                Icons.add_circle,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: addRecurringPayment,
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
            )
          ],
        ),
      ),
    );
  }
}
