import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/constants.dart';
import '../../../shared/constants/functions.dart';
import '../../../shared/widgets/default_container.dart';
import '../data/selected_transaction_type_provider.dart';
import 'transaction_type_button.dart';
import '../../../shared/models/bank_account.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/providers/accounts_provider.dart';
import '../../../shared/providers/transactions_provider.dart';
import 'account_list_tile.dart';
import 'accounts_pie_chart.dart';

final selectedAccountIndexProvider =
    StateProvider.autoDispose<int>((ref) => -1);

class AccountsTab extends ConsumerWidget with Functions {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);
    final transactionType = ref.watch(selectedTransactionTypeProvider);

    // create a map to link each accounts with a list of its transactions
    // stored as Map<String, dynamic> to be passed to AccountListTile
    Map<int, List<Transaction>> accountToTransactionsIncome = {},
        accountToTransactionsExpense = {};
    Map<int, double> accountToAmountIncome = {}, accountToAmountExpense = {};
    double totalIncome = 0, totalExpense = 0;

    for (Transaction transaction in transactions.value ?? []) {
      final accountId = transaction.idBankAccount;
      if (transaction.type == TransactionType.income) {
        if (accountToTransactionsIncome.containsKey(accountId)) {
          accountToTransactionsIncome[accountId]?.add(transaction);
        } else {
          accountToTransactionsIncome.putIfAbsent(
              accountId, () => [transaction]);
        }

        // update total amount for the account
        totalIncome += transaction.amount;
        if (accountToAmountIncome.containsKey(accountId)) {
          accountToAmountIncome[accountId] =
              accountToAmountIncome[accountId]! + transaction.amount.toDouble();
        } else {
          accountToAmountIncome.putIfAbsent(
              accountId, () => transaction.amount.toDouble());
        }
      } else if (transaction.type == TransactionType.expense) {
        if (accountToTransactionsExpense.containsKey(accountId)) {
          accountToTransactionsExpense[accountId]?.add(transaction);
        } else {
          accountToTransactionsExpense.putIfAbsent(
              accountId, () => [transaction]);
        }

        // update total amount for the account
        totalExpense -= transaction.amount;
        if (accountToAmountExpense.containsKey(accountId)) {
          accountToAmountExpense[accountId] =
              accountToAmountExpense[accountId]! -
                  transaction.amount.toDouble();
        } else {
          accountToAmountExpense.putIfAbsent(
              accountId, () => -transaction.amount.toDouble());
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
                List<BankAccount> accountIncomeList = data
                    .where((account) =>
                        accountToAmountIncome.containsKey(account.id))
                    .toList();
                List<BankAccount> accountExpenseList = data
                    .where((account) =>
                        accountToAmountExpense.containsKey(account.id))
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
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  BankAccount b = accountIncomeList[index];
                                  return AccountListTile(
                                    title: b.name,
                                    nTransactions:
                                        accountToTransactionsIncome[b.id]
                                                ?.length ??
                                            0,
                                    transactions:
                                        accountToTransactionsIncome[b.id] ?? [],
                                    amount: accountToAmountIncome[b.id] ?? 0,
                                    percent:
                                        (accountToAmountIncome[b.id] ?? 0) /
                                            totalIncome *
                                            100,
                                    color: accountColorList[b.color],
                                    icon: accountIconList[b.symbol] ??
                                        Icons.swap_horiz_rounded,
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
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  BankAccount b = accountExpenseList[index];
                                  return AccountListTile(
                                    title: b.name,
                                    nTransactions:
                                        accountToTransactionsExpense[b.id]
                                                ?.length ??
                                            0,
                                    transactions:
                                        accountToTransactionsExpense[b.id] ??
                                            [],
                                    amount: accountToAmountExpense[b.id] ?? 0,
                                    percent:
                                        (accountToAmountExpense[b.id] ?? 0) /
                                            totalExpense *
                                            100,
                                    color: accountColorList[b.color],
                                    icon: accountIconList[b.symbol] ??
                                        Icons.swap_horiz_rounded,
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
