import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/rounded_icon.dart';

class SubcategoriesList extends ConsumerWidget {
  const SubcategoriesList({super.key, required this.category});

  final CategoryTransaction category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subcategoriesAsync = ref.watch(subcategoriesProvider(category.id!));
    return subcategoriesAsync.when(
      data: (subcategories) {
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => const Divider(),
          shrinkWrap: true,
          itemCount: subcategories.length + 1,
          itemBuilder: (context, index) {
            if (index == subcategories.length) {
              // Add New Subcategory Button
              return Material(
                child: InkWell(
                  onTap: () {
                    ref.invalidate(selectedSubcategoryProvider);
                    Navigator.of(context).pushNamed(
                      '/add-subcategory',
                      arguments: {'category': category},
                    );
                  },
                  child: Ink(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      spacing: Sizes.md,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 30,
                          color: grey1,
                        ),
                        Text(
                          "Add subcategory",
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall!.copyWith(color: grey1),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final subcategory = subcategories[index];
            return Material(
              child: InkWell(
                onTap: () {
                  ref
                      .read(selectedSubcategoryProvider.notifier)
                      .setCategory(subcategory);
                  Navigator.of(context).pushNamed(
                    '/add-subcategory',
                    arguments: {'category': subcategory},
                  );
                },
                child: Ink(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    spacing: Sizes.md,
                    children: [
                      RoundedIcon(
                        icon: iconList[subcategory.symbol],
                        backgroundColor:
                            categoryColorListTheme[subcategory.color],
                        size: 24,
                        padding: const EdgeInsets.all(Sizes.sm),
                      ),
                      Text(
                        subcategory.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
