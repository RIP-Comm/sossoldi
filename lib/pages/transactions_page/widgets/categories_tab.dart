import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/constants/functions.dart';

import '../../../providers/categories_provider.dart';
import '../../../constants/style.dart';
import 'categories_pie_chart.dart';
import 'category_list_tile.dart';

class CategoriesTab extends ConsumerStatefulWidget {
  const CategoriesTab({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<CategoriesTab> with Functions {
  final notifier = ValueNotifier<int>(-1);

  @override
  Widget build(BuildContext context) {
    final categoriesList = ref.watch(categoriesProvider);

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      color: grey3,
      child: ListView(
        children: [
          // TODO: extract to a separate widget
          // switch between income and expenses
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: const BoxDecoration(
                      color: blue3,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 12.0,
                    ),
                    child: Text(
                      "Income",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: white),
                    ),
                  ),
                ),
                Container(child: Text("Expenses")),
              ],
            ),
          ),
          CategoriesPieChart(
            notifier: notifier,
            // will it rebuild the child on change?
            categories: categoriesList.value ?? [],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 400,
            child: ListView.builder(
              // TODO: implement nested ListView and remove SizedBox
              physics: const ClampingScrollPhysics(),
              itemCount: categoriesList.value?.length,
              itemBuilder: (context, index) => CategoryListTile(
                title: categoriesList.value?[index].name ?? "",
                amount: -325.90,
                nTransactions: 3,
                percent: 70,
                color: const Color(0xFFEBC35F),
                icon: Icons.home_rounded,
                notifier: notifier,
                index: index,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
