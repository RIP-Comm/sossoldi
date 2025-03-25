import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../ui/widgets/transactions_list.dart';
import '../../model/transaction.dart';
import '../../ui/device.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPage();
}

class _SearchPage extends ConsumerState<SearchPage> {
  Future<List<Transaction>>? futureTransactions;
  List<String> suggetions = [""];
  String? labelFilter;

  void _updateFutureTransactions() {
    Map<int, bool> filterAccountList = {
      for (var element in ref.read(filterAccountProvider).entries)
        element.key: element.value
    };
    setState(() {
      futureTransactions = TransactionMethods().selectAll(
          limit: 100,
          transactionType: ref
              .read(typeFilterProvider)
              .entries
              .map((f) => f.value == true ? f.key : "")
              .toList(),
          label: labelFilter,
          bankAccounts: filterAccountList);
    });
  }

  @override
  void initState() {
    super.initState();
    TransactionMethods()
        .getAllLabels()
        .then((List<String> value) => suggetions.addAll(value));
  }

  @override
  Widget build(BuildContext context) {
    final filterType = ref.watch(typeFilterProvider);
    final accountList = ref.watch(accountsProvider);
    final filterAccountList = ref.watch(filterAccountProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text("Search"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
            child: Column(
              children: [
                InputDecorator(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    child: Autocomplete(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return suggetions.where((String option) {
                          return option
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (option) {
                        labelFilter = option;
                        _updateFutureTransactions();
                      },
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    child: const Text("SEARCH FOR:")),
                Row(children: [
                  Expanded(
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
                            child: FilterChip(
                              showCheckmark: false,
                              label: Text("Income",
                                  style: TextStyle(
                                      color: filterType["IN"]!
                                          ? Colors.white
                                          : Colors.blue.shade700)),
                              selected: filterType["IN"] ?? false,
                              backgroundColor: Colors.white,
                              selectedColor: Colors.blue.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Sizes.borderRadius * 10),
                                side: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 2.0,
                                ),
                              ),
                              onSelected: (_) {
                                ref.read(typeFilterProvider.notifier).state = {
                                  ...filterType,
                                  "IN": filterType["IN"] != null
                                      ? !filterType["IN"]!
                                      : false
                                };
                                _updateFutureTransactions();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
                            child: FilterChip(
                              showCheckmark: false,
                              label: Text("Outcome",
                                  style: TextStyle(
                                      color: filterType["OUT"]!
                                          ? Colors.white
                                          : Colors.blue.shade700)),
                              selected: filterType["OUT"] ?? false,
                              backgroundColor: Colors.white,
                              selectedColor: Colors.blue.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Sizes.borderRadius * 10),
                                side: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 2.0,
                                ),
                              ),
                              onSelected: (_) {
                                ref.read(typeFilterProvider.notifier).state = {
                                  ...filterType,
                                  "OUT": filterType["OUT"] != null
                                      ? !filterType["OUT"]!
                                      : false
                                };
                                _updateFutureTransactions();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Sizes.sm),
                            child: FilterChip(
                              showCheckmark: false,
                              label: Text(
                                "Transfer",
                                style: TextStyle(
                                    color: filterType["TR"]!
                                        ? Colors.white
                                        : Colors.blue.shade700),
                              ),
                              selected: filterType["TR"] ?? false,
                              backgroundColor: Colors.white,
                              selectedColor: Colors.blue.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Sizes.borderRadius * 10),
                                side: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 2.0,
                                ),
                              ),
                              onSelected: (_) {
                                ref.read(typeFilterProvider.notifier).state = {
                                  ...filterType,
                                  "TR": filterType["TR"] != null
                                      ? !filterType["TR"]!
                                      : false
                                };
                                _updateFutureTransactions();
                              },
                            ),
                          ),
                        ])),
                  )
                ]),
                Container(
                    alignment: Alignment.centerLeft,
                    child: const Text("SEARCH IN:")),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: accountList.when(
                            data: (accounts) {
                              return Row(
                                  children: accounts.map((account) {
                                return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: Sizes.sm),
                                    child: FilterChip(
                                        label: Text(
                                          account.name,
                                          style: TextStyle(
                                            color:
                                                filterAccountList[account.id] !=
                                                            null &&
                                                        filterAccountList[
                                                            account.id]!
                                                    ? Colors.white
                                                    : Colors.blue.shade700,
                                          ),
                                        ),
                                        showCheckmark: false,
                                        selected:
                                            filterAccountList[account.id] ??
                                                false,
                                        backgroundColor: Colors.white,
                                        selectedColor: Colors.blue.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                              Sizes.borderRadius * 10),
                                          side: BorderSide(
                                            color: Colors.blue.shade700,
                                            width: 2.0,
                                          ),
                                        ),
                                        onSelected: (_) {
                                          ref
                                              .read(filterAccountProvider
                                                  .notifier)
                                              .state = {
                                            ...ref.read(filterAccountProvider),
                                            account.id!:
                                                ref.read(filterAccountProvider)[
                                                            account.id] !=
                                                        null
                                                    ? !ref.read(
                                                            filterAccountProvider)[
                                                        account.id]!
                                                    : false
                                          };
                                          _updateFutureTransactions();
                                        }));
                              }).toList());
                            },
                            loading: () => const SizedBox(),
                            error: (err, stack) => Text('Error: $err'),
                          )),
                    )
                  ],
                ),
                Expanded(
                  child: FutureBuilder(
                      future: futureTransactions,
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.connectionState == ConnectionState.done) {
                          return TransactionsList(transactions: snapshot.data!);
                        } else if (snapshot.hasError) {
                          return Text(
                              'Something went wrong: ${snapshot.error}');
                        } else {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Transform.scale(
                              scale: 0.5,
                              child: const CircularProgressIndicator(),
                            );
                          } else {
                            return const Text("Search for a transaction");
                          }
                        }
                      }),
                )
              ],
            )));
  }
}
