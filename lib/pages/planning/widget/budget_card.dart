import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../ui/extensions.dart';
import '../../../ui/widgets/default_container.dart';
import '../../../providers/budgets_provider.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/assets.dart';
import '../../../ui/device.dart';
import '../../graphs/widgets/linear_progress_bar.dart';
import '../manage_budget_page.dart';
import 'budget_pie_chart.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final transactionsAsync = ref.watch(monthlyTransactionsProvider);
    final categories = ref.watch(allParentCategoriesProvider).value ?? [];
    final currencyState = ref.watch(currencyStateProvider);
    var l10n = AppLocalizations.of(context)!;

    return DefaultContainer(
      margin: EdgeInsets.zero,
      child: budgetsAsync.when(
        data: (budgets) {
          return budgets.isNotEmpty
              ? transactionsAsync.when(
                  data: (transactions) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.composition,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        BudgetPieChart(
                          budgets: budgets,
                          categories: categories,
                        ),
                        Text(
                          l10n.progress,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: Sizes.sm),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: budgets.length,
                          itemBuilder: (BuildContext context, int index) {
                            final budget = budgets[index];
                            num spent = num.parse(
                              transactions
                                  .where(
                                    (t) =>
                                        t.idCategory == budget.idCategory ||
                                        t.categoryParent == budget.idCategory,
                                  )
                                  .fold(0.0, (sum, t) => sum + t.amount)
                                  .toCurrency(),
                            );
                            CategoryTransaction category = categories
                                .firstWhere(
                                  (cat) => cat.id == budget.idCategory,
                                );
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      budget.name!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (spent >= (budget.amountLimit * 0.9))
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                    Text(
                                      "$spent/${budget.amountLimit.toCurrency()}${currencyState.symbol}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Sizes.xs),
                                LinearProgressBar(
                                  type: BarType.category,
                                  colorIndex: category.color,
                                  amount:
                                      (spent == 0 || budget.amountLimit == 0)
                                      ? 0
                                      : spent,
                                  total: budget.amountLimit,
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: Sizes.lg);
                          },
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) {
                    return Text(l10n.errorOccurred(err));
                  },
                )
              : Column(
                  children: [
                    Text(
                      l10n.noBudgetSet,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    Image.asset(SossoldiAssets.wallet, width: 240, height: 240),
                    Text(
                      l10n.budgetHelpText,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Sizes.lg),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Sizes.borderRadius),
                        boxShadow: [defaultShadow],
                      ),
                      child: TextButton.icon(
                        icon: Icon(
                          Icons.add_circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          size: Sizes.xl,
                        ),
                        label: Text(
                          l10n.createBudget,
                          style: Theme.of(context).textTheme.titleLarge!.apply(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.md,
                          ),
                        ),
                        onPressed: () {
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
                            elevation: 10,
                            builder: (BuildContext context) {
                              return const FractionallySizedBox(
                                heightFactor: 0.9,
                                child: ManageBudgetPage(),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Text(l10n.errorOccurred(err)),
      ),
    );
  }
}
