import 'banking_account.dart';
import 'banking_request_context.dart';
import 'banking_balance.dart';
import 'banking_reference.dart';
import 'banking_transaction.dart';

abstract interface class BankAccountDataSource {
  Future<BankingAccount> getAccount(
    BankingAccountReference reference, {
    BankingRequestContext context = const BankingRequestContext(),
  });
  Future<List<BankingBalance>> getBalances(
    BankingAccountReference reference, {
    BankingRequestContext context = const BankingRequestContext(),
  });
  Future<BankingTransactionsPage> getTransactions(
    BankingAccountReference reference, {
    BankingTransactionQuery query = const BankingTransactionQuery(),
  });
}
