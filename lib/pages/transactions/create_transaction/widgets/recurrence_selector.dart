import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../model/recurring_transaction.dart';
import '../../../../providers/transactions_provider.dart';
import '../../../../ui/device.dart';

class RecurrenceSelector extends ConsumerStatefulWidget {
  const RecurrenceSelector({super.key});

  @override
  ConsumerState<RecurrenceSelector> createState() => _RecurrenceSelectorState();
}

class _RecurrenceSelectorState extends ConsumerState<RecurrenceSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView.builder(
          itemCount: Recurrence.values.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            Recurrence recurrence = Recurrence.values[i];
            return Material(
              child: InkWell(
                onTap: () =>
                    ref.read(intervalProvider.notifier).setValue(recurrence),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(
                    Sizes.xxl,
                    Sizes.lg,
                    Sizes.lg,
                    Sizes.lg,
                  ),
                  title: Text(
                    recurrence.label,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  trailing: ref.watch(intervalProvider) == recurrence
                      ? const Icon(Icons.check)
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
