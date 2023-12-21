import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../constants/functions.dart';
import '../../../model/bank_account.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';
import 'accounts_pie_chart.dart';
import 'account_list_tile.dart';

enum Type { income, expense }

class AccountsTab extends ConsumerStatefulWidget {
  const AccountsTab({
    super.key,
  });

  @override
  ConsumerState<AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends ConsumerState<AccountsTab> with Functions {
  final selectedCategory = ValueNotifier<int>(-1);

  /// income or expenses
  final transactionType = ValueNotifier<int>(Type.income.index);

  @override
  Widget build(BuildContext context) {
    // TODO: query only categories with expenses/income during the selected month
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);

    // create a map to link each categories with a list of its transactions
    // stored as Map<String, dynamic> to be passed to CategoryListTile
    Map<int, List<Map<String, dynamic>>> accountToTransactions = {};
    Map<int, double> categoryToAmount = {};
    double total = 0;

    for (var transaction in transactions.value ?? []) {
      final accountId = transaction.idBankAccount;
      if (accountId != null) {
        final updateValue = {
          "account": transaction.idBankAccount.toString(),
          "amount": transaction.amount,
          "category": accountId.toString(),
          "title": transaction.note,
        };

        if (accountToTransactions.containsKey(accountId)) {
          accountToTransactions[accountId]?.add(updateValue);
        } else {
          accountToTransactions.putIfAbsent(accountId, () => [updateValue]);
        }

        // update total amount for the category
        total += transaction.amount;
        if (categoryToAmount.containsKey(accountId)) {
          categoryToAmount[accountId] =
              categoryToAmount[accountId]! + transaction.amount.toDouble();
        } else {
          categoryToAmount.putIfAbsent(accountId, () => transaction.amount.toDouble());
        }
      }
    }

    // Add missing catogories (with amount 0)
    // This will be removed when only categories with transactions are queried
    for (var account in accounts.value ?? []) {
      if (account.id != null) {
        categoryToAmount.putIfAbsent(account.id, () => 0);
      }
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      color: grey3,
      child: ListView(
        children: [
          const SizedBox(height: 12.0),
          TransactionTypeButton(
            width: MediaQuery.of(context).size.width,
            notifier: transactionType,
          ),
          const SizedBox(height: 16),
          accounts.when(
            data: (data) => AccountsPieChart(
              notifier: selectedCategory,
              accounts: accounts.value!,
              amounts: categoryToAmount,
              total: total,
            ),
            error: (error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 16),
          accounts.when(
            data: (data) {
              return ValueListenableBuilder(
                valueListenable: selectedCategory,
                builder: (context, value, child) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: accounts.value!.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {

                          BankAccount b = accounts.value![index];
                          return AccountListTile(
                            title: b.name,
                            nTransactions:
                            accountToTransactions[b.id]?.length ?? 0,
                            transactions: accountToTransactions[b.id] ?? [],
                            amount: categoryToAmount[b.id] ?? 0,
                            percent:
                            (categoryToAmount[b.id] ?? 0) / total * 100,
                            color: accountColorList[b.color],
                            icon:
                            accountIconList[b.symbol] ?? Icons.swap_horiz_rounded,
                            notifier: selectedCategory,
                            index: index,
                          );
                        },
                      );
                },
              );
            },
            error: (error, stackTrace) => Center(
              child: Text(error.toString()),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }
}

/// Switch between income and expenses
class TransactionTypeButton extends StatelessWidget {
  const TransactionTypeButton({
    super.key,
    required this.width,
    required this.notifier,
  });

  final ValueNotifier<int> notifier;
  final double width;
  final double height = 28.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) {
          return Stack(
            children: [
              AnimatedAlign(
                alignment: Alignment(
                  (notifier.value == Type.income.index) ? -1 : 1,
                  0,
                ),
                curve: Curves.decelerate,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  width: width * 0.5,
                  height: height,
                  decoration: const BoxDecoration(
                    color: blue5,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  notifier.value = Type.income.index;
                },
                child: Align(
                  alignment: const Alignment(-1, 0),
                  child: Container(
                    width: width * 0.5,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      "Income",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: (notifier.value == Type.income.index)
                              ? white
                              : blue2),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  notifier.value = Type.expense.index;
                },
                child: Align(
                  alignment: const Alignment(1, 0),
                  child: Container(
                    width: width * 0.5,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      'Expenses',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: (notifier.value == Type.expense.index)
                              ? white
                              : blue2),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


