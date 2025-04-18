import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/bank_account.dart';
import '../model/category_transaction.dart';
import '../model/recurring_transaction.dart';
import '../model/transaction.dart';
import 'accounts_provider.dart';
import 'budgets_provider.dart';
import 'dashboard_provider.dart';
import 'statistics_provider.dart';
import '../ui/extensions.dart';

final lastTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactions = await TransactionMethods().selectAll(limit: 5);
  return transactions;
});

final transactionTypeList = Provider<List<TransactionType>>((ref) => [
      TransactionType.income,
      TransactionType.expense,
      TransactionType.transfer
    ]);

final transactionTypeProvider =
    StateProvider<TransactionType>((ref) => TransactionType.expense);
final bankAccountTransferProvider = StateProvider<BankAccount?>((ref) => null);
// Used as from account in transfer transactions
final bankAccountProvider =
    StateProvider<BankAccount?>((ref) => ref.watch(mainAccountProvider));
final dateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final categoryProvider = StateProvider<CategoryTransaction?>((ref) => null);

// Recurring Payment
final selectedRecurringPayProvider = StateProvider<bool>((ref) => false);
final intervalProvider = StateProvider<Recurrence>((ref) => Recurrence.monthly);
final endDateProvider = StateProvider<DateTime?>((ref) => null);

// Set when a transaction is selected for update
final selectedTransactionUpdateProvider =
    StateProvider<Transaction?>((ref) => null);
final selectedRecurringTransactionUpdateProvider =
    StateProvider<RecurringTransaction?>((ref) => null);

// Amount total for the transactions filtered
final totalAmountProvider = StateProvider<num>((ref) => 0);

// Filters
final filterDateStartProvider = StateProvider<DateTime>(
    (ref) => DateTime(DateTime.now().year, DateTime.now().month, 1));
