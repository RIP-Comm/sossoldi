import 'package:flutter/material.dart';

class CategorieTab extends StatelessWidget {
  const CategorieTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            "Categorie $index",
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: Colors.green),
          ),
        );
      },
    );
  }
}
