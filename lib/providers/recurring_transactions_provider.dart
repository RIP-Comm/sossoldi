import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/recurring_transaction.dart';
import '../model/transaction.dart';
import '../services/database/repositories/recurring_transactions_repository.dart';
import '../services/database/repositories/transactions_repository.dart';
import 'accounts_provider.dart';
import 'categories_provider.dart';
import 'transactions_provider.dart';

part 'recurring_transactions_provider.g.dart';

@Riverpod(keepAlive: true)
class SelectedRecurringTransactionUpdate
    extends _$SelectedRecurringTransactionUpdate {
  @override
  RecurringTransaction? build() => null;

  void setValue(RecurringTransaction? value) => state = value;
}

@Riverpod(keepAlive: true)
class RecurringTransactionsNotifier extends _$RecurringTransactionsNotifier {
  @override
  Future<List<RecurringTransaction>> build() {
    return _getRecurringTransactions();
  }

  Future<List<RecurringTransaction>> _getRecurringTransactions() async {
    final transactions = await ref
        .read(recurringTransactionRepositoryProvider)
        .selectAllActive();
    return transactions;
  }

  Future<RecurringTransaction?> create(
    num amount,
    String label,
    TransactionType type,
  ) async {
    state = const AsyncLoading();

    final date = ref.read(selectedDateProvider);
    final toDate = ref.read(endDateProvider);
    final bankAccount = ref.read(selectedBankAccountProvider)!;
    final category = ref.read(selectedCategoryProvider);
    final recurrency = ref.read(intervalProvider);

    RecurringTransaction transaction = RecurringTransaction(
      amount: amount,
      fromDate: date,
      toDate: toDate,
      note: label,
      type: type,
      idBankAccount: bankAccount.id!,
      idCategory: category!.id!,
      recurrency: recurrency,
      createdAt: date,
      updatedAt: date,
      lastInsertion: date,
    );

    // Here we need the recurringTransaction just inserted, to get and return a model with also his ID
    RecurringTransaction? insertedTransaction;

    state = await AsyncValue.guard(() async {
      insertedTransaction = await ref
          .read(recurringTransactionRepositoryProvider)
          .insert(transaction);

      // check if fromDate is today, and add the first recurrence of the transaction
      DateTime now = DateTime.now();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        final transaction = Transaction(
          date: date,
          amount: amount,
          type: type,
          note: label,
          idBankAccount: bankAccount.id!,
          idCategory: category.id!,
          idRecurringTransaction: insertedTransaction!.id,
          recurring: true,
        );
        await ref.read(transactionsRepositoryProvider).insert(transaction);
      }
      return await _getRecurringTransactions();
    });

    return insertedTransaction;
  }

  Future<void> updateTransaction(num amount, String label) async {
    final bankAccount = ref.read(selectedBankAccountProvider)!;
    final recurrency = ref.read(intervalProvider);
    final category = ref.read(selectedCategoryProvider);

    final RecurringTransaction transaction = ref
        .read(selectedRecurringTransactionUpdateProvider)!
        .copy(
          fromDate: ref.read(selectedDateProvider),
          toDate: ref.read(endDateProvider),
          recurrency: recurrency,
          amount: amount,
          note: label,
          idBankAccount: bankAccount.id!,
          idCategory: category?.id,
          updatedAt: DateTime.now(),
        );

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(recurringTransactionRepositoryProvider)
          .updateItem(transaction);
      return await _getRecurringTransactions();
    });
  }

  Future<void> transactionSelect(RecurringTransaction transaction) async {
    ref
        .read(selectedRecurringTransactionUpdateProvider.notifier)
        .setValue(transaction);
    ref.read(selectedRecurringPayProvider.notifier).setValue(true);
    ref.read(selectedCategoryProvider.notifier).state = ref
        .read(categoriesProvider)
        .value!
        .firstWhere((element) => element.id == transaction.idCategory);
    ref.read(selectedBankAccountProvider.notifier).state = ref
        .read(accountsProvider)
        .value!
        .firstWhere((element) => element.id == transaction.idBankAccount);
    ref.read(intervalProvider.notifier).setValue(transaction.recurrency);
    ref.read(endDateProvider.notifier).setDate(transaction.toDate);
  }

  Future<void> delete(int transactionId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(recurringTransactionRepositoryProvider)
          .deleteById(transactionId);
      return _getRecurringTransactions();
    });
  }
}

class RecurringPaymentsGrouped {
  final int year;
  final Map<String, num> transactionsByMonth;

  RecurringPaymentsGrouped({
    required this.year,
    required this.transactionsByMonth,
  });
}

@riverpod
Future<List<RecurringPaymentsGrouped>> recurringPayments(
  Ref ref,
  int id,
) async {
  final transactions = await ref
      .read(transactionsRepositoryProvider)
      .getRecurrenceTransactionsById(id: id);

  Map<int, Map<String, num>> groupedData = {};
  for (var transaction in transactions) {
    final year = transaction.date.year;
    final month = DateFormat.MMMM().format(transaction.date);

    groupedData.putIfAbsent(year, () => {});
    groupedData[year]!.putIfAbsent(month, () => 0);
    groupedData[year]![month] = groupedData[year]![month]! + transaction.amount;
  }
  List<RecurringPaymentsGrouped> result = [];
  groupedData.forEach((year, transactionsByMonth) {
    result.add(
      RecurringPaymentsGrouped(
        year: year,
        transactionsByMonth: transactionsByMonth,
      ),
    );
  });
  return result;
}
