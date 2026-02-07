import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/bank_account.dart';
import '../model/recurring_transaction.dart';
import '../model/transaction.dart';
import '../services/database/repositories/transactions_repository.dart';
import 'accounts_provider.dart';
import 'budgets_provider.dart';
import 'categories_provider.dart';
import 'dashboard_provider.dart';
import 'statistics_provider.dart';

part 'transactions_provider.g.dart';

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

// Amount total for the transactions filtered
@Riverpod(keepAlive: true)
class TotalAmount extends _$TotalAmount {
  @override
  num build() => 0;

  void setTotal(num total) => state = total;
}

// Filters
@riverpod
class FilterLabel extends _$FilterLabel {
  @override
  String? build() => null;

  void setLabel(String value) => state = value;
}

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

@riverpod
class TypeFilter extends _$TypeFilter {
  @override
  Map<String, bool> build() {
    return TransactionType.values.asMap().map(
      (index, type) => MapEntry(type.code, false),
    );
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
    ref.invalidate(transactionsExistsProvider);
    ref.invalidate(lastTransactionsProvider);
    ref.invalidate(accountsProvider);
    ref.invalidate(monthlyBudgetsStatsProvider);
    ref.invalidate(monthlyTransactionsProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(statisticsProvider);
    ref.invalidate(categoryMapProvider);
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

@Riverpod(keepAlive: true)
Future<bool> transactionsExists(Ref ref) async {
  final count = await ref.read(transactionsRepositoryProvider).countAll();
  return count > 0;
}

@Riverpod(keepAlive: true)
Future<List<Transaction>> monthlyTransactions(Ref ref) async {
  final now = DateTime.now();
  final firstDayOfMonth = DateTime(now.year, now.month, 1);
  final transactions = await ref
      .read(transactionsRepositoryProvider)
      .selectAll(dateRangeStart: firstDayOfMonth, dateRangeEnd: now);

  return transactions;
}

@riverpod
Future<List<Transaction>> searchTransactions(Ref ref) async {
  List<String> transactionType = ref
      .watch(typeFilterProvider)
      .entries
      .map((f) => f.value == true ? f.key : "")
      .toList();
  Map<int, bool> filteredAccounts = ref.watch(filterAccountProvider);
  Map<int, bool> filterAccountList = {
    for (var element in filteredAccounts.entries) element.key: element.value,
  };
  String? label = ref.watch(filterLabelProvider);

  final transactions = await ref
      .read(transactionsRepositoryProvider)
      .selectAll(
        limit: 100,
        label: label,
        transactionType: transactionType,
        bankAccounts: filterAccountList,
      );

  return transactions;
}
