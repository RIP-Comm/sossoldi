import 'package:flutter/material.dart';
import '../../ui/device.dart';
import 'manage_budget_page.dart';
import 'widget/budget_card.dart';
import 'widget/recurring_payments_list.dart';

class PlanningPage extends StatelessWidget {
  const PlanningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.all(Sizes.md),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Monthly budget",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(Sizes.borderRadiusLarge),
                      topRight: Radius.circular(Sizes.borderRadiusLarge),
                    ),
                  ),
                  elevation: 10,
                  builder: (BuildContext context) {
                    return const FractionallySizedBox(
                      heightFactor: 0.9,
                      child: ManageBudgetPage(),
                    );
                  },
                );
              },
              child: Row(
                spacing: Sizes.xs,
                children: [
                  Text("MANAGE", style: Theme.of(context).textTheme.labelLarge),
                  const Icon(Icons.edit, size: 13),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Sizes.sm),
        const BudgetCard(),
        const SizedBox(height: Sizes.xl),
        Text(
          "Recurring payments",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: Sizes.sm),
        const RecurringPaymentSection(),
      ],
    );
  }
}
