import 'package:flutter/material.dart';

import '/constants/style.dart';
import 'category_list_tile.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      color: grey3,
      child: ListView.separated(
        itemCount: 3,
        itemBuilder: (context, index) => const CategoryListTile(
          title: "Casa",
          amount: -325.90,
          nTransactions: 2,
          percent: 70,
          color: Color(0xFFEBC35F),
          icon: Icons.home_rounded,
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 8.0),
      ),
    );
  }
}
