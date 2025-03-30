import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';

Future<void> showDeleteCategoryDialog(
    BuildContext context, WidgetRef ref, selectedCategory) async {
  void backToCategoryList() {
    if (context.mounted) {
      Navigator.of(context)
          .popUntil((route) => route.settings.name == '/category-list');
    }
  }

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'With "Mark as deleted," transitions with the category will be available, but new ones cannot be created\n',
              ),
              Text(
                'With "Delete" all transitions with that category will automatically be "Uncategorized"',
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
                ref
                    .read(categoriesProvider(userCategoriesFilter).notifier)
                    .markAsDeleted(selectedCategory.id)
                    .whenComplete(backToCategoryList);
                ref.invalidate(categoriesProvider(userCategoriesFilter));
                ref.invalidate(categoryByIdProvider);
              }),
          TextButton(
              child: Text(
                "Delete",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              onPressed: () async {
                ref
                    .read(categoriesProvider(userCategoriesFilter).notifier)
                    .removeCategory(selectedCategory.id!)
                    .whenComplete(backToCategoryList);
                ref.invalidate(categoriesProvider(userCategoriesFilter));
                ref.invalidate(categoryByIdProvider);
              }),
        ],
      );
    },
  );
}
