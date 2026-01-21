import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../ui/device.dart';
import 'widgets/category_icon_color_selector.dart';

class CreateEditSubcategoryPage extends ConsumerStatefulWidget {
  final CategoryTransaction category;

  const CreateEditSubcategoryPage({super.key, required this.category});

  @override
  ConsumerState<CreateEditSubcategoryPage> createState() =>
      _CreateEditSubcategoryPage();
}

class _CreateEditSubcategoryPage
    extends ConsumerState<CreateEditSubcategoryPage> {
  final TextEditingController nameController = TextEditingController();
  late CategoryTransactionType categoryType;
  String categoryIcon = iconList.keys.first;
  int categoryColor = 0;

  @override
  void initState() {
    super.initState();

    categoryType = widget.category.type;
    categoryColor = widget.category.color;

    final selectedSubcategory = ref.read(selectedSubcategoryProvider);
    if (selectedSubcategory != null) {
      nameController.text = selectedSubcategory.name;
      categoryType = selectedSubcategory.type;
      categoryIcon = selectedSubcategory.symbol;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSubcategory = ref.watch(selectedSubcategoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${selectedSubcategory == null ? "New" : "Edit"} Subcategory",
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      persistentFooterDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 5.0,
            offset: const Offset(0, -1.0),
          ),
        ],
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Sizes.sm,
            Sizes.xs,
            Sizes.sm,
            Sizes.sm,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              boxShadow: [defaultShadow],
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
            ),
            child: ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  if (selectedSubcategory != null) {
                    await ref
                        .read(categoriesProvider.notifier)
                        .updateSubcategory(
                          name: nameController.text,
                          icon: categoryIcon,
                        );
                  } else {
                    await ref
                        .read(categoriesProvider.notifier)
                        .addSubcategory(
                          name: nameController.text,
                          icon: categoryIcon,
                        );
                  }
                  // Result from the .pop is used in lib\pages\planning_page\manage_budget_page.dart.
                  //
                  // If the category has been created correctly, result is true.
                  if (context.mounted) Navigator.of(context).pop(true);
                }
              },
              child: Text(
                "${selectedSubcategory == null ? "CREATE" : "UPDATE"} SUBCATEGORY",
              ),
            ),
          ),
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                horizontal: Sizes.lg,
                vertical: Sizes.md,
              ),
              padding: const EdgeInsets.fromLTRB(
                Sizes.lg,
                Sizes.md,
                Sizes.lg,
                0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NAME",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: "Category name",
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            CategoryIconColorSelector(
              selectedIcon: categoryIcon,
              selectedColor: categoryColor,
              onIconChanged: (icon) => setState(() => categoryIcon = icon),
            ),
            if (selectedSubcategory != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Sizes.lg),
                child: TextButton.icon(
                  onPressed: () => ref
                      .read(categoriesProvider.notifier)
                      .removeCategory(selectedSubcategory.id!)
                      .whenComplete(() {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }),
                  style: TextButton.styleFrom(
                    side: const BorderSide(color: red, width: 1),
                  ),
                  icon: const Icon(Icons.delete_outlined, color: red),
                  label: Text(
                    "Delete subcategory",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
