import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../constants/style.dart";
import '../../../providers/transactions_provider.dart';
import '../../../model/transaction.dart';
import 'recurrence_selector.dart';

class RecurrenceListTile extends ConsumerWidget {
  const RecurrenceListTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRecurring = ref.watch(selectedRecurringPayProvider);

    return Column(
      children: [
        const Divider(height: 1, color: grey1),
        ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Icons.autorenew,
                size: 24.0,
                color: Theme.of(context).colorScheme.background,
              ),
            ),
          ),
          title: Text(
            "Recurring payment",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          trailing: Switch.adaptive(
            value: isRecurring,
            onChanged: (select) =>
                ref.read(selectedRecurringPayProvider.notifier).state = select,
          ),
        ),
        if (isRecurring) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.background,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                showModalBottomSheet(
                  context: context,
                  builder: (_) => const RecurrenceSelector(),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Interval",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  const Spacer(),
                  Text(
                    recurrenceMap[ref.watch(intervalProvider)]!,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.background,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "End repetition",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  const Spacer(),
                  Text(
                    "Never",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
        ]
      ],
    );
  }
}
