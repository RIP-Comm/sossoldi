import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/bank_account.dart';
import '../model/category_transaction.dart';
import '../model/transaction.dart';
import 'accounts_provider.dart';
import 'dashboard_provider.dart';
import 'statistics_provider.dart';

final lastTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final transactions = await TransactionMethods().selectAll(limit: 5);
  return transactions;
});

final transactionTypeList = Provider<List<TransactionType>>(
    (ref) => [TransactionType.income, TransactionType.expense, TransactionType.transfer]);

final transactionTypeProvider = StateProvider<TransactionType>((ref) => TransactionType.expense);
final bankAccountTransferProvider = StateProvider<BankAccount?>((ref) => null);
// Used as from account in transfer transactions
final bankAccountProvider = StateProvider<BankAccount?>((ref) => ref.read(mainAccountProvider));
final dateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final categoryProvider = StateProvider<CategoryTransaction?>((ref) => null);

// Recurring Payment
final selectedRecurringPayProvider = StateProvider<bool>((ref) => false);
final intervalProvider = StateProvider<Recurrence>((ref) => Recurrence.monthly);
final repetitionProvider = StateProvider<dynamic>((ref) => null);

// Set when a transaction is selected for update
final selectedTransactionUpdateProvider = StateProvider<Transaction?>((ref) => null);

// Amount total for the transactions filtered
final totalAmountProvider = StateProvider<num>((ref) => 0);

// Filters
final filterDateStartProvider =
    StateProvider<DateTime>((ref) => DateTime(DateTime.now().year, DateTime.now().month, 1));
final filterDateEndProvider =
    StateProvider<DateTime>((ref) => DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
final typeFilterProvider = StateProvider<Map<String, bool>>(
  (ref) => {
    'IN': false,
    'OUT': false,
    'TR': false,
  },
);

class AsyncTransactionsNotifier extends AutoDisposeAsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    return _getTransactions();
  }

  Future<List<Transaction>> _getTransactions({int? limit, bool update = false}) async {
    if (update) {
      ref.invalidate(lastTransactionsProvider);
      // ignore: unused_result
      ref.refresh(dashboardProvider);
      // ignore: unused_result
      ref.refresh(statisticsProvider);
    }
    final dateStart = ref.watch(filterDateStartProvider);
    final dateEnd = ref.watch(filterDateEndProvider);
    final transactions = await TransactionMethods()
        .selectAll(dateRangeStart: dateStart, dateRangeEnd: dateEnd, limit: limit);

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
    final transactions = await TransactionMethods().selectAll(dateRangeStart: firstDayOfMonth, dateRangeEnd: now);

    return transactions;
  }

  Future<void> filterTransactions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _getTransactions();
    });
  }

  Future<void> addTransaction(num amount, String label) async {
    state = const AsyncValue.loading();

    final type = ref.read(transactionTypeProvider);
    final date = ref.read(dateProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    final bankAccountTransfer = ref.read(bankAccountTransferProvider);
    final category = ref.read(categoryProvider);
    final recurring = ref.read(selectedRecurringPayProvider);

    Transaction transaction = Transaction(
      date: date,
      amount: amount,
      type: type,
      note: label,
      idBankAccount: bankAccount.id!,
      idBankAccountTransfer: bankAccountTransfer?.id,
      idCategory: category?.id,
      recurring: recurring,
    );

    state = await AsyncValue.guard(() async {
      await TransactionMethods().insert(transaction);
      return _getTransactions(update: true);
    });
  }

  Future<void> updateTransaction(num amount, String label) async {
    final type = ref.read(transactionTypeProvider);
    final date = ref.read(dateProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    final bankAccountTransfer = ref.read(bankAccountTransferProvider);
    final category = ref.read(categoryProvider);
    final recurring = ref.read(selectedRecurringPayProvider);

    Transaction transaction = ref.read(selectedTransactionUpdateProvider)!.copy(
          date: date,
          amount: amount,
          type: type,
          note: label,
          idBankAccount: bankAccount.id!,
          idBankAccountTransfer: bankAccountTransfer?.id,
          idCategory: category?.id,
          recurring: recurring,
        );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await TransactionMethods().updateItem(transaction);
      return _getTransactions(update: true);
    });
  }

  Future<void> transactionUpdateState(Transaction transaction) async {
    ref.read(selectedTransactionUpdateProvider.notifier).state = transaction;
    final accountList = ref.watch(accountsProvider);
    if (transaction.type != TransactionType.transfer) {
      if (transaction.idCategory != null) {
        ref.read(categoryProvider.notifier).state =
            await CategoryTransactionMethods().selectById(transaction.idCategory!);
      }
    }
    ref.read(bankAccountProvider.notifier).state =
        accountList.value!.firstWhere((element) => element.id == transaction.idBankAccount);
    ref.read(bankAccountTransferProvider.notifier).state =
        transaction.type == TransactionType.transfer
            ? accountList.value!
                .firstWhere((element) => element.id == transaction.idBankAccountTransfer)
            : null;
    ref.read(transactionTypeProvider.notifier).state = transaction.type;
    ref.read(dateProvider.notifier).state = transaction.date;
    ref.read(selectedRecurringPayProvider.notifier).state = transaction.recurring;
  }

  Future<void> deleteTransaction(int transactionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await TransactionMethods().deleteById(transactionId);
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
    ref.invalidate(repetitionProvider);
    ref.invalidate(transactionTypeProvider);
  }
}

final transactionsProvider =
    AsyncNotifierProvider.autoDispose<AsyncTransactionsNotifier, List<Transaction>>(() {
  return AsyncTransactionsNotifier();
});
