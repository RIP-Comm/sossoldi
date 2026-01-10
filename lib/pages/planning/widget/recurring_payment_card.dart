import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';
import '../../../ui/extensions.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../../model/recurring_transaction.dart';
import '../../../providers/theme_provider.dart';
import '../../../ui/device.dart';
import 'older_recurring_payments.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/currency_provider.dart';

import '../../../constants/style.dart';
import '../../../providers/categories_provider.dart';

/// This class shows account summaries in dashboard
class RecurringPaymentCard extends ConsumerWidget {
  final RecurringTransaction transaction;

  const RecurringPaymentCard({super.key, required this.transaction});

  String getNextText() {
    final now = DateTime.now();
    final daysPassed = now
        .difference(transaction.lastInsertion ?? transaction.fromDate)
        .inDays;
    final daysInterval = transaction.recurrency.days;
    final daysUntilNextTransaction = daysInterval - (daysPassed % daysInterval);
    return daysUntilNextTransaction.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value;
    final accounts = ref.watch(accountsProvider).value;
    final isDarkMode = ref.watch(appThemeStateProvider).isDarkModeEnabled;
    final currencyState = ref.watch(currencyStateProvider);

    var category = categories?.firstWhereOrNull(
      (element) => element.id == transaction.idCategory,
    );

    return category != null
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
              color: Theme.of(context).colorScheme.primaryContainer,
              boxShadow: [defaultShadow],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.sm,
                vertical: Sizes.md,
              ),
              decoration: BoxDecoration(
                color: categoryColorList[category.color].withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
              ),
              child: Column(
                spacing: 16,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RoundedIcon(
                        icon: iconList[category.symbol],
                        backgroundColor: categoryColorList[category.color],
                        padding: const EdgeInsets.all(Sizes.sm),
                        size: 25,
                      ),
                      const SizedBox(width: Sizes.sm),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: Sizes.sm,
                          children: [
                            Text(
                              transaction.recurrency.label.toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              transaction.note,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              category.name.toUpperCase(),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: Sizes.sm,
                          children: [
                            Text(
                              "IN ${getNextText()} DAYS".toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Builder(
                              builder: (context) {
                                final Color amountColor = transaction.type
                                    .toColor(
                                      brightness: Theme.of(context).brightness,
                                    );
                                return Text(
                                  "${transaction.type.prefix}${transaction.amount}${currencyState.symbol}",
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: amountColor),
                                );
                              },
                            ),
                            Text(
                              accounts!
                                  .firstWhere(
                                    (element) =>
                                        element.id == transaction.idBankAccount,
                                  )
                                  .name
                                  .toUpperCase(),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
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
                                isScrollControlled: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                      Sizes.borderRadiusLarge,
                                    ),
                                    topRight: Radius.circular(
                                      Sizes.borderRadiusLarge,
                                    ),
                                  ),
                                ),
                                elevation: Sizes.sm,
                                builder: (BuildContext context) {
                                  return FractionallySizedBox(
                                    heightFactor: 0.9,
                                    child: OlderRecurringPayments(
                                      transaction: transaction,
                                    ),
                                  );
                                },
                              ),
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              foregroundColor: isDarkMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              iconColor: isDarkMode
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              overlayColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.sm,
                                vertical: Sizes.xs,
                              ),
                            ),
                            icon: const Icon(Icons.checklist_rtl_outlined),
                            label: const Text(
                              "See older payments",
                              style: TextStyle(fontSize: 14),
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
                              "Until ${transaction.toDate?.formatEDMY()}",
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
