import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../constants/functions.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/transactions_provider.dart';

class CategorySelector extends ConsumerStatefulWidget {
  const CategorySelector({Key? key}) : super(key: key);

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> with Functions {
  @override
  Widget build(BuildContext context) {
    final categoriesList = ref.watch(categoriesProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Category"),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/add-category'),
            icon: const Icon(Icons.add_circle),
            splashRadius: 28,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16, top: 32, bottom: 8),
              child: Text(
                "MORE FREQUENT",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Container(
              color: Theme.of(context).colorScheme.surface,
              height: 74,
              width: double.infinity,
              child: categoriesList.when(
                data: (categories) => ListView.builder(
                  itemCount: 4,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    CategoryTransaction category = categories[i];
                    IconData? icon = iconList[category.symbol];
                    Color? color = categoryColorList[category.color];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: icon != null
                                ? Icon(
                                    icon,
                                    size: 24.0,
                                    color: Theme.of(context).colorScheme.background,
                                  )
                                : const SizedBox(),
                          ),
                          Text(
                            category.name,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error: $err'),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16, top: 32, bottom: 8),
              child: Text(
                "ALL CATEGORIES",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            categoriesList.when(
              data: (categories) => ListView.separated(
                itemCount: categories.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(height: 1, color: grey1),
                itemBuilder: (context, i) {
                  CategoryTransaction category = categories[i];
                  IconData? icon = iconList[category.symbol];
                  Color? color = categoryColorList[category.color];
                  return Material(
                    color: Theme.of(context).colorScheme.surface,
                    child: InkWell(
                      onTap: () => ref.read(categoryProvider.notifier).state = category,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: icon != null
                              ? Icon(
                                  icon,
                                  size: 24.0,
                                  color: Theme.of(context).colorScheme.background,
                                )
                              : const SizedBox(),
                        ),
                        title: Text(
                          category.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
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
          ],
        ),
      ),
    );
  }
}