final filterDateEndProvider = StateProvider<DateTime>(
    (ref) => DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
final typeFilterProvider = StateProvider<Map<String, bool>>(
  (ref) => {
    'IN': false,
    'OUT': false,
    'TR': false,
  },
);

final duplicatedTransactoinProvider =
    StateProvider<Transaction?>((ref) => null);

class AsyncTransactionsNotifier
    extends AutoDisposeAsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    return _getTransactions();
  }

  Future<List<Transaction>> _getTransactions(
      {int? limit, bool update = false}) async {
    if (update) {
      ref.invalidate(lastTransactionsProvider);
      // Refresh the accounts list
      ref.invalidate(accountsProvider);
      // Refresh the budgets list
      ref.invalidate(monthlyBudgetsStatsProvider);
      // ignore: unused_result
      ref.refresh(dashboardProvider);
      // ignore: unused_result
      ref.refresh(statisticsProvider);
    }
    final dateStart = ref.watch(filterDateStartProvider);
    final dateEnd = ref.watch(filterDateEndProvider);

    final transactions = await TransactionMethods().selectAll(
        dateRangeStart: dateStart, dateRangeEnd: dateEnd, limit: limit);

    ref.read(totalAmountProvider.notifier).state = transactions.fold<num>(
        0,
        (prev, transaction) => transaction.type == TransactionType.transfer
            ? prev
            : transaction.type == TransactionType.expense
                ? prev - transaction.amount
                : prev + transaction.amount);
    return transactions;
  }

  Future<List<Transaction>> getMonthlyTransactions() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final transactions = await TransactionMethods()
        .selectAll(dateRangeStart: firstDayOfMonth, dateRangeEnd: now);

    return transactions;
  }

  Future<void> filterTransactions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _getTransactions();
    });
  }

  Future<void> addTransaction(num amount, String label,
      {BankAccount? account, DateTime? date, TransactionType? type}) async {
    state = const AsyncValue.loading();

    Transaction transaction = Transaction(
      date: date ?? ref.read(dateProvider),
      amount: amount,
      type: type ?? ref.read(transactionTypeProvider),
      note: label,
      idBankAccount: (account ?? ref.read(bankAccountProvider))!.id!,
      idBankAccountTransfer:
          account != null ? null : ref.read(bankAccountTransferProvider)?.id,
      idCategory: account != null ? null : ref.read(categoryProvider)?.id,
      recurring:
          account != null ? false : ref.read(selectedRecurringPayProvider),
    );

    state = await AsyncValue.guard(() async {
      await TransactionMethods().insert(transaction);
      return _getTransactions(update: true);
    });
  }

  Future<Transaction?> duplicateTransaction(Transaction transaction) async {
    final duplicatedTransaction = transaction.copy(
      id: null,
      note: "${transaction.note} (copy)",
    );
    Transaction? insertedTransaction;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      insertedTransaction =
          await TransactionMethods().insert(duplicatedTransaction);
      ref.read(duplicatedTransactoinProvider.notifier).state =
          insertedTransaction;
      return _getTransactions(update: true);
    });
    return insertedTransaction;
  }

  Future<RecurringTransaction?> addRecurringTransaction(
      num amount, String label) async {
    state = const AsyncValue.loading();

    final date = ref.read(dateProvider);
    final toDate = ref.read(endDateProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    final category = ref.read(categoryProvider);
    final type = ref.read(transactionTypeProvider);
    final recurrency = ref.read(intervalProvider.notifier).state;

    final RecurringTransaction recurringTransaction =
        _createRecurringTransactionObject(
      date: date,
      toDate: toDate,
      amount: amount,
      note: label,
      type: type,
      idBankAccount: bankAccount.id!,
      idCategory: category!.id!,
      recurrency: recurrency.name.toUpperCase(),
    );

    RecurringTransaction? insertedTransaction;
    state = await AsyncValue.guard(() async {
      insertedTransaction =
          await RecurringTransactionMethods().insert(recurringTransaction);
      return _getTransactions(update: true);
    });

    if (insertedTransaction?.id != null) {
      await _generateTransactionsForRecurringTransaction(insertedTransaction!,
          amount, label, bankAccount.id!, category.id!, date, recurrency);
    }

    return insertedTransaction;
  }

  RecurringTransaction _createRecurringTransactionObject({
    required DateTime date,
    required DateTime? toDate,
    required num amount,
    required String note,
    required TransactionType type,
    required int idBankAccount,
    required int idCategory,
    required String recurrency,
  }) {
    return RecurringTransaction(
        amount: amount,
        fromDate: date,
        toDate: toDate,
        note: note,
        idBankAccount: idBankAccount,
        idCategory: idCategory,
        recurrency: recurrency,
        type: type,
        createdAt: date,
        updatedAt: date,
        lastInsertion: date);
  }

  Future<void> _generateTransactionsForRecurringTransaction(
      RecurringTransaction recurringTransaction,
      num amount,
      String label,
      int idBankAccount,
      int idCategory,
      DateTime startDate,
      Recurrence recurrency) async {
    DateTime now = DateTime.now();

    if (startDate.isBefore(now)) {
      await _createPastTransactions(startDate, now, recurrency,
          recurringTransaction.id!, amount, label, idBankAccount, idCategory);
    } else if (startDate.isSameDay(now)) {
      await _createSingleTransaction(
        date: startDate,
        amount: amount,
        note: label,
        idBankAccount: idBankAccount,
        idCategory: idCategory,
        idRecurringTransaction: recurringTransaction.id!,
      );
    }
  }

  Future<void> _createPastTransactions(
      DateTime startDate,
      DateTime endDate,
      Recurrence recurrency,
      int recurringTransactionId,
      num amount,
      String label,
      int idBankAccount,
      int idCategory) async {
    // Calcola tutte le date passate in cui creare transazioni
    List<DateTime> transactionDates =
        calculatePastTransactionDates(startDate, endDate, recurrency);

    for (var transactionDate in transactionDates) {
      await _createSingleTransaction(
        date: transactionDate,
        amount: amount,
        note: label,
        idBankAccount: idBankAccount,
        idCategory: idCategory,
        idRecurringTransaction: recurringTransactionId,
      );
    }
  }

  List<DateTime> calculatePastTransactionDates(
      DateTime startDate, DateTime endDate, Recurrence recurrence) {
    List<DateTime> dates = [];
    DateTime currentDate = startDate;

    final recurrencyEntry = recurrenciesMap[recurrence.name.toUpperCase()];
    final entity = recurrencyEntry?['entity'] as String;
    final intervalAmount = recurrencyEntry?['amount'] as int;

    while (currentDate.isBefore(endDate)) {
      dates.add(currentDate);

      if (entity == 'days') {
        currentDate = currentDate.add(Duration(days: intervalAmount));
      } else if (entity == 'months') {
        currentDate =
            _calculateNextMonthDate(currentDate, intervalAmount, startDate.day);
      }
    }

    return dates;
  }

  DateTime _calculateNextMonthDate(
      DateTime currentDate, int monthsToAdd, int originalDay) {
    int lastDayOfNextPeriod =
        DateTime(currentDate.year, (currentDate.month + monthsToAdd + 1), 0)
            .day;

    int dayOfInsertion = originalDay;
    if (originalDay > lastDayOfNextPeriod) {
      dayOfInsertion = lastDayOfNextPeriod;
    }

    return DateTime(
        currentDate.year, currentDate.month + monthsToAdd, dayOfInsertion);
  }

  Future<void> _createSingleTransaction({
    required DateTime date,
    required num amount,
    required String note,
    required int idBankAccount,
    required int idCategory,
    required int idRecurringTransaction,
  }) async {
    final transaction = Transaction(
      date: date,
      amount: amount,
      type: TransactionType.expense,
      note: note,
      idBankAccount: idBankAccount,
      idCategory: idCategory,
      idRecurringTransaction: idRecurringTransaction,
      recurring: true,
    );

    await TransactionMethods().insert(transaction);
  }

  Future<void> updateTransaction(num amount, String label,
      [int? recurringTransactionId]) async {
    final type = ref.read(transactionTypeProvider);
    final date = ref.read(dateProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    final bankAccountTransfer = ref.read(bankAccountTransferProvider);
    final category = ref.read(categoryProvider);

    Transaction transaction = ref.read(selectedTransactionUpdateProvider)!.copy(
        date: date,
        amount: amount,
        type: type,
        note: label,
        idBankAccount: bankAccount.id!,
        idBankAccountTransfer: bankAccountTransfer?.id,
        idCategory: category?.id,
        idRecurringTransaction: recurringTransactionId,
        recurring: recurringTransactionId != null ? true : false);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await TransactionMethods().updateItem(transaction);
      return _getTransactions(update: true);
    });
  }

  Future<void> updateRecurringTransaction(num amount, String label) async {
    final bankAccount = ref.read(bankAccountProvider)!;
    final recurrency = ref.read(intervalProvider.notifier).state;
    final category = ref.read(categoryProvider);

    RecurringTransaction transaction = ref
        .read(selectedRecurringTransactionUpdateProvider)!
        .copy(
            fromDate: ref.read(dateProvider),
            toDate: ref.read(endDateProvider),
            recurrency: recurrency.name.toUpperCase(),
            amount: amount,
            note: label,
            idBankAccount: bankAccount.id!,
            idCategory: category?.id,
            updatedAt: DateTime.now());

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await RecurringTransactionMethods().updateItem(transaction);
      return _getTransactions(update: true);
    });
  }

  Future<void> addRecurringDataToTransaction(
      num idTransaction, num idRecurringTransaction) async {}

  Future<void> transactionUpdateState(dynamic transaction) async {
    if (transaction is Transaction) {
      ref.read(selectedTransactionUpdateProvider.notifier).state = transaction;
      ref.read(selectedRecurringPayProvider.notifier).state =
          transaction.recurring;

      final accountList = ref.watch(accountsProvider);
      if (transaction.type != TransactionType.transfer) {
        if (transaction.idCategory != null) {
          ref.read(categoryProvider.notifier).state =
              await CategoryTransactionMethods()
                  .selectById(transaction.idCategory!);
        }
      }

      ref.read(bankAccountProvider.notifier).state = accountList.value!
          .firstWhere((element) => element.id == transaction.idBankAccount);
      ref.read(bankAccountTransferProvider.notifier).state =
          transaction.type == TransactionType.transfer
              ? accountList.value!.firstWhere(
                  (element) => element.id == transaction.idBankAccountTransfer)
              : null;
      ref.read(transactionTypeProvider.notifier).state = transaction.type;
      ref.read(dateProvider.notifier).state = transaction.date;
    } else if (transaction is RecurringTransaction) {
      ref.read(selectedRecurringTransactionUpdateProvider.notifier).state =
          transaction;
      ref.read(selectedRecurringPayProvider.notifier).state = true;
      ref.read(categoryProvider.notifier).state =
          await CategoryTransactionMethods().selectById(transaction.idCategory);
      ref.read(bankAccountProvider.notifier).state = ref
          .watch(accountsProvider)
          .value!
          .firstWhere((element) => element.id == transaction.idBankAccount);
      ref.read(intervalProvider.notifier).state =
          parseRecurrence(transaction.recurrency);
      ref.read(endDateProvider.notifier).state = transaction.toDate;
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await TransactionMethods().deleteById(transactionId);
      return _getTransactions(update: true);
    });
  }

  Future<void> deleteRecurringTransaction(int transactionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await RecurringTransactionMethods().deleteById(transactionId);
      return _getTransactions(update: true);
    });
  }

  void switchAccount() {
    final fromAccount = ref.read(bankAccountProvider);
    final toAccount = ref.read(bankAccountTransferProvider);
    if (fromAccount != null && toAccount != null) {
      ref.read(bankAccountProvider.notifier).state = toAccount;
      ref.read(bankAccountTransferProvider.notifier).state = fromAccount;
    }
  }

  void reset() {
    ref.invalidate(selectedTransactionUpdateProvider);
    ref.invalidate(bankAccountProvider);
    ref.invalidate(bankAccountTransferProvider);
    ref.invalidate(dateProvider);
    ref.invalidate(categoryProvider);
    ref.invalidate(selectedRecurringPayProvider);
    ref.invalidate(intervalProvider);
    ref.invalidate(transactionTypeProvider);
  }
}

final transactionsProvider = AsyncNotifierProvider.autoDispose<
    AsyncTransactionsNotifier, List<Transaction>>(() {
  return AsyncTransactionsNotifier();
});
