import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import '../../../shared/constants/functions.dart';
import "../../../shared/constants/style.dart";
import '../../../shared/widgets/rounded_icon.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/transactions_provider.dart';
import '../../../shared/models/transaction.dart';
import 'recurrence_selector.dart';

class RecurrenceListTile extends ConsumerWidget with Functions {
  final bool recurrencyEditingPermitted;
  final Transaction? selectedTransaction;

  const RecurrenceListTile({
    super.key,
    required this.recurrencyEditingPermitted,
    required this.selectedTransaction, // Add this line
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appThemeStateNotifier).isDarkModeEnabled;
    final isRecurring = ref.watch(selectedRecurringPayProvider);
    final endDate = ref.watch(endDateProvider);
    bool isSnackBarVisible = false;

    return Column(
      children: [
        const Divider(),
        ListTile(
          leading: RoundedIcon(
            icon: Icons.autorenew,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          title: Text(
            "Recurring payment",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          trailing: recurrencyEditingPermitted
              ? Switch.adaptive(
                  value: isRecurring,
                  onChanged: (select) => ref
                      .read(selectedRecurringPayProvider.notifier)
                      .state = select,
                )
              : GestureDetector(
                  onTap: () {
                    if (!isSnackBarVisible) {
                      isSnackBarVisible = true;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                            const SnackBar(
                              content: Text('Switch is disabled'),
                              duration: Duration(milliseconds: 800),
                            ),
                          )
                          .closed
                          .then((_) {
                        isSnackBarVisible = false;
                      });
                    }
                  },
                  child: Tooltip(
                    message: 'Switch is disabled',
                    child: Switch.adaptive(
                      value: isRecurring,
                      onChanged: null, // This makes the switch read-only
                    ),
                  ),
                ),
        ),
        if (isRecurring) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Opacity(
              opacity: selectedTransaction == null || recurrencyEditingPermitted
                  ? 1.0
                  : 0.5,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed:
                    selectedTransaction == null || recurrencyEditingPermitted
                        ? () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => const RecurrenceSelector(),
                            );
                          }
                        : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Interval",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary),
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
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Opacity(
              opacity: selectedTransaction == null || recurrencyEditingPermitted
                  ? 1.0
                  : 0.5,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed:
                    selectedTransaction == null || recurrencyEditingPermitted
                        ? () => showModalBottomSheet(
                              context: context,
                              elevation: 10,
                              builder: (BuildContext context) {
                                return const EndDateSelector();
                              },
                            )
                        : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "End repetition",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary),
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
          ),
          if (selectedTransaction != null && !recurrencyEditingPermitted) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(
                    "/edit-recurring-transaction",
                    arguments: selectedTransaction,
                  )
                      .then((value) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'This is a transaction generated by a recurring one: any change will affect this unique transaction.\nTo change all future transactions options, or recurrency options, TAP HERE',
                        style: TextStyle(
                          color: darkBlue5,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
              title: const Text("Never"),
              onTap: () {
                ref.read(endDateProvider.notifier).state = null;
                Navigator.pop(context);
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
