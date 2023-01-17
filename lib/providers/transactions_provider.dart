import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accounts_provider.dart';
import '../model/bank_account.dart';
import '../model/transaction.dart';
import '../model/category_transaction.dart';

final transactionTypesProvider =
    StateProvider.autoDispose<List<bool>>((ref) => [false, true, false]);
final dateProvider = StateProvider.autoDispose<DateTime>((ref) => DateTime.now());
final bankAccountProvider =
    StateProvider.autoDispose<BankAccount?>((ref) => ref.read(mainAccountProvider));
final amountProvider = StateProvider<num>((ref) => 0);
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

  Future<void> addTransaction(num amount) async {
    final date = ref.read(dateProvider);
    // final amount = ref.read(amountProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    List<Type> typeList = [Type.income, Type.expense, Type.transfer];
    final typeIndex = ref.read(transactionTypesProvider).indexOf(true);
    final category = ref.read(categoryProvider);
    final note = ref.read(noteProvider);
    state = const AsyncValue.loading();

    Transaction transaction = Transaction(
      date: date,
      amount: amount,
      type: typeList[typeIndex],
      note: note,
      idBankAccount: bankAccount.id!,
      idBudget: 0,
      idCategory: 0,
    );

    // Dispose dell'amount provider manuale, nell'attesa di capire perchè se metto autodispose ogni volta che aggiorna il valore fa il dispose da solo in contemporanea
    ref.invalidate(amountProvider);

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
