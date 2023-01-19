import 'package:flutter/material.dart';
import '../../../constants/style.dart';

class TypeTab extends StatelessWidget {
  const TypeTab(
    this.selectedType,
    this.title,
    this.color, {
    Key? key,
  }) : super(key: key);

  final bool selectedType;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      width: (MediaQuery.of(context).size.width - 36) / 3,
      decoration: BoxDecoration(
        color: selectedType ? color : white,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        boxShadow: selectedType ? [defaultShadow] : [],
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: selectedType ? white : color),
      ),
    );
  }
}
