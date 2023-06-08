import 'package:flutter/material.dart';
import 'package:sossoldi/pages/onboarding_page/widgets/budget_setup.dart';
import '/constants/style.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blue7,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 80,
            ),
            Text(
              'Set up the app',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(
              height: 80,
            ),
            Image.asset(
              'assets/openVault.png',
              height: 214,
            ),
            const SizedBox(
              height: 74,
            ),
            Text(
              'In a few steps you\'ll be ready to start keeping\ntrack of your personal finances (almost) like\nMr. Rip',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
            ),
            const Spacer(),
            SizedBox(
              width: 342,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BudgetSetup(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'START THE SET UP',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}