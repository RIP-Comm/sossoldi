import 'package:flutter/material.dart';

import '../../../constants/style.dart';
import '../../../ui/assets.dart';
import '../../../ui/device.dart';
import '../../../ui/widgets/default_container.dart';

class AddTransactionCard extends StatelessWidget {
  const AddTransactionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: DefaultContainer(
        margin: const EdgeInsets.symmetric(
          horizontal: Sizes.lg,
          vertical: Sizes.xl,
        ),
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "There are no transactions added yet",
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Image.asset(SossoldiAssets.calculator, width: 240, height: 240),
            Text(
              "Add a transaction to make this section more appealing",
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
                boxShadow: [defaultShadow],
              ),
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.add_circle,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: Sizes.xl,
                ),
                label: Text(
                  "Add transaction",
                  style: Theme.of(context).textTheme.titleLarge!.apply(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed("/add-page");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
