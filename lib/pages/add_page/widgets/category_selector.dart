import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/transactions_provider.dart';

class CategorySelector extends ConsumerStatefulWidget {
  const CategorySelector({Key? key}) : super(key: key);

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  @override
  Widget build(BuildContext context) {
    final categoriesList = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: categoriesList.when(
          data: (categories) => ListView.builder(
            itemCount: categories.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              CategoryTransaction category = categories[i];
              return Material(
                child: InkWell(
                  onTap: () => ref.read(categoryProvider.notifier).state = category,
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(32, 20, 20, 20),
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          IconData(int.parse(category.symbol), fontFamily: 'MaterialIcons'),
                          size: 24.0,
                          color: Theme.of(context).colorScheme.background,
                        ),
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    trailing: ref.watch(categoryProvider)?.id == category.id
                        ? Icon(Icons.done, color: Theme.of(context).colorScheme.secondary)
                        : null,
                  ),
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
        ),
      ),
    );
  }
}
