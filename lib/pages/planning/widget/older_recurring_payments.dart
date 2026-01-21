import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../model/category_transaction.dart';
import '../../../model/currency.dart';
import '../../../model/recurring_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/recurring_transactions_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../../ui/widgets/default_container.dart';
import '../../../ui/widgets/rounded_icon.dart';

class OlderRecurringPayments extends ConsumerWidget {
  const OlderRecurringPayments({super.key, required this.transaction});

  final RecurringTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String nextDueDay = getNextDueDay();
    final currencyState = ref.watch(currencyStateProvider);
    final categories = ref.watch(categoriesProvider).value;
    final category = categories?.firstWhereOrNull(
      (element) => element.id == transaction.idCategory,
    );
    final recurringPayments = ref.watch(
      recurringPaymentsProvider(transaction.id!),
    );

    // Handle null category case
    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Older payments"), centerTitle: true),
        body: const Center(child: Text("Category not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Older payments"),
        centerTitle: true,
        leadingWidth: 80.0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              const SizedBox(width: Sizes.sm),
              const Icon(Icons.arrow_back_ios),
              Text(
                "Back",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: darkBlue5),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Sizes.lg),
            _CategoryHeader(
              category: category,
              transaction: transaction,
              currency: currencyState,
            ),
            const SizedBox(height: Sizes.sm),
            Text(
              "${transaction.recurrency.label}"
              " - On the $nextDueDay day",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: Sizes.xl),
            Expanded(
              child: recurringPayments.when(
                data: (transactions) {
                  return transactions.isNotEmpty
                      ? ListView.separated(
                          itemCount: transactions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: Sizes.lg),
                          itemBuilder: (ctx, index) {
                            var yearTransactions = transactions[index];
                            var year = yearTransactions.year;
                            var monthlyEntries =
                                yearTransactions.transactionsByMonth;
                            var totalyearlyAmt = monthlyEntries.values.sum;

                            return DefaultContainer(
                              margin: EdgeInsets.zero,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: Sizes.sm,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: Sizes.lg,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '$year',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        ),
                                        const Spacer(),
                                        _buildAmountText(
                                          context,
                                          totalyearlyAmt,
                                          currencyState.symbol,
                                        ),
                                      ],
                                    ),
                                  ),
                                  monthlyEntries.isNotEmpty
                                      ? Container(
                                          padding: const EdgeInsets.all(
                                            Sizes.md,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(
                                              Sizes.borderRadius,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              Sizes.borderRadius,
                                            ),
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              itemCount: monthlyEntries.length,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (ctx, index) {
                                                var month = monthlyEntries.keys
                                                    .toList()[index];
                                                var montlyAmt =
                                                    monthlyEntries[month];

                                                return Container(
                                                  padding: const EdgeInsets.all(
                                                    Sizes.md,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(month),
                                                      const Spacer(),
                                                      _buildAmountText(
                                                        context,
                                                        montlyAmt,
                                                        currencyState.symbol,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              separatorBuilder: (ctx, index) {
                                                return const SizedBox(
                                                  height: Sizes.xxs,
                                                  child: Divider(
                                                    thickness: 0.3,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: double.infinity,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          child: Center(
                                            child: Text(
                                              "No Montly payment history",
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "No recurrent payment history",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text(
                    "Error loading payments: $error",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getNextDueDay() {
    final now = DateTime.now();
    final daysPassed = now
        .difference(transaction.lastInsertion ?? transaction.fromDate)
        .inDays;
    final daysInterval = transaction.recurrency.days;
    final daysUntilNextTransaction = daysInterval - (daysPassed % daysInterval);
    return ordinal(daysUntilNextTransaction);
  }

  String ordinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  // Reusable amount display
  Widget _buildAmountText(
    BuildContext context,
    num? amount,
    String currencySymbol,
  ) {
    return Row(
      children: [
        Text(
          '${transaction.type.prefix}${(amount ?? 0).toCurrency()}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: transaction.type.toColor(
              brightness: Theme.of(context).brightness,
            ),
          ),
        ),
        Text(
          currencySymbol,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: transaction.type.toColor(
              brightness: Theme.of(context).brightness,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.category,
    required this.transaction,
    required this.currency,
  });

  final CategoryTransaction category;
  final RecurringTransaction transaction;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedIcon(
          icon: iconList[category.symbol] ?? Icons.help_outline,
          backgroundColor: categoryColorList[category.color],
          padding: const EdgeInsets.all(Sizes.sm),
          size: 56,
        ),
        const SizedBox(height: Sizes.sm),
        Text(transaction.note, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: Sizes.sm),
        Text(
          "${transaction.type.prefix}"
          "${transaction.amount}"
          "${currency.symbol}",
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
            color: transaction.type.toColor(
              brightness: Theme.of(context).brightness,
            ),
          ),
        ),
      ],
    );
  }
}
