import 'package:flutter/material.dart';
import '../../../../constants/style.dart';
import '../../../../ui/device.dart';

class TypeTab extends StatelessWidget {
  const TypeTab(
    this.selectedType,
    this.title,
    this.color, {
    super.key,
  });

  final bool selectedType;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      width: (MediaQuery.of(context).size.width - 36) / 3,
      decoration: BoxDecoration(
        color: selectedType
            ? color
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius:
            const BorderRadius.all(Radius.circular(Sizes.borderRadiusSmall)),
        boxShadow: selectedType ? [defaultShadow] : [],
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: selectedType ? white : color),
      ),
    );
  }
}
