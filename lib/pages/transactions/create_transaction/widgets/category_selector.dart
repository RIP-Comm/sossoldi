import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/style.dart';
import '../../../../ui/widgets/rounded_icon.dart';
import '../../../../model/category_transaction.dart';
import '../../../../providers/categories_provider.dart';
import '../../../../providers/transactions_provider.dart';
import '../../../../ui/device.dart';

class CategorySelector extends ConsumerStatefulWidget {
  const CategorySelector({required this.scrollController, super.key});

  final ScrollController scrollController;

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  void _selectCategory(BuildContext context, CategoryTransaction category) {
    ref.read(selectedCategoryProvider.notifier).setCategory(category);
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final transactionType = ref.watch(selectedTransactionTypeProvider);
    final categoriesList = ref.watch(
      categoriesByTypeProvider(transactionType.categoryType),
    );
    final frequentCategories = ref.watch(
      frequentCategoriesProvider(transactionType.categoryType),
    );
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text("Category"),
            actions: [
              IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/add-category'),
                icon: const Icon(Icons.add_circle),
                splashRadius: 28,
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(
                      left: Sizes.lg,
                      top: Sizes.xxl,
                      bottom: Sizes.md,
                    ),
                    child: Text(
                      "MORE FREQUENT",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    height: 74,
                    width: double.infinity,
                    child: frequentCategories.when(
                      data: (categories) => ListView.builder(
                        itemCount: categories.length, // to prevent range error
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          CategoryTransaction category = categories[i];
                          return GestureDetector(
                            onTap: () => _selectCategory(context, category),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.lg,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RoundedIcon(
                                    icon: iconList[category.symbol],
                                    backgroundColor:
                                        categoryColorListTheme[category.color],
                                  ),
                                  Text(
                                    category.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(
                      left: Sizes.lg,
                      top: Sizes.xxl,
                      bottom: Sizes.sm,
                    ),
                    child: Text(
                      "ALL CATEGORIES",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  categoriesList.when(
                    data: (categories) => Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: ListView.separated(
                        itemCount: categories.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: grey1),
                        itemBuilder: (context, i) {
                          CategoryTransaction category = categories[i];
                          final subcategories = ref.watch(
                            subcategoriesProvider(category.id!),
                          );
                          return Column(
                            children: [
                              ListTile(
                                onTap: () => _selectCategory(context, category),
                                leading: RoundedIcon(
                                  icon: iconList[category.symbol],
                                  backgroundColor:
                                      categoryColorListTheme[category.color],
                                ),
                                title: Text(category.name),
                                trailing: selectedCategory?.id == category.id
                                    ? const Icon(Icons.check)
                                    : null,
                              ),
                              AnimatedCrossFade(
                                crossFadeState:
                                    selectedCategory?.id == category.id ||
                                        selectedCategory?.parent == category.id
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 150),
                                firstChild: const SizedBox.shrink(),
                                secondChild: subcategories.when(
                                  data: (data) {
                                    return ListView(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: data.map((subcategory) {
                                        return ListTile(
                                          contentPadding: const EdgeInsets.only(
                                            left: Sizes.xxl,
                                            right: Sizes.lg,
                                          ),
                                          onTap: () => _selectCategory(
                                            context,
                                            subcategory,
                                          ),
                                          leading: RoundedIcon(
                                            icon: iconList[subcategory.symbol],
                                            backgroundColor:
                                                categoryColorListTheme[subcategory
                                                    .color],
                                          ),
                                          title: Text(subcategory.name),
                                          trailing:
                                              ref
                                                      .watch(
                                                        selectedCategoryProvider,
                                                      )
                                                      ?.id ==
                                                  subcategory.id
                                              ? const Icon(Icons.check)
                                              : null,
                                        );
                                      }).toList(),
                                    );
                                  },
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (err, stack) => Text('Error: $err'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
