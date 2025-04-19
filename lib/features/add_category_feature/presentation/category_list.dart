import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/constants.dart';
import '../../../shared/models/category_transaction.dart';
import '../../../shared/providers/categories_provider.dart';
import '../../../ui/widgets/default_card.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../../ui/device.dart';

class CategoryList extends ConsumerStatefulWidget {
  const CategoryList({super.key});

  @override
  ConsumerState<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<CategoryList> {
  @override
  Widget build(BuildContext context) {
    final categorysList = ref.watch(categoriesProvider);
    ref.listen(selectedCategoryProvider, (_, __) {});
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(selectedCategoryProvider);
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
              padding: const EdgeInsets.symmetric(
                  vertical: Sizes.xl, horizontal: Sizes.lg),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: const EdgeInsets.all(Sizes.sm),
                    child: Icon(
                      Icons.list_alt,
                      size: 24.0,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: Sizes.md),
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
                separatorBuilder: (context, index) =>
                    const SizedBox(height: Sizes.lg),
                itemBuilder: (context, i) {
                  CategoryTransaction category = categorys[i];
                  return DefaultCard(
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category;
                      Navigator.of(context).pushNamed('/add-category');
                    },
                    child: Row(
                      children: [
                        RoundedIcon(
                          icon: iconList[category.symbol],
                          backgroundColor:
                              categoryColorListTheme[category.color],
                          size: 30,
                        ),
                        const SizedBox(width: Sizes.md),
                        Text(
                          category.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
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
