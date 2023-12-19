import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                Text(AppLocalizations.of(context)!.recurrentSubTitle,
                    style:
                        const TextStyle(fontWeight: FontWeight.normal, fontSize: 13)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: addRecurringPayment,
                  label: Text(
                    AppLocalizations.of(context)!.recurrentSubTitle,
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
            )));
  }
}
