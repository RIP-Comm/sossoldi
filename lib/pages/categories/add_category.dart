import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/constants.dart';
import '../../constants/functions.dart';
import '../../constants/style.dart';
import '../../providers/categories_provider.dart';

final showCategoryIconsProvider = StateProvider.autoDispose<bool>((ref) => false);

class AddCategory extends ConsumerStatefulWidget {
  const AddCategory({super.key});

  @override
  ConsumerState<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends ConsumerState<AddCategory> with Functions {
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    nameController.text = ref.read(selectedCategoryProvider)?.name ?? '';
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
    final categoryIcon = ref.watch(categoryIconProvider);
    final categoryColor = ref.watch(categoryColorProvider);
    final showCategoryIcons = ref.watch(showCategoryIconsProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: Text("${selectedCategory == null ? "New" : "Edit"} Category")),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Category name",
                          hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: grey2),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(0),
                        ),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(color: grey1),
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              .copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: const BorderRadius.all(Radius.circular(90)),
                          onTap: () => ref.read(showCategoryIconsProvider.notifier).state = true,
                          child: Ink(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: categoryColorListTheme[categoryColor],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              iconList[categoryIcon],
                              size: 48,
                              color: Theme.of(context).colorScheme.background,
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
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                      if (showCategoryIcons) const Divider(height: 1, color: grey1),
                      if (showCategoryIcons)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: TextButton(
                                  onPressed: () =>
                                      ref.read(showCategoryIconsProvider.notifier).state = false,
                                  child: Text(
                                    "Done",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: Theme.of(context).colorScheme.secondary),
                                  ),
                                ),
                              ),
                              GridView.builder(
                                itemCount: iconList.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 6),
                                itemBuilder: (context, index) {
                                  IconData categoryIconData = iconList.values.elementAt(index);
                                  String categoryIconName = iconList.keys.elementAt(index);
                                  return GestureDetector(
                                    onTap: () => ref.read(categoryIconProvider.notifier).state =
                                        categoryIconName,
                                    child: Container(
                                      margin: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: iconList[categoryIcon] == categoryIconData
                                            ? Theme.of(context).colorScheme.secondary
                                            : Theme.of(context).colorScheme.surface,
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                      ),
                                      child: Icon(
                                        categoryIconData,
                                        color: iconList[categoryIcon] == categoryIconData
                                            ? Colors.white
                                            : Theme.of(context).colorScheme.primary,
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
                          separatorBuilder: (context, index) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            Color color = categoryColorListTheme[index];
                            return GestureDetector(
                              onTap: () => ref.read(categoryColorProvider.notifier).state = index,
                              child: Container(
                                height: categoryColorListTheme[categoryColor] == color ? 38 : 32,
                                width: categoryColorListTheme[categoryColor] == color ? 38 : 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                  border: categoryColorListTheme[categoryColor] == color
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
                            .copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16, top: 32, bottom: 8),
                  child: Text(
                    "SUBCATEGORY",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
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
                if (selectedCategory != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: TextButton.icon(
                      onPressed: () => ref
                          .read(categoriesProvider.notifier)
                          .removeCategory(selectedCategory.id!)
                          .whenComplete(() => Navigator.of(context).pop()),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        side: const BorderSide(color: red, width: 1),
                      ),
                      icon: const Icon(Icons.delete_outlined, color: red),
                      label: Text(
                        "Delete category",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: red),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: blue1.withOpacity(0.15),
                    blurRadius: 5.0,
                    offset: const Offset(0, -1.0),
                  )
                ],
              ),
              padding: const EdgeInsets.only(left:24 ,right: 24, top: 16, bottom: 30),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [defaultShadow],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: () async {
                    if(nameController.text.isNotEmpty) {
                      if (selectedCategory != null) {
                        ref
                            .read(categoriesProvider.notifier)
                            .updateCategory(nameController.text)
                            .whenComplete(() => Navigator.of(context).pop());
                      } else {
                        ref
                            .read(categoriesProvider.notifier)
                            .addCategory(nameController.text)
                            .whenComplete(() => Navigator.of(context).pop());
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    "${selectedCategory == null ? "CREATE" : "UPDATE"} CATEGORY",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Theme.of(context).colorScheme.background),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
