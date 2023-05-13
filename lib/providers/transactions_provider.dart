import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'categories_provider.dart';
import 'accounts_provider.dart';
import '../model/bank_account.dart';
import '../model/transaction.dart';
import '../model/category_transaction.dart';

final transactionTypeList =
    Provider<List<Type>>((ref) => [Type.income, Type.expense, Type.transfer]);

final transactionTypesProvider = StateProvider<List<bool>>((ref) => [false, true, false]);
final bankAccountTransferProvider = StateProvider<BankAccount?>((ref) => null);
// Used as from account in transfer transactions
final bankAccountProvider = StateProvider<BankAccount?>((ref) => ref.read(mainAccountProvider));
final dateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final categoryProvider = StateProvider<CategoryTransaction?>((ref) => null);
final amountProvider = StateProvider<num>((ref) => 0);
final noteProvider = StateProvider<String?>((ref) => null);

//Recurring Payment
final selectedRecurringPayProvider = StateProvider<bool>((ref) => false);
final intervalProvider = StateProvider<Recurrence>((ref) => Recurrence.monthly);
final repetitionProvider = StateProvider<dynamic>((ref) => null);

// Set when a transaction is selected for update
final selectedTransactionUpdateProvider = StateProvider<Transaction?>((ref) => null);

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
    state = const AsyncValue.loading();

    final typeIndex = ref.read(transactionTypesProvider).indexOf(true);
    final date = ref.read(dateProvider);
    final amount = ref.read(amountProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    final bankAccountTransfer = ref.read(bankAccountTransferProvider);
    final category = ref.read(categoryProvider);
    final note = ref.read(noteProvider);
    final recurring = ref.read(selectedRecurringPayProvider);

    Transaction transaction = Transaction(
      date: date,
      amount: amount,
      type: ref.watch(transactionTypeList)[typeIndex],
      note: note,
      idBankAccount: bankAccount.id!,
      idBankAccountTransfer: bankAccountTransfer?.id,
      idCategory: category?.id,
      recurring: recurring,
    );

    state = await AsyncValue.guard(() async {
      await TransactionMethods().insert(transaction);
      return _getTransactions();
    });
  }

  Future<void> updateTransaction() async {
    final typeIndex = ref.read(transactionTypesProvider).indexOf(true);
    final date = ref.read(dateProvider);
    final amount = ref.read(amountProvider);
    final bankAccount = ref.read(bankAccountProvider)!;
    final bankAccountTransfer = ref.read(bankAccountTransferProvider);
    final category = ref.read(categoryProvider);
    final note = ref.read(noteProvider);
    final recurring = ref.read(selectedRecurringPayProvider);

    Transaction transaction = ref.read(selectedTransactionUpdateProvider)!.copy(
          date: date,
          amount: amount,
          type: ref.watch(transactionTypeList)[typeIndex],
          note: note,
          idBankAccount: bankAccount.id!,
          idBankAccountTransfer: bankAccountTransfer?.id,
          idCategory: category?.id,
          recurring: recurring,
        );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await TransactionMethods().updateItem(transaction);
      return _getTransactions();
    });
  }

  Future<void> transactionUpdateState() async {
    if (ref.read(selectedTransactionUpdateProvider) == null) return;
    Transaction transaction = ref.read(selectedTransactionUpdateProvider)!;
    final accountList = ref.watch(accountsProvider);
    if (transaction.type != Type.transfer) {
      final categories = ref
          .watch(categoriesProvider)
          .value!
          .where((element) => element.id == transaction.idCategory);
      if (categories.isNotEmpty) {
        ref.read(categoryProvider.notifier).state = categories.first;
      }
    }
    ref.read(bankAccountProvider.notifier).state =
        accountList.value!.firstWhere((element) => element.id == transaction.idBankAccount);
    ref.read(bankAccountTransferProvider.notifier).state = transaction.type == Type.transfer
        ? accountList.value!
            .firstWhere((element) => element.id == transaction.idBankAccountTransfer)
        : null;
    ref.read(transactionTypesProvider.notifier).state = [
      transaction.type == Type.income,
      transaction.type == Type.expense,
      transaction.type == Type.transfer,
    ];
    ref.read(dateProvider.notifier).state = transaction.date;
    ref.read(amountProvider.notifier).state = transaction.amount;
    ref.read(noteProvider.notifier).state = transaction.note;
    ref.read(selectedRecurringPayProvider.notifier).state = transaction.recurring;
  }

  Future<void> deleteTransaction(int transactionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await TransactionMethods().deleteById(transactionId);
      return _getTransactions();
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
}

final transactionsProvider =
    AsyncNotifierProvider<AsyncTransactionsNotifier, List<Transaction>>(() {
  return AsyncTransactionsNotifier();
});
