import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../constants/functions.dart';

/// This class shows account summaries in dashboard
class BudgetCircularIndicator extends StatelessWidget with Functions {
  final String title;
  final num amount;
  final double perc;
  final Color color;

  const BudgetCircularIndicator({
    super.key,
    required this.title,
    required this.amount,
    required this.perc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 52.0,
          animation: true,
          animationDuration: 1200,
          lineWidth: 10.0,
          percent: perc,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: numToCurrency(amount),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    TextSpan(
                      text: "€",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: Theme.of(context).colorScheme.primary)
                          .apply(
                        fontFeatures: [const FontFeature.subscripts()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "LEFT",
                style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          circularStrokeCap: CircularStrokeCap.butt,
          backgroundColor: color.withOpacity(0.3),
          progressColor: color,
        ),
        const SizedBox(height: 10),
        Text(title, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
