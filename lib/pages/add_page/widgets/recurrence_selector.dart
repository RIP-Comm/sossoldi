import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/transaction.dart';
import '../../../constants/functions.dart';
import '../../../providers/transactions_provider.dart';

class RecurrenceSelector extends ConsumerStatefulWidget {
  const RecurrenceSelector({super.key});

  @override
  ConsumerState<RecurrenceSelector> createState() => _RecurrenceSelectorState();
}

class _RecurrenceSelectorState extends ConsumerState<RecurrenceSelector> with Functions {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView.builder(
          itemCount: recurrenceMap.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            var j = 0;
            late Map<Recurrence, String> recurrence;
            recurrenceMap.forEach((key, value) {
              if (j == i) {
                recurrence = {key: value.label};
              }
              j++;
            });
            return Material(
              child: InkWell(
                onTap: () => ref.read(intervalProvider.notifier).state = recurrence.keys.first,
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(32, 20, 20, 20),
                  title: Text(
                    recurrence.values.first,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  trailing: ref.watch(intervalProvider) == recurrence.keys.first
                      ? Icon(Icons.check)
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
