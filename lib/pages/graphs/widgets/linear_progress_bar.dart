import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../ui/device.dart';

enum BarType { account, category }

class LinearProgressBar extends StatelessWidget {
  const LinearProgressBar({
    super.key,
    required this.type,
    required this.amount,
    required this.total,
    required this.colorIndex,
  });

  final BarType type;
  final num amount;
  final num total;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final colorList = isDarkMode
        ? (type == BarType.account
            ? darkAccountColorList
            : darkCategoryColorList)
        : (type == BarType.account ? accountColorList : categoryColorList);

    return ClipRRect(
      borderRadius: BorderRadius.circular(Sizes.borderRadiusLarge),
      child: LinearProgressIndicator(
        value: amount != 0 ? amount / total : 0,
        minHeight: 16,
        backgroundColor: colorList[colorIndex].withValues(alpha: 0.3),
        valueColor: AlwaysStoppedAnimation<Color>(colorList[colorIndex]),
        borderRadius: BorderRadius.circular(Sizes.borderRadiusLarge),
      ),
    );
  }
}
