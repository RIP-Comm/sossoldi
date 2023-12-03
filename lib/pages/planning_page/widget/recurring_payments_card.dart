import 'package:flutter/material.dart';

import '../../../model/recurring_transaction_amount.dart';

class RecurringPaymentCard extends StatefulWidget {
  const RecurringPaymentCard({super.key});

  @override
  State<RecurringPaymentCard> createState() => _RecurringPaymentCardState();
}

class _RecurringPaymentCardState extends State<RecurringPaymentCard> {

  void addRecurringPayment() {
    print("addRecurringPayment");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                const Text("All recurring payments will be displayed here",
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 13)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                  onPressed: addRecurringPayment,
                  label: Text(
                    "Add recurring payment",
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .apply(color: Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    fixedSize: const Size(330, 50),
                  ),
                )
              ],
            )));
  }
}
