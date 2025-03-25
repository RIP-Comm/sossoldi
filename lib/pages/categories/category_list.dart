import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/functions.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../custom_widgets/default_card.dart';
import '../../custom_widgets/rounded_icon.dart';

class CategoryList extends ConsumerStatefulWidget {
  const CategoryList({super.key});

  @override
  ConsumerState<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<CategoryList> with Functions {
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
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(selectedCategoryProvider);
              Navigator.of(context).pushNamed('/add-category');
            },
            icon: const Icon(
              Icons.add_circle,
              size: 30,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            categorysList.when(
              data: (categorys) => ListView.separated(
                itemCount: categorys.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
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
                        const SizedBox(width: 12.0),
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
