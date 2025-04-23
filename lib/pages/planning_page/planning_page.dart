import 'package:flutter/material.dart';
import '../../ui/device.dart';
import 'manage_budget_page.dart';
import 'widget/budget_card.dart';
import 'widget/recurring_payments_list.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  GlobalKey<_PlanningPageState> _key = GlobalKey<_PlanningPageState>();

  void _forceRefresh() {
    setState(() {
      final key = GlobalKey<_PlanningPageState>();
      _key.currentState?.dispose();
      _key.currentState?.reassemble();
      _key.currentState?._key = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: ListView(
        padding: const EdgeInsetsDirectional.all(Sizes.md),
        children: [
          Row(
            children: [
              Text(
                "Monthly budget",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Sizes.borderRadiusLarge),
                        topRight: Radius.circular(Sizes.borderRadiusLarge),
                      ),
                    ),
                    elevation: 10,
                    builder: (BuildContext context) {
                      return FractionallySizedBox(
                        heightFactor: 0.9,
                        child:
                            ManageBudgetPage(onRefreshBudgets: _forceRefresh),
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Text("MANAGE",
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(width: Sizes.xs),
                    const Icon(Icons.edit, size: 13)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Sizes.sm),
          BudgetCard(_forceRefresh),
          const SizedBox(height: Sizes.xl),
          Text("Recurring payments",
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: Sizes.sm),
          RecurringPaymentSection(),
        ],
      ),
    );
  }
}
