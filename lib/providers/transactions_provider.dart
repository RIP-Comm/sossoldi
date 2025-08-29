import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/bank_account.dart';
import '../model/category_transaction.dart';
import '../model/recurring_transaction.dart';
import '../model/transaction.dart';
import '../utils/location_bag.dart';
import 'accounts_provider.dart';
import 'budgets_provider.dart';
import 'dashboard_provider.dart';
import 'statistics_provider.dart';

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
    StateProvider<BankAccount?>((ref) => ref.read(mainAccountProvider));
final dateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final categoryProvider = StateProvider<CategoryTransaction?>((ref) => null);
final locationTransactionProvider = StateProvider<LocationBag?>((ref) => null);

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

    final TransactionType t = type ?? ref.read(transactionTypeProvider);

    Transaction transaction = Transaction(
      date: date ?? ref.read(dateProvider),
      amount: amount,
      type: t,
      note: label,
      idBankAccount: (account ?? ref.read(bankAccountProvider))!.id!,
      idBankAccountTransfer:
          account != null ? null : ref.read(bankAccountTransferProvider)?.id,
      idCategory: account != null || t == TransactionType.transfer
          ? null
          : ref.read(categoryProvider)?.id,
      recurring:
          account != null ? false : ref.read(selectedRecurringPayProvider),
      locationName: ref.read(locationTransactionProvider)?.searchText,
      lat: ref.read(locationTransactionProvider)?.latitude,
      lon: ref.read(locationTransactionProvider)?.longitude,
    );
    final a = 1;
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
      num amount, String label, TransactionType type) async {
    state = const AsyncValue.loading();

    final date = ref.read(dateProvider);
    final toDate = ref.read(endDateProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    final category = ref.read(categoryProvider);
    final recurrency = ref.read(intervalProvider.notifier).state;
    final location = ref.read(locationTransactionProvider);

    RecurringTransaction transaction = RecurringTransaction(
        amount: amount,
        fromDate: date,
        toDate: toDate,
        note: label,
        type: type,
        idBankAccount: bankAccount.id!,
        idCategory: category!.id!,
        recurrency: recurrency.name.toUpperCase(),
        createdAt: date,
        updatedAt: date,
        locationName: location?.searchText,
        lat: location?.latitude,
        lon: location?.longitude,
        lastInsertion: date);

    // Here we need the recurringTransaction just inserted, to get and return a model with also his ID
    RecurringTransaction? insertedTransaction;
    state = await AsyncValue.guard(() async {
      insertedTransaction =
          await RecurringTransactionMethods().insert(transaction);
      return _getTransactions(update: true);
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
        locationName: location?.searchText,
        lat: location?.latitude,
        lon: location?.longitude,
      );
      await TransactionMethods().insert(transaction);
    }

    return insertedTransaction;
  }

  Future<void> updateTransaction(num amount, String label,
      [int? recurringTransactionId]) async {
    final type = ref.read(transactionTypeProvider);
    final date = ref.read(dateProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    final bankAccountTransfer = ref.read(bankAccountTransferProvider);
    final category = ref.read(categoryProvider);
    final location = ref.read(locationTransactionProvider);

    Transaction transaction = ref.read(selectedTransactionUpdateProvider)!.copy(
        date: date,
        amount: amount,
        type: type,
        note: label,
        idBankAccount: bankAccount.id!,
        idBankAccountTransfer: bankAccountTransfer?.id,
        idCategory: category?.id,
        idRecurringTransaction: recurringTransactionId,
        locationName: location?.searchText,
        lat: location?.latitude,
        lon: location?.longitude,
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
    final location = ref.read(locationTransactionProvider);

    final RecurringTransaction transaction = ref
        .read(selectedRecurringTransactionUpdateProvider)!
        .copy(
            fromDate: ref.read(dateProvider),
            toDate: ref.read(endDateProvider),
            recurrency: recurrency.name.toUpperCase(),
            amount: amount,
            note: label,
            idBankAccount: bankAccount.id!,
            idCategory: category?.id,
            locationName: location?.searchText,
            lat: location?.latitude,
            lon: location?.longitude,
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
    ref.read(locationTransactionProvider.notifier).state =
          transaction.locationName != null
              ? LocationBag(
                  searchText: transaction.locationName ?? '',
                  latitude: transaction.lat?.toDouble() ?? 0.0,
                  longitude: transaction.lon?.toDouble() ?? 0.0)
              : null;
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
    ref.invalidate(locationTransactionProvider);
    ref.invalidate(selectedRecurringPayProvider);
    ref.invalidate(intervalProvider);
    ref.invalidate(transactionTypeProvider);
  }
}

final transactionsProvider = AsyncNotifierProvider.autoDispose<
    AsyncTransactionsNotifier, List<Transaction>>(() {
  return AsyncTransactionsNotifier();
});
