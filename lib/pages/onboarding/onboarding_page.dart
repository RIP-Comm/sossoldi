import 'package:flutter/material.dart';
import '../../ui/assets.dart';
import '../../ui/device.dart';
import 'widgets/budget_setup.dart';
import '/constants/style.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue7,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height / 9),
                Text(
                  'Set up the app',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(color: blue1),
                ),
                const SizedBox(height: 80),
                Image.asset(
                  SossoldiAssets.openVault,
                  height: MediaQuery.sizeOf(context).height / 3.7,
                ),
                const SizedBox(height: 74),
                Text(
                  'In a few steps you\'ll be ready to start keeping\ntrack of your personal finances (almost) like\nMr. Rip',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: blue1),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.xl,
                vertical: Sizes.sm,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BudgetSetup(),
                    ),
                  );
                },
                child: const Center(child: Text('START THE SET UP')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
