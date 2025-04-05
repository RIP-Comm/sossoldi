import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/dashboard_provider.dart';
import 'dashboard_data.dart';

class DashboardGraph extends ConsumerWidget {
  const DashboardGraph({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(dashboardProvider)) {
      AsyncData() => const DashboardData(),
      AsyncError(:final error) => Text('Error: $error'),
      _ => const SizedBox(
          height: 330,
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
    };
  }
}
