import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/style.dart';
import '../../../constants/functions.dart';
import '../../../model/bank_account.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';

class AccountSelector extends ConsumerStatefulWidget {
  const AccountSelector(this.provider, {Key? key}) : super(key: key);

  final StateProvider provider;

  @override
  ConsumerState<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends ConsumerState<AccountSelector> with Functions {
  @override
  Widget build(BuildContext context) {
    final accountsList = ref.watch(accountsProvider);
    return Scaffold(
      appBar: AppBar(),
      body: accountsList.when(
        data: (accounts) => ListView.separated(
          itemCount: accounts.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          separatorBuilder: (context, index) => const Divider(height: 1, color: grey1),
          itemBuilder: (context, i) {
            BankAccount account = accounts[i];
            return Material(
              color: Theme.of(context).colorScheme.surface,
              child: InkWell(
                onTap: () => ref.read(widget.provider.notifier).state = account,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    padding: const EdgeInsets.all(10.0),
                    // TODO: Add icon to bank account
                    // child: icon != null ? Icon(
                    //   icon,
                    //   size: 24.0,
                    //   color: Theme.of(context).colorScheme.background,
                    // ) : const SizedBox(),
                    child: SizedBox(height: 24, width: 24),
                  ),
                  title: Text(
                    account.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  trailing: ref.watch(widget.provider)?.id == account.id
                      ? Icon(Icons.done, color: Theme.of(context).colorScheme.secondary)
                      : null,
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Text('Error: $err'),
      ),
    );
  }
}
