import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/bank_account.dart';
import '../model/recurring_transaction.dart';
import '../model/transaction.dart';
import '../services/database/repositories/recurring_transactions_repository.dart';
import '../services/database/repositories/transactions_repository.dart';
import 'accounts_provider.dart';
import 'budgets_provider.dart';
import 'categories_provider.dart';
import 'dashboard_provider.dart';
import 'statistics_provider.dart';

part 'transactions_provider.g.dart';

// @riverpod
// class SelectedTransactionType extends _$SelectedTransactionType {
//   @override
//   TransactionType build() {
//     return TransactionType.income;
//   }

//   void setType(TransactionType type) {
//     state = type;
//   }
// }

@riverpod
class SelectedTransactionType extends _$SelectedTransactionType {
  @override
  TransactionType build() => TransactionType.expense;

  void setType(TransactionType type) => state = type;
}

@riverpod
class SelectedListIndex extends _$SelectedListIndex {
  @override
  int build() => -1;

  void setIndex(int index) => state = index;
}

@Riverpod(keepAlive: true)
Future<List<Transaction>> lastTransactions(Ref ref) async {
  final transactions = await ref
      .read(transactionsRepositoryProvider)
      .selectAll(limit: 5);
  return transactions;
}

@Riverpod(keepAlive: true)
Future<List<RecurringTransaction>> recurringTransactions(Ref ref) async {
  return await ref
      .read(recurringTransactionRepositoryProvider)
      .selectAllActive();
}

// final transactionTypeList = Provider<List<TransactionType>>((ref) => [
//       TransactionType.income,
//       TransactionType.expense,
//       TransactionType.transfer
//     ]);

// @Riverpod(keepAlive: true)
// class TransactionType extends _$TransactionType {
//   @override
//   TransactionType build() {
//     return TransactionType.expense;
//   }

//   void setType(TransactionType type) {
//     state = type;
//   }
// }

@Riverpod(keepAlive: true)
class BankAccountTransfer extends _$BankAccountTransfer {
  @override
  BankAccount? build() => null;

  void setAccount(BankAccount? account) => state = account;
}

@Riverpod(keepAlive: true)
class SelectedBankAccount extends _$SelectedBankAccount {
  @override
  BankAccount? build() => ref.read(mainAccountProvider);

  void setAccount(BankAccount? account) => state = account;
}

@Riverpod(keepAlive: true)
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

// Recurring Payment
@Riverpod(keepAlive: true)
class SelectedRecurringPay extends _$SelectedRecurringPay {
  @override
  bool build() => false;

  void setValue(bool value) => state = value;
}

@Riverpod(keepAlive: true)
class Interval extends _$Interval {
  @override
  Recurrence build() => Recurrence.monthly;

  void setValue(Recurrence recurrence) => state = recurrence;
}

@Riverpod(keepAlive: true)
class EndDate extends _$EndDate {
  @override
  DateTime? build() => null;

  void setDate(DateTime? date) => state = date;
}

@Riverpod(keepAlive: true)
class SelectedRecurringTransactionUpdate
    extends _$SelectedRecurringTransactionUpdate {
  @override
  RecurringTransaction? build() => null;

  void setValue(RecurringTransaction? value) => state = value;
}

// Amount total for the transactions filtered
@Riverpod(keepAlive: true)
class TotalAmount extends _$TotalAmount {
  @override
  num build() => 0;

  void setTotal(num total) => state = total;
}

// Filters
@Riverpod(keepAlive: true)
class FilterDateStart extends _$FilterDateStart {
  @override
  DateTime build() => DateTime(DateTime.now().year, DateTime.now().month, 1);

  void setDate(DateTime date) => state = date;
}

@Riverpod(keepAlive: true)
class FilterDateEnd extends _$FilterDateEnd {
  @override
  DateTime build() =>
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  void setDate(DateTime date) => state = date;
}

@Riverpod(keepAlive: true)
class TypeFilter extends _$TypeFilter {
  @override
  Map<String, bool> build() {
    return {
      TransactionType.income.code: false,
      TransactionType.expense.code: false,
      TransactionType.transfer.code: false,
    };
  }

  void setFilter(Map<String, bool> filter) => state = filter;
}

@Riverpod(keepAlive: true)
class DuplicatedTransaction extends _$DuplicatedTransaction {
  @override
  Transaction? build() => null;

  void setTransaction(Transaction? transaction) => state = transaction;
}

@Riverpod(keepAlive: true)
class TransactionsNotifier extends _$TransactionsNotifier {
  @override
  Future<List<Transaction>> build() async {
    return await _getTransactions();
  }

  Future<List<Transaction>> _getTransactions({int? limit}) async {
    ref.invalidate(lastTransactionsProvider);
    ref.invalidate(accountsProvider);
    ref.invalidate(monthlyBudgetsStatsProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(statisticsProvider);
    final dateStart = ref.watch(filterDateStartProvider);
    final dateEnd = ref.watch(filterDateEndProvider);
    final transactions = await ref
        .read(transactionsRepositoryProvider)
        .selectAll(
          dateRangeStart: dateStart,
          dateRangeEnd: dateEnd,
          limit: limit,
        );

    ref.read(totalAmountProvider.notifier).state = transactions.fold<num>(
      0,
      (prev, transaction) => transaction.type == TransactionType.transfer
          ? prev
          : transaction.type == TransactionType.expense
          ? prev - transaction.amount
          : prev + transaction.amount,
    );
    return transactions;
  }

  Future<List<Transaction>> getMonthlyTransactions() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final transactions = await ref
        .read(transactionsRepositoryProvider)
        .selectAll(dateRangeStart: firstDayOfMonth, dateRangeEnd: now);

    return transactions;
  }

