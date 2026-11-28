import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/style.dart';
import '../../../providers/banking_ui_provider.dart';
import '../../../services/banking/banking_account.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';
import 'account_icon_color_selector.dart';

/// One account offered by the bank: whether to import it and, when it is selected, how it should look among the app accounts.
class AccountImportTile extends ConsumerWidget {
  const AccountImportTile({
    required this.account,
    required this.selected,
    required this.nameController,
    required this.symbol,
    required this.color,
    required this.onSelectedChanged,
    required this.onIconChanged,
    required this.onColorChanged,
    super.key,
  });

  final BankingAccount account;
  final bool selected;
  final TextEditingController nameController;
  final String symbol;
  final int color;
  final ValueChanged<bool> onSelectedChanged;
  final ValueChanged<String> onIconChanged;
  final ValueChanged<int> onColorChanged;

  /// Keeps the first and last characters only: enough to tell the accounts apart without spelling out the full IBAN.
  static String maskIban(String? iban) {
    if (iban == null || iban.isEmpty) return '—';
    if (iban.length <= 6) return iban;
    return '${iban.substring(0, 2)}•• ••${iban.substring(iban.length - 4)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(
      ebAccountBalanceProvider(account.reference.remoteId),
    );
    final subtitle = [
      maskIban(account.iban),
      if (account.currency != null) account.currency!,
    ].join(' · ');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: Sizes.lg,
        vertical: Sizes.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.lg,
        vertical: Sizes.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Sizes.borderRadiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name ?? account.product ?? "Account",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'Import ${account.name ?? account.product ?? 'account'}',
                child: Switch.adaptive(
                  value: selected,
                  onChanged: onSelectedChanged,
                ),
              ),
            ],
          ),
          balance.when(
            data: (amount) => amount == null
                ? const SizedBox.shrink()
                : Text(
                    "${amount.toCurrency()} ${account.currency ?? ''}".trim(),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
            loading: () => const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          if (selected) ...[
            const SizedBox(height: Sizes.md),
            const Divider(height: 1, color: grey2),
            const SizedBox(height: Sizes.md),
            Text("NAME", style: Theme.of(context).textTheme.labelLarge),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Account name"),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Sizes.md),
            AccountIconColorSelector(
              selectedIcon: symbol,
              selectedColor: color,
              onIconChanged: onIconChanged,
              onColorChanged: onColorChanged,
            ),
          ],
        ],
      ),
    );
  }
}
