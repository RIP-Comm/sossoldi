import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/database/repositories/transactions_repository.dart';
import '../../ui/extensions.dart';
import '../../ui/widgets/transactions_list.dart';
import '../../model/transaction.dart';
import '../../ui/device.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPage();
}

class _SearchPage extends ConsumerState<SearchPage> {
  late List<String> suggetions = [""];
  String? labelFilter;

  @override
  void initState() {
    super.initState();
    ref
        .read(transactionsRepositoryProvider)
        .getAllLabels()
        .then((List<String> value) => suggetions.addAll(value));
  }

  @override
  Widget build(BuildContext context) {
    final filterType = ref.watch(typeFilterProvider);
    final accountList = ref.watch(accountsProvider);
    final filterAccountList = ref.watch(filterAccountProvider);
    final searchTransactions = ref.watch(searchTransactionsProvider);
    var l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.search),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
              ),
              child: InputDecorator(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
                  hintText: l10n.search,
                ),
                child: Autocomplete(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return suggetions.where((String option) {
                      return option.contains(
                        textEditingValue.text.toLowerCase(),
                      );
                    });
                  },
                  onSelected: (option) {
                    setState(() => labelFilter = option);
                    ref.read(filterLabelProvider.notifier).setLabel(option);
                  },
                ),
              ),
            ),
            const SizedBox(height: Sizes.md),
            Text(l10n.searchForATransaction, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: TransactionType.values.map((type) {
                  String message = '';
                  switch(type)
                  {
                    case TransactionType.expense:
                      message = l10n.expense;
                      break;
                    case TransactionType.income:
                      message = l10n.income;
                      break;
                    case TransactionType.transfer:
                      message = l10n.transfer;
                      break;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
                    child: FilterChip(
                      showCheckmark: false,
                      label: Text(
                        message,
                        style: TextStyle(
                          color: filterType[type.code]!
                              ? Colors.white
                              : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      selected: filterType[type.code] ?? false,
                      onSelected: (_) {
                        ref.read(typeFilterProvider.notifier).setFilter({
                          ...filterType,
                          type.code: filterType[type.code] != null
                              ? !filterType[type.code]!
                              : false,
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: Sizes.md),
            Text(l10n.searchIn, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(
              height: 60,
              child: accountList.when(
                data: (accounts) {
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: accounts.map((account) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.sm,
                        ),
                        child: FilterChip(
                          label: Text(
                            account.name,
                            style: TextStyle(
                              color:
                                  filterAccountList[account.id] != null &&
                                      filterAccountList[account.id]!
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          showCheckmark: false,
                          selected: filterAccountList[account.id] ?? false,
                          onSelected: (_) {
                            ref
                                .read(filterAccountProvider.notifier)
                                .setAccounts({
                                  ...ref.read(filterAccountProvider),
                                  account.id!:
                                      ref.read(
                                            filterAccountProvider,
                                          )[account.id] !=
                                          null
                                      ? !ref.read(
                                          filterAccountProvider,
                                        )[account.id]!
                                      : false,
                                });
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox(),
                error: (err, stack) => Text(l10n.errorOccurred(err)),
              ),
            ),
            Expanded(
              child: searchTransactions.when(
                data: (data) {
                  if (data.isNotEmpty) {
                    return SingleChildScrollView(
                      child: TransactionsList(
                        margin: EdgeInsets.zero,
                        transactions: data,
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(l10n.searchForATransaction),
                    );
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text(l10n.errorOccurred(err)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
