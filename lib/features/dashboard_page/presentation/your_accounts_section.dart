import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/accounts_provider.dart';
import 'accounts_list.dart';

class YourAccountsSection extends ConsumerWidget {
  const YourAccountsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountListWidget = switch (ref.watch(accountsProvider)) {
      AsyncData(:final value) => AccountsList(accounts: value),
      AsyncError(:final error) => Text('Error: $error'),
      _ => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CircularProgressIndicator.adaptive(),
        ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            "Your accounts",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 80.0,
          child: accountListWidget,
        ),
      ],
    );
  }
}
