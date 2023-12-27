import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../custom_widgets/default_container.dart';
import '../../../model/bank_account.dart';
import '../../../model/transaction.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';
import 'account_list_tile.dart';
import 'accounts_pie_chart.dart';

final selectedAccountIndexProvider = StateProvider<int>((ref) => -1);

final selectedTransactionTypeProvider =
    StateProvider<TransactionType>((ref) => TransactionType.income);

class AccountsTab extends ConsumerStatefulWidget {
  const AccountsTab({
    super.key,
  });

  @override
  ConsumerState<AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends ConsumerState<AccountsTab> with Functions {
  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);
    final transactionType = ref.watch(selectedTransactionTypeProvider);

    // create a map to link each accounts with a list of its transactions
    // stored as Map<String, dynamic> to be passed to AccountListTile
    Map<int, List<Map<String, dynamic>>> accountToTransactionsIncome = {},
        accountToTransactionsExpense = {};
    Map<int, double> accountToAmountIncome = {}, accountToAmountExpense = {};
    double totalIncome = 0, totalExpense = 0;

    for (Transaction transaction in transactions.value ?? []) {
      final accountId = transaction.idBankAccount;
      final updateValue = {
        "account": transaction.idBankAccount.toString(),
        "amount": transaction.amount,
        "category": accountId.toString(),
        "title": transaction.note,
      };
      if (transaction.type == TransactionType.income) {
        if (accountToTransactionsIncome.containsKey(accountId)) {
          accountToTransactionsIncome[accountId]?.add(updateValue);
        } else {
          accountToTransactionsIncome.putIfAbsent(accountId, () => [updateValue]);
        }

        // update total amount for the account
        totalIncome += transaction.amount;
        if (accountToAmountIncome.containsKey(accountId)) {
          accountToAmountIncome[accountId] =
              accountToAmountIncome[accountId]! + transaction.amount.toDouble();
        } else {
          accountToAmountIncome.putIfAbsent(accountId, () => transaction.amount.toDouble());
        }
      } else if (transaction.type == TransactionType.expense) {
        if (accountToTransactionsExpense.containsKey(accountId)) {
          accountToTransactionsExpense[accountId]?.add(updateValue);
        } else {
          accountToTransactionsExpense.putIfAbsent(accountId, () => [updateValue]);
        }

        // update total amount for the account
        totalExpense -= transaction.amount;
        if (accountToAmountExpense.containsKey(accountId)) {
          accountToAmountExpense[accountId] =
              accountToAmountExpense[accountId]! - transaction.amount.toDouble();
        } else {
          accountToAmountExpense.putIfAbsent(accountId, () => -transaction.amount.toDouble());
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: DefaultContainer(
        child: Column(
          children: [
            const TransactionTypeButton(),
            const SizedBox(height: 16),
            accounts.when(
              data: (data) {
                List<BankAccount> accountIncomeList =
                    data.where((account) => accountToAmountIncome.containsKey(account.id)).toList();
                List<BankAccount> accountExpenseList = data
                    .where((account) => accountToAmountExpense.containsKey(account.id))
                    .toList();
                return transactionType == TransactionType.income
                    ? accountIncomeList.isEmpty
                        ? const SizedBox(
                            height: 400,
                            child: Center(
                              child: Text("No incomes for selected month"),
                            ),
                          )
                        : Column(
                            children: [
                              AccountsPieChart(
                                accounts: accountIncomeList,
                                amounts: accountToAmountIncome,
                                total: totalIncome,
                              ),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: accountIncomeList.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  BankAccount b = accountIncomeList[index];
                                  return AccountListTile(
                                    title: b.name,
                                    nTransactions: accountToTransactionsIncome[b.id]?.length ?? 0,
                                    transactions: accountToTransactionsIncome[b.id] ?? [],
                                    amount: accountToAmountIncome[b.id] ?? 0,
                                    percent: (accountToAmountIncome[b.id] ?? 0) / totalIncome * 100,
                                    color: accountColorList[b.color],
                                    icon: accountIconList[b.symbol] ?? Icons.swap_horiz_rounded,
                                    index: index,
                                  );
                                },
                              )
                            ],
                          )
                    : accountExpenseList.isEmpty
                        ? const SizedBox(
                            height: 400,
                            child: Center(
                              child: Text("No expenses for selected month"),
                            ),
                          )
                        : Column(
                            children: [
                              AccountsPieChart(
                                accounts: accountExpenseList,
                                amounts: accountToAmountExpense,
                                total: totalExpense,
                              ),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: accountExpenseList.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  BankAccount b = accountExpenseList[index];
                                  return AccountListTile(
                                    title: b.name,
                                    nTransactions: accountToTransactionsExpense[b.id]?.length ?? 0,
                                    transactions: accountToTransactionsExpense[b.id] ?? [],
                                    amount: accountToAmountExpense[b.id] ?? 0,
                                    percent:
                                        (accountToAmountExpense[b.id] ?? 0) / totalExpense * 100,
                                    color: accountColorList[b.color],
                                    icon: accountIconList[b.symbol] ?? Icons.swap_horiz_rounded,
                                    index: index,
                                  );
                                },
                              )
                            ],
                          );
              },
              error: (error, stackTrace) => Center(
                child: Text(error.toString()),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Switch between income and expenses
class TransactionTypeButton extends ConsumerWidget {
  const TransactionTypeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionType = ref.watch(selectedTransactionTypeProvider);
    final width = (MediaQuery.of(context).size.width - 64) * 0.5;
    return Container(
      height: 28,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(
              (transactionType == TransactionType.income) ? -1 : 1,
              0,
            ),
            curve: Curves.decelerate,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: width,
              height: 28,
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
              ref.read(selectedTransactionTypeProvider.notifier).state = TransactionType.income;
            },
            child: Align(
              alignment: const Alignment(-1, 0),
              child: Container(
                width: width,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  "Income",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: (transactionType == TransactionType.income) ? white : blue2),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(selectedTransactionTypeProvider.notifier).state = TransactionType.expense;
            },
            child: Align(
              alignment: const Alignment(1, 0),
              child: Container(
                width: width,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  'Expenses',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: (transactionType == TransactionType.expense) ? white : blue2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
