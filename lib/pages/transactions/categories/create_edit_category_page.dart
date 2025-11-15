import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../model/category_transaction.dart';
import '../../../providers/categories_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import '../../transactions/widgets/category_icon_color_selector.dart';

class CreateEditCategoryPage extends ConsumerStatefulWidget {
  final bool hideIncome;

  const CreateEditCategoryPage({super.key, this.hideIncome = false});

  @override
  ConsumerState<CreateEditCategoryPage> createState() =>
      _CreateEditCategoryPage();
}

class _CreateEditCategoryPage extends ConsumerState<CreateEditCategoryPage> {
  final TextEditingController nameController = TextEditingController();
  late CategoryTransactionType categoryType;
  String categoryIcon = iconList.keys.first;
  int categoryColor = 0;

  @override
  void initState() {
    super.initState();

    final transactionType = ref.read(transactionTypeProvider);
    categoryType = ref.read(transactionToCategoryProvider(transactionType)) ??
        CategoryTransactionType.expense;

    final selectedCategory = ref.read(selectedCategoryProvider);
    if (selectedCategory != null) {
      nameController.text = selectedCategory.name;
      categoryType = selectedCategory.type;
      categoryIcon = selectedCategory.symbol;
      categoryColor = selectedCategory.color;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("${selectedCategory == null ? "New" : "Edit"} Category"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          // Result from the .pop is used in lib\pages\planning_page\manage_budget_page.dart.
          //
          // If back button is pressed, no category has been added.
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: Sizes.lg,
                      vertical: Sizes.md,
                    ),
                    padding: const EdgeInsets.fromLTRB(
                        Sizes.lg, Sizes.md, Sizes.lg, 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius:
                          BorderRadius.circular(Sizes.borderRadiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NAME",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Category name",
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    padding: const EdgeInsets.fromLTRB(
                        Sizes.lg, Sizes.md, Sizes.lg, 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius:
                          BorderRadius.circular(Sizes.borderRadiusSmall),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TYPE",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        DropdownButton<CategoryTransactionType>(
                          value: categoryType,
                          underline: const SizedBox(),
                          isExpanded: true,
                          items: (widget.hideIncome
                                  ? [
                                      CategoryTransactionType.expense
                                    ] // Only show 'expense' if true
                                  : CategoryTransactionType
                                      .values) // Otherwise, show all values
                              .map((CategoryTransactionType type) {
                            return DropdownMenuItem<CategoryTransactionType>(
                              value: type,
                              child: Text(
                                type.toString().split('.').last.capitalize(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            );
                          }).toList(),
                          onChanged: (CategoryTransactionType? newType) {
                            if (newType != categoryType) {
                              setState(() => categoryType = newType!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  CategoryIconColorSelector(
                    selectedIcon: categoryIcon,
                    selectedColor: categoryColor,
                    onIconChanged: (icon) =>
                        setState(() => categoryIcon = icon),
                    onColorChanged: (color) =>
                        setState(() => categoryColor = color),
                  ),
                  /* temporary hided, see #178
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16, top: 32, bottom: 8),
                    child: Text(
                      "SUBCATEGORY",
                      style:
                          Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  Material(
                    child: InkWell(
                      onTap: () => print("click"),
                      child: Ink(
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.surface,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, size: 30, color: grey1),
                            const SizedBox(width: 12),
                            Text(
                              "Add subcategory",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(color: grey1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  */
                  if (selectedCategory != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Sizes.lg),
                      child: TextButton.icon(
                        onPressed: () => ref
                            .read(categoriesProvider.notifier)
                            .removeCategory(selectedCategory.id!)
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
                          "Delete category",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: red),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  blurRadius: 5.0,
                  offset: const Offset(0, -1.0),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(
                Sizes.xl, Sizes.md, Sizes.xl, Sizes.xl),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [defaultShadow],
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    if (selectedCategory != null) {
                      await ref
                          .read(categoriesProvider.notifier)
                          .updateCategory(
                            name: nameController.text,
                            type: categoryType,
                            icon: categoryIcon,
                            color: categoryColor,
                          );
                    } else {
                      await ref.read(categoriesProvider.notifier).addCategory(
                            name: nameController.text,
                            type: categoryType,
                            icon: categoryIcon,
                            color: categoryColor,
                          );
                    }
                    ref.invalidate(selectedCategoryProvider);
                    ref.invalidate(categoryMapProvider);
                    // Result from the .pop is used in lib\pages\planning_page\manage_budget_page.dart.
                    //
                    // If the category has been created correctly, result is true.
                    if (context.mounted) Navigator.of(context).pop(true);
                  }
                },
                child: Text(
                  "${selectedCategory == null ? "CREATE" : "UPDATE"} CATEGORY",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
