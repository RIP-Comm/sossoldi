import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';
import '../../../custom_widgets/rounded_icon.dart';
import '../../../model/recurring_transaction.dart';
import '../../../providers/theme_provider.dart';
import '../../../ui/device.dart';
import 'older_recurring_payments.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/currency_provider.dart';

import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../model/transaction.dart';
import '../../../providers/categories_provider.dart';

/// This class shows account summaries in dashboard
class RecurringPaymentCard extends ConsumerWidget with Functions {
  final RecurringTransaction transaction;

  const RecurringPaymentCard({
    super.key,
    required this.transaction,
  });

  String getNextText() {
    final now = DateTime.now();
    final daysPassed = now
        .difference(transaction.lastInsertion ?? transaction.fromDate)
        .inDays;
    final daysInterval =
        recurrenceMap[parseRecurrence(transaction.recurrency)]!.days;
    final daysUntilNextTransaction = daysInterval - (daysPassed % daysInterval);
    return daysUntilNextTransaction.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value;
    final accounts = ref.watch(accountsProvider).value;
    final isDarkMode = ref.watch(appThemeStateNotifier).isDarkModeEnabled;
    final currencyState = ref.watch(currencyStateNotifier);

    var cat = categories
        ?.firstWhereOrNull((element) => element.id == transaction.idCategory);

    return cat != null
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
              color: Theme.of(context).colorScheme.primaryContainer,
              boxShadow: [defaultShadow],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: categoryColorList[cat.color].withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
              ),
              child: Column(
                spacing: 16,
                children: [
                  Row(
                    children: [
                      RoundedIcon(
                        icon: iconList[cat.symbol],
                        backgroundColor: categoryColorList[cat.color],
                        padding: const EdgeInsets.all(8.0),
                        size: 25,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                transaction.recurrency,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w200,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                transaction.note,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(cat.name),
                            ],
                          )),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("In ${getNextText()} days"),
                            const SizedBox(height: 10),
                            Text(
                                "-${transaction.amount}${currencyState.selectedCurrency.symbol}",
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 10),
                            Text(accounts!
                                .firstWhere((element) =>
                                    element.id == transaction.idBankAccount)
                                .name),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: () => {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(Sizes.borderRadiusLarge),
                                    topRight: Radius.circular(Sizes.borderRadiusLarge),
                                  ),
                                ),
                                elevation: 10,
                                builder: (BuildContext context) {
                                  return ListView(
                                    scrollDirection: Axis.vertical,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 10,
                                    ),
                                    children: [
                                      OlderRecurringPayments(
                                        transaction: transaction,
                                      ),
                                    ],
                                  );
                                },
                              )
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              foregroundColor: isDarkMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              iconColor: isDarkMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              overlayColor:
                                  Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            icon: Icon(
                              Icons.checklist_rtl_outlined,
                            ),
                            label: Text(
                              "See older payments",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (transaction.toDate != null)
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Until ${dateToString(transaction.toDate!)}",
                              style: const TextStyle(fontSize: 8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
