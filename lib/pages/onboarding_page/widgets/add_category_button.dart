import 'package:flutter/material.dart';

import '../../../constants/style.dart';

class AddCategoryButton extends StatelessWidget {
  const AddCategoryButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: grey2, width: 1.5),
        color: grey3,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.add_circle_outline_outlined, size: 30, color: grey1)
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Add category",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: grey1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
