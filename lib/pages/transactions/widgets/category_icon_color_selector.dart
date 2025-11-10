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
  bool showAllColors = false;
  String selectedIconCategory = 'Household';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                  .labelLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
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
                .labelMedium!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: Sizes.md),
          if (showCategoryIcons) const Divider(height: 1, color: grey1),
          if (showCategoryIcons)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.lg, vertical: Sizes.sm),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryTab('Household'),
                        _buildCategoryTab('Activities'),
                        _buildCategoryTab('Travel'),
                        _buildCategoryTab('Tech'),
                        _buildCategoryTab('People'),
                        _buildCategoryTab('Others'),
                      ],
                    ),
                  ),
                  const SizedBox(height: Sizes.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final categories = [
                        'Household',
                        'Activities',
                        'Travel',
                        'Tech',
                        'People',
                        'Others'
                      ];

                      final crossAxisCount = 7;
                      final itemSize = (constraints.maxWidth -
                              (crossAxisCount - 1) * Sizes.md) /
                          crossAxisCount;

                      int maxRows = 0;
                      for (var category in categories) {
                        final icons = _getIconsForCategory(category);
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
                            setState(
                                () => selectedIconCategory = categories[index]);
                          },
                          children: [
                            _buildIconGrid('Household'),
                            _buildIconGrid('Activities'),
                            _buildIconGrid('Travel'),
                            _buildIconGrid('Tech'),
                            _buildIconGrid('People'),
                            _buildIconGrid('Others'),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          const Divider(height: 1, color: grey1),
          const SizedBox(height: Sizes.md),
          _buildColorGrid(),
          const SizedBox(height: Sizes.xs),
          Text(
            "CHOOSE COLOR",
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildColorGrid() {
    final colorOrder = [
      2,
      0,
      20,
      7,
      5,
      4,
      39,
      43,
      10,
      1,
      21,
      24,
      6,
      27,
      36,
      44,
      if (showAllColors) ...[
        48,
        13,
        8,
        25,
        28,
        37,
        40,
        45,
        49,
        14,
        18,
        23,
        29,
        38,
        41,
        46,
        3,
        15,
        19,
        26,
        30,
        42,
        47,
        11,
        50,
        16,
        22,
        31,
        32,
        33,
        34,
        35,
        17,
        9,
        12,
      ],
    ];

    final int displayCount = showAllColors ? colorOrder.length : 16;
    final List<int> displayedColors = colorOrder.take(displayCount).toList();

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
          itemCount: displayedColors.length,
          itemBuilder: (context, index) {
            final colorIndex = displayedColors[index];
            final Color color = categoryColorListTheme[colorIndex];
            final isSelected = widget.selectedColor == colorIndex;

            return Center(
              child: GestureDetector(
                onTap: () => widget.onColorChanged(colorIndex),
                child: Container(
                  height: isSelected ? 38 : 32,
                  width: isSelected ? 38 : 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
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

  Widget _buildCategoryTab(String category) {
    final isSelected = selectedIconCategory == category;
    final categories = [
      'Household',
      'Activities',
      'Travel',
      'Tech',
      'People',
      'Others'
    ];
    final index = categories.indexOf(category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (selected) {
          if (selected) {
            setState(() => selectedIconCategory = category);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        backgroundColor: white,
        selectedColor: blue5,
        labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: isSelected ? white : grey1,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? blue5 : grey2,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildIconGrid(String category) {
    final icons = _getIconsForCategory(category);
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
          onTap: () => widget.onIconChanged(categoryIconName),
          child: Container(
            decoration: BoxDecoration(
              color: iconList[widget.selectedIcon] == categoryIconData
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
            ),
            child: Icon(
              categoryIconData,
              color: iconList[widget.selectedIcon] == categoryIconData
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  Map<String, IconData> _getIconsForCategory(String category) {
    final Map<String, IconData> categoryIcons = {};

    switch (category) {
      case 'Household':
        final householdKeys = [
          'home',
          'weekend',
          'blender',
          'construction',
          'shopping_cart',
          'dry_cleaning',
          'checkroom',
          'lightbulb',
          'electrical_services',
          'energy_savings_leaf',
          'router',
          'device_thermostat',
          'water_drop',
          'local_fire_department',
          'local_gas_station',
          'ev_station',
          'bakery_dining',
          'cookie',
          'fastfood',
          'toys',
          'cake',
          'gavel',
          'ramen_dining',
          'liquor',
          'restaurant',
          'medical_services',
          'vaccines'
        ];
        for (var key in householdKeys) {
          if (iconList.containsKey(key)) {
            categoryIcons[key] = iconList[key]!;
          }
        }
        break;

      case 'Activities':
        final activitiesKeys = [
          'work',
          'school',
          'calendar_month',
          'videogame_asset',
          'translate',
          'menu_book',
          'palette',
          'biotech',
          'draw',
          'celebration',
          'card_giftcard',
          'shopping_bag',
          'format_paint',
          'park',
          'attractions',
          'stadium',
          'theater_comedy',
          'local_movies',
          'confirmation_number',
          'subscriptions',
          'church',
          'storefront',
          'beach_access',
          'fitness_center',
          'military_tech',
          'emoji_events',
          'sports_motorsports'
        ];
        for (var key in activitiesKeys) {
          if (iconList.containsKey(key)) {
            categoryIcons[key] = iconList[key]!;
          }
        }
        break;

      case 'Travel':
        final travelKeys = [
          'rocket_launch',
          'flight',
          'airplane_ticket',
          'local_taxi',
          'directions_boat',
          'sailing',
          'anchor',
          'agriculture',
          'commute',
          'directions_bus',
          'subway',
          'tram',
          'electric_scooter',
          'directions_car',
          'directions_car_rounded',
          'electric_car',
          'directions_bike',
          'electric_bike',
          'two_wheeler',
          'moped',
          'electric_moped',
          'public',
          'place',
          'hotel',
          'luggage',
          'airline_seat_recline_normal'
        ];
        for (var key in travelKeys) {
          if (iconList.containsKey(key)) {
            categoryIcons[key] = iconList[key]!;
          }
        }
        break;

      case 'Tech':
        final techKeys = [
          'monitor',
          'laptop',
          'devices',
          'phone',
          'sim_card',
          'camera_alt',
          'image',
          'language',
          'album',
          'video_library',
          'music_note',
          'cloud',
          'call',
          'headphones',
          'shield',
          'drafts'
        ];
        for (var key in techKeys) {
          if (iconList.containsKey(key)) {
            categoryIcons[key] = iconList[key]!;
          }
        }
        break;

      case 'People':
        final peopleKeys = [
          'wc',
          'pregnant_woman',
          'diversity_3',
          'family_restroom',
          'accessible',
          'elderly',
          'elderly_woman',
          'self_improvement',
          'sports_kabaddi',
          'downhill_skiing',
          'directions_run',
          'hiking',
          'child_care'
        ];
        for (var key in peopleKeys) {
          if (iconList.containsKey(key)) {
            categoryIcons[key] = iconList[key]!;
          }
        }
        break;

      case 'Others':
        final othersKeys = [
          'real_estate_agent',
          'show_chart',
          'diamond',
          'local_parking',
          'circle',
          'key',
          'bolt',
          'local_florist',
          'ac_unit',
          'wb_sunny',
          'nights_stay',
          'recycling',
          'favorite',
          'star',
          'priority_high',
          'volunteer_activism',
          'psychology',
          'push_pin',
          'help',
          'flag',
          'percent',
          'block',
          'link',
          'sos'
        ];
        for (var key in othersKeys) {
          if (iconList.containsKey(key)) {
            categoryIcons[key] = iconList[key]!;
          }
        }
        break;
    }

    return categoryIcons;
  }
}
