import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../ui/device.dart';

class CategoryIconColorSelector extends StatefulWidget {
  final String selectedIcon;
  final int selectedColor;
  final Function(String) onIconChanged;
  final Function(int) onColorChanged;

  const CategoryIconColorSelector({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconChanged,
    required this.onColorChanged,
  });

  @override
  State<CategoryIconColorSelector> createState() =>
      _CategoryIconColorSelectorState();
}

class _CategoryIconColorSelectorState extends State<CategoryIconColorSelector> {
  final PageController _pageController = PageController();
  bool showCategoryIcons = false;
  String selectedIconCategory = mapIconsList.keys.first;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.lg,
        vertical: Sizes.md,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.lg,
        vertical: Sizes.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "ICON AND COLOR",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: Sizes.xl),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(Sizes.borderRadius * 10),
              onTap: () => setState(() => showCategoryIcons = true),
              child: Ink(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: categoryColorListTheme[widget.selectedColor],
                ),
                padding: const EdgeInsets.all(Sizes.lg),
                child: Icon(
                  iconList[widget.selectedIcon],
                  size: 48,
                  color: white,
                ),
              ),
            ),
          ),
          const SizedBox(height: Sizes.sm),
          Text(
            "CHOOSE ICON",
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: Sizes.md),
          if (showCategoryIcons) const Divider(height: 1, color: grey1),
          if (showCategoryIcons)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.lg,
                vertical: Sizes.sm,
              ),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: mapIconsList.keys
                          .map(
                            (key) => CategoryTab(
                              category: key,
                              isSelected: selectedIconCategory == key,
                              onSelected: () {
                                setState(() {
                                  selectedIconCategory = key;
                                  _pageController.jumpToPage(
                                    mapIconsList.keys.toList().indexOf(key),
                                  );
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: Sizes.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = 7;
                      final itemSize = (constraints.maxWidth -
                              (crossAxisCount - 1) * Sizes.md) /
                          crossAxisCount;

                      int maxRows = 0;
                      for (var category in mapIconsList.entries) {
                        final icons = mapIconsList[category.key]!;
                        final rows = (icons.length / crossAxisCount).ceil();
                        if (rows > maxRows) maxRows = rows;
                      }

                      final gridHeight =
                          (maxRows * itemSize) + ((maxRows - 1) * Sizes.md);

                      return SizedBox(
                        height: gridHeight,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => selectedIconCategory =
                                mapIconsList.keys.elementAt(index));
                          },
                          children: mapIconsList.entries
                              .map((e) => IconsGrid(
                                    icons: e.value,
                                    selectedIcon: widget.selectedIcon,
                                    onIconChanged: widget.onIconChanged,
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          const Divider(height: 1, color: grey1),
          const SizedBox(height: Sizes.md),
          ColorGrid(
            selectedColor: widget.selectedColor,
            onColorChanged: widget.onColorChanged,
          ),
          const SizedBox(height: Sizes.xs),
          Text(
            "CHOOSE COLOR",
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  const CategoryTab({
    required this.category,
    required this.isSelected,
    required this.onSelected,
    super.key,
  });

  final String category;
  final bool isSelected;
  final Function() onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.xs),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (selected) {
          if (selected) {
            onSelected.call();
          }
        },
        backgroundColor: white,
        selectedColor: blue5,
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected ? white : grey1,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.borderRadius),
          side: BorderSide(
            color: isSelected ? blue5 : grey2,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.md,
          vertical: Sizes.md / 2,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class IconsGrid extends StatelessWidget {
  const IconsGrid({
    required this.icons,
    required this.selectedIcon,
    required this.onIconChanged,
    super.key,
  });

  final Map<String, IconData> icons;
  final String selectedIcon;
  final Function(String) onIconChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: icons.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: Sizes.md,
        crossAxisSpacing: Sizes.md,
      ),
      itemBuilder: (context, index) {
        String categoryIconName = icons.keys.elementAt(index);
        IconData categoryIconData = icons[categoryIconName]!;
        return GestureDetector(
          onTap: () => onIconChanged(categoryIconName),
          child: Container(
            decoration: BoxDecoration(
              color: iconList[selectedIcon] == categoryIconData
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
            ),
            child: Icon(
              categoryIconData,
              color: iconList[selectedIcon] == categoryIconData
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}

class ColorGrid extends StatefulWidget {
  const ColorGrid({
    required this.selectedColor,
    required this.onColorChanged,
    super.key,
  });

  final int selectedColor;
  final Function(int) onColorChanged;

  @override
  State<ColorGrid> createState() => _ColorGridState();
}

class _ColorGridState extends State<ColorGrid> {
  bool showAllColors = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Sizes.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: Sizes.lg,
            crossAxisSpacing: Sizes.lg,
          ),
          itemCount: showAllColors ? categoryColorListTheme.length : 16,
          itemBuilder: (context, index) {
            final isSelected = widget.selectedColor == index;
            return Center(
              child: GestureDetector(
                onTap: () => widget.onColorChanged(index),
                child: Container(
                  height: isSelected ? 38 : 32,
                  width: isSelected ? 38 : 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: categoryColorListTheme[index],
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          )
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
        if (categoryColorListTheme.length > 16)
          Padding(
            padding: const EdgeInsets.only(top: Sizes.sm),
            child: TextButton.icon(
              onPressed: () => setState(() => showAllColors = !showAllColors),
              icon: Icon(
                showAllColors ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
              label: Text(
                showAllColors ? 'Show less' : 'Show more colors',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.md,
                  vertical: Sizes.xs,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
