import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'accounts_provider.dart';
import '../model/bank_account.dart';
import '../model/transaction.dart';
import '../model/category_transaction.dart';

final transactionTypeList =
    Provider<List<Type>>((ref) => [Type.income, Type.expense, Type.transfer]);

final transactionTypesProvider =
    StateProvider.autoDispose<List<bool>>((ref) => [false, true, false]);
final toAccountProvider = StateProvider.autoDispose<BankAccount?>((ref) => null);
// Used as from account in transfer transactions
final bankAccountProvider =
    StateProvider.autoDispose<BankAccount?>((ref) => ref.read(mainAccountProvider));
final dateProvider = StateProvider.autoDispose<DateTime>((ref) => DateTime.now());
final categoryProvider = StateProvider.autoDispose<CategoryTransaction?>((ref) => null);
final amountProvider = StateProvider.autoDispose<num>((ref) => 0);
final noteProvider = StateProvider.autoDispose<String?>((ref) => null);

//Recurring Payment
final selectedRecurringPayProvider = StateProvider.autoDispose<bool>((ref) => false);
final intervalProvider = StateProvider.autoDispose<Recurrence>((ref) => Recurrence.monthly);
// final repetitionProvider = StateProvider.autoDispose<dynamic>((ref) => null);

class AsyncTransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    return _getTransactions();
  }

  Future<List<Transaction>> _getTransactions() async {
    final transaction = await TransactionMethods().selectAll(limit: 5);
    return transaction;
  }

  Future<void> addTransaction() async {
    final typeIndex = ref.read(transactionTypesProvider).indexOf(true);
    final date = ref.read(dateProvider);
    final amount = ref.read(amountProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    final category = ref.read(categoryProvider)!;
    final note = ref.read(noteProvider);
    state = const AsyncValue.loading();

    Transaction transaction = Transaction(
      date: date,
      amount: amount,
      type: ref.watch(transactionTypeList)[typeIndex],
      note: note,
      idBankAccount: bankAccount.id!,
      idCategory: category.id!,
      recurring: false,
    );

    state = await AsyncValue.guard(() async {
      await TransactionMethods().insert(transaction);
      return _getTransactions();
    });
  }

  Future<void> addTransfer() async {
    final date = ref.read(dateProvider);
    final amount = ref.read(amountProvider);
    final fromAccount = ref.read(bankAccountProvider)!;
    final toAccount = ref.read(toAccountProvider)!;
    final note = ref.read(noteProvider);
    state = const AsyncValue.loading();

    Transaction transaction = Transaction(
      date: date,
      amount: amount,
      type: Type.transfer,
      note: note,
      idBankAccount: fromAccount.id!,
      idBankAccountTransfer: toAccount.id!,
      idCategory: 0,
      recurring: false,
    );

    state = await AsyncValue.guard(() async {
      await TransactionMethods().insert(transaction);
      return _getTransactions();
    });
  }

  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await TransactionMethods().updateItem(transaction);
      return _getTransactions();
    });
  }

  Future<void> removeTransaction(int transactionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await TransactionMethods().deleteById(transactionId);
      return _getTransactions();
    });
  }

  void switchAccount() {
    final fromAccount = ref.read(bankAccountProvider);
    final toAccount = ref.read(toAccountProvider);
    if (fromAccount != null && toAccount != null) {
      ref.read(bankAccountProvider.notifier).state = toAccount;
      ref.read(toAccountProvider.notifier).state = fromAccount;
    }
  }
}

final transactionsProvider =
    AsyncNotifierProvider<AsyncTransactionsNotifier, List<Transaction>>(() {
  return AsyncTransactionsNotifier();
});
