import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'dart:io' show Platform;

import "../../../constants/style.dart";
import '../../../model/transaction.dart';

class RecurrenceListTile extends ConsumerWidget {
  const RecurrenceListTile({
    required this.isRecurring,
    required this.recurringProvider,
    required this.intervalProvider,
    Key? key,
  }) : super(key: key);

  final bool isRecurring;
  final StateProvider<bool> recurringProvider;
  final StateProvider<Recurrence> intervalProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          trailing: (Platform.isIOS)
              ? CupertinoSwitch(
                  value: isRecurring,
                  onChanged: (select) =>
                      ref.read(recurringProvider.notifier).state = select,
                )
              : Switch(
                  value: isRecurring,
                  onChanged: (select) =>
                      ref.read(recurringProvider.notifier).state = select,
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
              onPressed: () =>
                  Navigator.of(context).pushNamed('/recurrenceselect'),
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
