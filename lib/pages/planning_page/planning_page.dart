import 'package:flutter/material.dart';
import 'widget/budget_card.dart';
import 'widget/recurring_payments_card.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 45),
            children: [
              Row(
                children: [
                  Text("Monthly budget",
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      print("Manage budgets");
                    },
                      child: Row(children: [
                    Text("MANAGE",
                        style: Theme.of(context).textTheme.labelLarge),
                    SizedBox(width: 5),
                    Icon(Icons.edit, size: 13)
                  ]))
                ],
              ),
              const SizedBox(height: 10),
              BudgetCard(),
              const SizedBox(height: 20),
              Text("Recurring payments",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              RecurringPaymentCard()
            ]));
  }
}
