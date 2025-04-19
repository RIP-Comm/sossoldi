import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import '../constants/functions.dart';
import "../constants/style.dart";
import '../providers/theme_provider.dart';
import '../providers/transactions_provider.dart';
import '../model/transaction.dart';
import '../features/add_page/presentation/recurrence_selector.dart';

class RecurrenceListTileEdit extends ConsumerWidget with Functions {
  const RecurrenceListTileEdit({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appThemeStateNotifier).isDarkModeEnabled;
    final isRecurring = ref.watch(selectedRecurringPayProvider);
    final endDate = ref.watch(endDateProvider);

    return Column(
      children: [
        const Divider(),
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
                color: white,
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
        ),
        if (isRecurring) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(16),
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
                    recurrenceMap[ref.watch(intervalProvider)]!.label,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isDarkMode
                            ? grey3
                            : Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right,
                    color: isDarkMode
                        ? grey3
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: () => showModalBottomSheet(
                context: context,
                elevation: 10,
                builder: (BuildContext context) {
                  return const EndDateSelector();
                },
              ),
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
                    endDate != null ? dateToString(endDate) : "Never",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: isDarkMode
                            ? grey3
                            : Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right,
                    color: isDarkMode
                        ? grey3
                        : Theme.of(context).colorScheme.secondary,
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

class EndDateSelector extends ConsumerWidget with Functions {
  const EndDateSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: [
            ListTile(
              visualDensity: const VisualDensity(vertical: -3),
              trailing: ref.watch(endDateProvider) != null
                  ? null
                  : const Icon(Icons.check),
              title: const Text(
                "Never",
              ),
              onTap: () => {
                ref.read(endDateProvider.notifier).state = null,
                Navigator.pop(context)
              },
            ),
            ListTile(
                visualDensity: const VisualDensity(vertical: -3),
                title: const Text("On a date"),
                trailing: ref.watch(endDateProvider) != null
                    ? const Icon(Icons.check)
                    : null,
                subtitle: Text(ref.read(endDateProvider) != null
                    ? dateToString(ref.read(endDateProvider.notifier).state!)
                    : ''),
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (Platform.isIOS) {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (_) => Container(
                        height: 300,
                        color: white,
                        child: CupertinoDatePicker(
                          initialDateTime: ref.watch(endDateProvider),
                          minimumYear: 2015,
                          maximumYear: 2050,
                          mode: CupertinoDatePickerMode.date,
                          onDateTimeChanged: (date) =>
                              ref.read(endDateProvider.notifier).state = date,
                        ),
                      ),
                    );
                  } else if (Platform.isAndroid) {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: ref.watch(endDateProvider),
                      firstDate: DateTime(2015),
                      lastDate: DateTime(2050),
                    );
                    if (pickedDate != null) {
                      ref.read(endDateProvider.notifier).state = pickedDate;
                    }
                  }
                })
          ],
        ));
  }
}
