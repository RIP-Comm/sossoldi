import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/constants.dart';
import '../../../../model/category_transaction.dart';
import '../../../../providers/categories_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/default_card.dart';
import '../../../ui/widgets/rounded_icon.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorysList = ref.watch(categoriesProvider);
    ref.listen(selectedCategoryProvider, (_, _) {});
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
                vertical: Sizes.xl,
                horizontal: Sizes.lg,
              ),
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
                    style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            categorysList.when(
              data: (categorys) => ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categorys.length,
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(categoriesProvider.notifier)
                      .reorderCategories(oldIndex, newIndex);
                },
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: 5,
                    color: Colors.transparent,
                    child: child,
                  );
                },
                itemBuilder: (context, i) {
                  CategoryTransaction category = categorys[i];
                  return Container(
                    key: ValueKey(category.id),
                    margin: const EdgeInsets.only(bottom: Sizes.lg),
                    child: DefaultCard(
                      onTap: () {
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .setCategory(category);
                        Navigator.of(context).pushNamed('/add-category');
                      },
                      child: Row(
                        spacing: Sizes.md,
                        children: [
                          RoundedIcon(
                            icon: iconList[category.symbol],
                            backgroundColor:
                                categoryColorListTheme[category.color],
                            size: 30,
                          ),
                          Expanded(
                            child: Text(
                              category.name,
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.drag_handle,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ],
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
