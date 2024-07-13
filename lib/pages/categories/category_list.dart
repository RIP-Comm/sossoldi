import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/functions.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../custom_widgets/default_card.dart';

class CategoryList extends ConsumerStatefulWidget {
  const CategoryList({super.key});

  @override
  ConsumerState<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<CategoryList> with Functions {
  @override
  Widget build(BuildContext context) {
    final categorysList = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(categoriesProvider.notifier).reset();
              Navigator.of(context).pushNamed('/add-category');
            },
            icon: const Icon(Icons.add_circle),
            splashRadius: 28,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.list_alt,
                      size: 24.0,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    "Your categories",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
            categorysList.when(
              data: (categorys) => ListView.separated(
                itemCount: categorys.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  CategoryTransaction category = categorys[i];
                  IconData? icon = iconList[category.symbol];
                  Color? color = categoryColorListTheme[category.color];
                  return DefaultCard(
                    onTap: () {
                      ref.read(categoriesProvider.notifier).selectedCategory(category);
                      Navigator.of(context).pushNamed('/add-category');
                    },
                    child: Row(
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
                                  size: 30.0,
                                  color: Theme.of(context).colorScheme.surface,
                                )
                              : const SizedBox(),
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          category.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
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
          ],
        ),
      ),
    );
  }
}
