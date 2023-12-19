import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/constants.dart';
import '../../../constants/style.dart';
import '../../../constants/functions.dart';
import '../../../model/category_transaction.dart';
import '../../../model/transaction.dart';
import '../../../pages/transactions_page/widgets/transaction_list_tile.dart';
import '../../../providers/accounts_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../providers/categories_provider.dart';
import '../../../utils/date_helper.dart';

class ListTab extends ConsumerStatefulWidget {
  const ListTab({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ListTab> createState() => _ListTabState();
}

class _ListTabState extends ConsumerState<ListTab> with Functions {
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(transactionsProvider);
    final accounts = ref.watch(accountsProvider);

    // calculate the total for each day
    Map<String, double> totals = {};
    if (transactions.value != null) {
      for (var t in transactions.value!) {
        String date = t.date.toYMD();
        if (totals.containsKey(date)) {
          totals[date] = totals[date]! + t.amount.toDouble();
        } else {
          totals.putIfAbsent(date, () => t.amount.toDouble());
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      color: Theme.of(context).colorScheme.primaryContainer, // da sistemare prima il layout della pagina
      child: transactions.when(
        data: (data) {
          return ListView.separated(
            itemCount: transactions.value!.length,
            itemBuilder: (context, i) {
              if (i == 0) {
                return DateSeparator(
                  transaction: transactions.value![i],
                  total: totals[transactions.value![i].date.toYMD()] ?? 0,
                );
              } else {
                Transaction transaction = transactions.value![i - 1];
                Iterable<CategoryTransaction> tCategories =
                    (transaction.type != Type.transfer &&
                            categories.value != null)
                        ? categories.value!
                            .where((e) => e.id == transaction.idCategory)
                        : [];

                return TransactionListTile(
                  title: transaction.note ?? "Title",
                  amount: transaction.amount.toDouble(),
                  account: accounts.value!
                      .firstWhere((e) => e.id == transaction.idBankAccount)
                      .name,
                  category: (tCategories.isNotEmpty)
                      ? tCategories.first.name
                      : "not found",
                  color: Colors.red,
                  icon: (tCategories.isNotEmpty)
                      ? iconList[tCategories.first.symbol] ??
                          Icons.swap_horiz_rounded
                      : Icons.swap_horiz_rounded,
                );
              }
            },
            separatorBuilder: (context, i) {
              if (i == 0) {
                return const SizedBox(height: 0);
              } else {
                if (!transactions.value![i - 1].date
                    .isSameDate(transactions.value![i].date)) {
                  return DateSeparator(
                    transaction: transactions.value![i],
                    total: totals[transactions.value![i].date.toYMD()] ?? 0,
                  );
                } else {
                  return const Divider(
                    height: 0,
                    thickness: 1,
                    endIndent: 10,
                    indent: 10,
                  );
                }
              }
            },
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(error.toString()),
          );
        },
      ),
    );
  }
}

class DateSeparator extends StatelessWidget {
  const DateSeparator({
    Key? key,
    required this.transaction,
    required this.total,
  }) : super(key: key);

  final Transaction transaction;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            transaction.date.formatDate(),
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(color: blue1),
          ),
          Text(
            "${total.toStringAsFixed(2)} €",
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: (total > 0) ? green : red),
          )
        ],
      ),
    );
  }
}
