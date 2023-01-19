import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'accounts_provider.dart';
import '../model/bank_account.dart';
import '../model/transaction.dart';
import '../model/category_transaction.dart';

final transactionTypeList = Provider<List<Type>>((ref) => [Type.income, Type.expense, Type.transfer]);

final transactionTypesProvider =
    StateProvider.autoDispose<List<bool>>((ref) => [false, true, false]);
final dateProvider = StateProvider.autoDispose<DateTime>((ref) => DateTime.now());
final bankAccountProvider =
    StateProvider.autoDispose<BankAccount?>((ref) => ref.read(mainAccountProvider));
final amountProvider = StateProvider.autoDispose<num>((ref) => 0);
final noteProvider = StateProvider.autoDispose<String?>((ref) => null);
final categoryProvider = StateProvider.autoDispose<CategoryTransaction?>((ref) => null);
final selectedRecurringPayProvider = StateProvider.autoDispose<bool>((ref) => false);

class AsyncTransactionsNotifier extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    return _getTransactions();
  }

  Future<List<Transaction>> _getTransactions() async {
    final transaction = await TransactionMethods().selectAll();
    return transaction;
  }

  Future<void> addTransaction() async {
    final date = ref.read(dateProvider);
    final amount = ref.read(amountProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    final typeIndex = ref.read(transactionTypesProvider).indexOf(true);
    final category = ref.read(categoryProvider)!;
    final note = ref.read(noteProvider);
    state = const AsyncValue.loading();

    Transaction transaction = Transaction(
      date: date,
      amount: amount,
      type: ref.read(transactionTypeList)[typeIndex],
      note: note,
      idBankAccount: bankAccount.id!,
      idBudget: 0,
      idCategory: category.id!,
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
}

final transactionsProvider =
    AsyncNotifierProvider<AsyncTransactionsNotifier, List<Transaction>>(() {
  return AsyncTransactionsNotifier();
});
