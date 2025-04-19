import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../constants/style.dart';
import '../../../models/budget.dart';
import '../../../ui/device.dart';

class CategoryButton extends StatelessWidget {
  const CategoryButton(
      {super.key,
      required this.categoryColor,
      required this.categoryName,
      this.budget});

  final Color categoryColor;
  final String categoryName;
  final Budget? budget;

  @override
  Widget build(BuildContext context) {
    if (budget != null && budget!.active && budget!.amountLimit > 0) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: categoryColor, width: 2.5),
          color: categoryColor,
          borderRadius: BorderRadius.circular(Sizes.borderRadius),
        ),
        padding: const EdgeInsets.only(left: Sizes.md),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(Sizes.xxs),
              child: Icon(Icons.check_rounded, color: categoryColor, size: 22),
            ),
            const SizedBox(width: Sizes.sm),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Sizes.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    textAlign: TextAlign.left,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: white),
                  ),
                  Text(
                    "BUDGET: ${budget?.amountLimit}€",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 10, color: white),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: categoryColor, width: 2.5),
          color: HSLColor.fromColor(categoryColor)
              .withLightness(clampDouble(0.99, 0.0, 0.9))
              .toColor(),
          borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Sizes.sm),
              child: Icon(
                Icons.add_circle_outline_outlined,
                size: 30,
                color: blue1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Sizes.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text("ADD BUDGET",
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