  Future<void> filterTransactions() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _getTransactions();
    });
  }

  Future<void> create(
    num amount,
    String label, {
    BankAccount? account,
    DateTime? date,
    TransactionType? type,
  }) async {
    state = const AsyncLoading();

    final TransactionType t = type ?? ref.read(selectedTransactionTypeProvider);

    Transaction transaction = Transaction(
      date: date ?? ref.read(selectedDateProvider),
      amount: amount,
      type: t,
      note: label,
      idBankAccount: (account ?? ref.read(selectedBankAccountProvider))!.id!,
      idBankAccountTransfer: account != null
          ? null
          : ref.read(bankAccountTransferProvider)?.id,
      idCategory: account != null || t == TransactionType.transfer
          ? null
          : ref.read(selectedCategoryProvider)?.id,
      recurring: account != null
          ? false
          : ref.read(selectedRecurringPayProvider),
    );

    state = await AsyncValue.guard(() async {
      await ref.read(transactionsRepositoryProvider).insert(transaction);
      return await _getTransactions();
    });
  }

  Future<Transaction?> duplicateTransaction(Transaction transaction) async {
    final duplicatedTransaction = transaction.copy(
      id: null,
      note: "${transaction.note} (copy)",
    );
    Transaction? insertedTransaction;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      insertedTransaction = await ref
          .read(transactionsRepositoryProvider)
          .insert(duplicatedTransaction);
      ref.read(duplicatedTransactionProvider.notifier).state =
          insertedTransaction;
      return await _getTransactions();
    });
    return insertedTransaction;
  }

  Future<void> updateTransaction(
    Transaction transaction,
    num amount,
    String label, [
    int? recurringTransactionId,
  ]) async {
    final type = ref.read(selectedTransactionTypeProvider);
    final date = ref.read(selectedDateProvider);
    final bankAccount = ref.read(selectedBankAccountProvider)!;
    final bankAccountTransfer = ref.read(bankAccountTransferProvider);
    final category = ref.read(selectedCategoryProvider);

    Transaction transactionCopy = transaction.copy(
      date: date,
      amount: amount,
      type: type,
      note: label,
      idBankAccount: bankAccount.id!,
      idBankAccountTransfer: bankAccountTransfer?.id,
      idCategory: category?.id,
      idRecurringTransaction: recurringTransactionId,
      recurring: recurringTransactionId != null ? true : false,
    );

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(transactionsRepositoryProvider)
          .updateItem(transactionCopy);
      return await _getTransactions();
    });
  }

  Future<void> transactionSelect(Transaction transaction) async {
    state = const AsyncLoading();
    ref.read(selectedRecurringPayProvider.notifier).state =
        transaction.recurring;
    if (transaction.type != TransactionType.transfer &&
        transaction.idCategory != null) {
      ref.read(selectedCategoryProvider.notifier).state = ref
          .read(categoriesProvider)
          .value!
          .firstWhere((element) => element.id == transaction.idCategory!);
    }
    ref.read(selectedBankAccountProvider.notifier).state = ref
        .read(accountsProvider)
        .value!
        .firstWhere((element) => element.id == transaction.idBankAccount);
    ref
        .read(bankAccountTransferProvider.notifier)
        .state = transaction.type == TransactionType.transfer
        ? ref
              .read(accountsProvider)
              .value!
              .firstWhere(
                (element) => element.id == transaction.idBankAccountTransfer,
              )
        : null;
    ref.read(selectedTransactionTypeProvider.notifier).state = transaction.type;
    ref.read(selectedDateProvider.notifier).state = transaction.date;

    state = await AsyncValue.guard(() async {
      return await _getTransactions();
    });
  }

  Future<void> delete(int transactionId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionsRepositoryProvider).deleteById(transactionId);
      return await _getTransactions();
    });
  }

  void switchAccount() {
    final fromAccount = ref.read(selectedBankAccountProvider);
    final toAccount = ref.read(bankAccountTransferProvider);
    if (fromAccount != null && toAccount != null) {
      ref.read(selectedBankAccountProvider.notifier).state = toAccount;
      ref.read(bankAccountTransferProvider.notifier).state = fromAccount;
    }
  }

  void reset() {
    ref.invalidate(selectedBankAccountProvider);
    ref.invalidate(bankAccountTransferProvider);
    ref.invalidate(selectedDateProvider);
    ref.invalidate(selectedCategoryProvider);
    ref.invalidate(selectedRecurringPayProvider);
    ref.invalidate(intervalProvider);
    ref.invalidate(selectedTransactionTypeProvider);
  }
}

@riverpod
class RecurringTransactionNotifier extends _$RecurringTransactionNotifier {
  @override
  AsyncValue<RecurringTransaction?> build() {
    return const AsyncValue.data(null);
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
      return insertedTransaction;
    });

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

    return insertedTransaction;
  }

  Future<void> update(num amount, String label) async {
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
      return transaction;
    });
  }

  Future<void> addRecurringDataToTransaction(
    num idTransaction,
    num idRecurringTransaction,
  ) async {}

  Future<void> transactionSelect(RecurringTransaction transaction) async {
    state = const AsyncLoading();
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
    state = await AsyncValue.guard(() async => transaction);
  }

  Future<void> delete(int transactionId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(recurringTransactionRepositoryProvider)
          .deleteById(transactionId);
      return null;
    });
  }
}
