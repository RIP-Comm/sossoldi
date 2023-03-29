import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/constants/functions.dart';

import '../../../providers/categories_provider.dart';
import '../../../constants/style.dart';
import 'categories_pie_chart.dart';
import 'category_list_tile.dart';

enum Type { income, expense }

class CategoriesTab extends ConsumerStatefulWidget {
  const CategoriesTab({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<CategoriesTab> with Functions {
  final selectedCategory = ValueNotifier<int>(-1);
  final transactionType = ValueNotifier<int>(Type.income.index);

  @override
  Widget build(BuildContext context) {
    final categoriesList = ref.watch(categoriesProvider);

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      color: grey3,
      child: ListView(
        children: [
          TransactionTypeButton(
            width: MediaQuery.of(context).size.width,
            notifier: transactionType,
          ),
          const SizedBox(height: 16),
          CategoriesPieChart(
            notifier: selectedCategory,
            // will it rebuild the child on change?
            categories: categoriesList.value ?? [],
          ),
          const SizedBox(height: 16),
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
                notifier: selectedCategory,
                index: index,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Switch between income and expenses
class TransactionTypeButton extends StatelessWidget {
  const TransactionTypeButton({
    super.key,
    required this.width,
    required this.notifier,
  });

  final ValueNotifier<int> notifier;
  final double width;
  final double height = 28.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) {
          return Stack(
            children: [
              AnimatedAlign(
                alignment: Alignment(
                  (notifier.value == Type.income.index) ? -1 : 1,
                  0,
                ),
                curve: Curves.decelerate,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  width: width * 0.5,
                  height: height,
                  decoration: const BoxDecoration(
                    color: blue5,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  notifier.value = Type.income.index;
                },
                child: Align(
                  alignment: const Alignment(-1, 0),
                  child: Container(
                    width: width * 0.5,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      "Income",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: (notifier.value == Type.income.index)
                              ? white
                              : blue2),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  notifier.value = Type.expense.index;
                },
                child: Align(
                  alignment: const Alignment(1, 0),
                  child: Container(
                    width: width * 0.5,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      'Expenses',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: (notifier.value == Type.expense.index)
                              ? white
                              : blue2),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
