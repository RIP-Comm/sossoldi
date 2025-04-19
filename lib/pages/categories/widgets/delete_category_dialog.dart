import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/budgets_provider.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/statistics_provider.dart';
import '../../../providers/transactions_provider.dart';

Future<void> showDeleteCategoryDialog(
    BuildContext context, WidgetRef ref, selectedCategory) async {
  
  void backToCategoryList() {
    if (context.mounted) {
      Navigator.of(context)
          .popUntil((route) => route.settings.name == '/category-list');
    }
  }

  void invalidateProviders() {
    ref.invalidate(categoriesProvider(userCategoriesFilter));
    ref.invalidate(categoryByIdProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(budgetsProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(lastTransactionsProvider);
    ref.invalidate(statisticsProvider);
  }

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                "Mark as deleted: Category remains available for existing transitions but cannot be used for new ones.\n",
              ),
              Text(
                "Delete: All transitions using this category will be automatically changed to 'Uncategorized'.\n",
              ),
              Text(
                "Both options will delete budgets with the specified category.",
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                "Mark as deleted",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () async {
                await ref
                    .read(categoriesProvider(userCategoriesFilter).notifier)
                    .markAsDeleted(selectedCategory.id);
                invalidateProviders();
                backToCategoryList();
              }),
          TextButton(
              child: Text(
                "Delete",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () async {
                 await ref
                    .read(categoriesProvider(userCategoriesFilter).notifier)
                    .removeCategory(selectedCategory.id!);
                invalidateProviders();
                backToCategoryList();
              }),
        ],
      );
    },
  );
}
