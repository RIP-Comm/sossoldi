import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/functions.dart';
import '../../../model/bank_account.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';

class AccountSelector extends ConsumerStatefulWidget {
  const AccountSelector(this.provider, {Key? key}) : super(key: key);

  final AutoDisposeStateProvider provider;

  @override
  ConsumerState<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends ConsumerState<AccountSelector> with Functions {
  @override
  Widget build(BuildContext context) {
    final accountsList = ref.watch(accountsProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: accountsList.when(
          data: (accounts) => ListView.builder(
            itemCount: accounts.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              BankAccount account = accounts[i];
              return Material(
                child: InkWell(
                  onTap: () => ref.read(widget.provider.notifier).state = account,
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(32, 20, 20, 20),
                    leading: const SizedBox(width: 10),
                    title: Text(
                      account.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
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
      ),
    );
  }
}
