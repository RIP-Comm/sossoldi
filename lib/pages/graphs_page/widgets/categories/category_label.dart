import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sossoldi/providers/currency_provider.dart';

import '../../../../constants/style.dart';
import '../../../../model/category_transaction.dart';

class CategoryLabel extends ConsumerWidget {
  const CategoryLabel({
    super.key,
    required this.category,
    required this.amount,
    required this.total,
  });

  final CategoryTransaction category;
  final double amount;
  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyStateNotifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          category.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
        ),
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: "${amount.toStringAsFixed(2)}${currencyState.selectedCurrency.symbol}    ",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
            ),
            TextSpan(
              text: "${((amount / total) * 100).abs().toStringAsFixed(2)}%",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: blue1,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ]),
        ),
      ],
    );
  }
}
