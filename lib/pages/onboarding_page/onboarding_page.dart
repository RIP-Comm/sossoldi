import 'package:flutter/material.dart';
import '/pages/onboarding_page/widgets/budget_setup.dart';
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height/9,
                ),
                Text(
                  'Set up the app',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: blue1),
                ),
                const SizedBox(
                  height: 80,
                ),
                Image.asset(
                  'assets/openVault.png',
                  height: MediaQuery.sizeOf(context).height/3.7,
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

              ],

            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
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
                        ?.copyWith(color: white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
