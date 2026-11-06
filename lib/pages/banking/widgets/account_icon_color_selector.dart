import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../ui/device.dart';

/// Keyboard and screen-reader accessible account appearance controls.
class AccountIconColorSelector extends StatefulWidget {
  final String selectedIcon;
  final int selectedColor;
  final Function(String) onIconChanged;
  final Function(int) onColorChanged;

  const AccountIconColorSelector({
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconChanged,
    required this.onColorChanged,
    super.key,
  });

  @override
  State<AccountIconColorSelector> createState() =>
      _AccountIconColorSelectorState();
}

class _AccountIconColorSelectorState extends State<AccountIconColorSelector> {
  bool showAccountIcons = false;
  static const iconLabels = {
    'payments': 'Cash',
    'credit_card': 'Card',
    'savings': 'Savings',
    'account_balance': 'Bank',
  };
  static const colorLabels = [
    'Yellow',
    'Orange',
    'Blue',
    'Light blue',
    'Green',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ICON AND COLOR', style: theme.textTheme.labelLarge),
        const SizedBox(height: Sizes.md),
        OutlinedButton.icon(
          onPressed: () => setState(() => showAccountIcons = !showAccountIcons),
          icon: Icon(accountIconList[widget.selectedIcon]),
          label: Text(
            showAccountIcons ? 'Close icon picker' : 'Choose account icon',
          ),
        ),
        if (showAccountIcons)
          Wrap(
            spacing: Sizes.sm,
            runSpacing: Sizes.sm,
            children: [
              for (final entry in accountIconList.entries)
                Semantics(
                  selected: widget.selectedIcon == entry.key,
                  child: IconButton(
                    tooltip: '${iconLabels[entry.key] ?? entry.key} icon',
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    onPressed: () => widget.onIconChanged(entry.key),
                    icon: Icon(entry.value),
                  ),
                ),
            ],
          ),
        const SizedBox(height: Sizes.md),
        Text('Choose account color', style: theme.textTheme.labelMedium),
        const SizedBox(height: Sizes.sm),
        Wrap(
          spacing: Sizes.sm,
          runSpacing: Sizes.sm,
          children: [
            for (var index = 0; index < accountColorListTheme.length; index++)
              Semantics(
                selected: widget.selectedColor == index,
                child: Tooltip(
                  message: '${colorLabels[index]} account color',
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () => widget.onColorChanged(index),
                    child: Semantics(
                      label: '${colorLabels[index]} account color',
                      selected: widget.selectedColor == index,
                      child: ExcludeSemantics(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: accountColorListTheme[index],
                            shape: BoxShape.circle,
                          ),
                          child: widget.selectedColor == index
                              ? Icon(
                                  Icons.check,
                                  size: 20,
                                  color:
                                      ThemeData.estimateBrightnessForColor(
                                            accountColorListTheme[index],
                                          ) ==
                                          Brightness.light
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
