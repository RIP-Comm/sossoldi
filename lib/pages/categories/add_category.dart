import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/constants.dart';
import '../../constants/functions.dart';
import '../../constants/style.dart';
import '../../model/category_transaction.dart';
import '../../providers/categories_provider.dart';

class AddCategory extends ConsumerStatefulWidget {
  final bool hideIncome;

  const AddCategory({super.key, this.hideIncome = false});

  @override
  ConsumerState<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends ConsumerState<AddCategory> with Functions {
  final TextEditingController nameController = TextEditingController();
  CategoryTransactionType categoryType = CategoryTransactionType.income;
  String categoryIcon = iconList.keys.first;
  int categoryColor = 0;

  bool showCategoryIcons = false;

  @override
  void initState() {
    if (widget.hideIncome) {
      categoryType = CategoryTransactionType.expense;
    }
    final selectedCategory = ref.read(selectedCategoryProvider);
    if (selectedCategory != null) {
      nameController.text = selectedCategory.name;
      categoryType = selectedCategory.type;
      categoryIcon = selectedCategory.symbol;
      categoryColor = selectedCategory.color;
    }
    super.initState();
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
          onPressed: () => Navigator.pop(context),
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
                        horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
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
                            hintStyle: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: grey2),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(0),
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: grey1),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
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
                                capitalizeFirstLetter(
                                    type.toString().split('.').last),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(color: grey1),
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
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "ICON AND COLOR",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(90)),
                            onTap: () =>
                                setState(() => showCategoryIcons = true),
                            child: Ink(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: categoryColorListTheme[categoryColor],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Icon(
                                iconList[categoryIcon],
                                size: 48,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "CHOOSE ICON",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 12),
                        if (showCategoryIcons)
                          const Divider(height: 1, color: grey1),
                        if (showCategoryIcons)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            color: Theme.of(context).colorScheme.surface,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: TextButton(
                                    onPressed: () => setState(
                                        () => showCategoryIcons = false),
                                    child: Text(
                                      "Done",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                    ),
                                  ),
                                ),
                                GridView.builder(
                                  itemCount: iconList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 6),
                                  itemBuilder: (context, index) {
                                    IconData categoryIconData =
                                        iconList.values.elementAt(index);
                                    String categoryIconName =
                                        iconList.keys.elementAt(index);
                                    return GestureDetector(
                                      onTap: () => setState(() =>
                                          categoryIcon = categoryIconName),
                                      child: Container(
                                        margin: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: iconList[categoryIcon] ==
                                                  categoryIconData
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(4)),
                                        ),
                                        child: Icon(
                                          categoryIconData,
                                          color: iconList[categoryIcon] ==
                                                  categoryIconData
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          size: 24,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        const Divider(height: 1, color: grey1),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              Color color = categoryColorListTheme[index];
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => categoryColor = index),
                                child: Container(
                                  height:
                                      categoryColorListTheme[categoryColor] ==
                                              color
                                          ? 38
                                          : 32,
                                  width:
                                      categoryColorListTheme[categoryColor] ==
                                              color
                                          ? 38
                                          : 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: color,
                                    border:
                                        categoryColorListTheme[categoryColor] ==
                                                color
                                            ? Border.all(
                                                color: grey1,
                                                width: 3,
                                              )
                                            : null,
                                  ),
                                ),
                              );
                            },
                            itemCount: categoryColorListTheme.length,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "CHOOSE COLOR",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
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
                      padding: const EdgeInsets.all(16),
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
                          padding: const EdgeInsets.all(16),
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
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 5.0,
                  offset: const Offset(0, -1.0),
                )
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                boxShadow: [defaultShadow],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
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
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
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
