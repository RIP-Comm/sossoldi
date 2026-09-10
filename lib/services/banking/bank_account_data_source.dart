// dart format width=400

import 'banking_account.dart';
import 'banking_balance.dart';
import 'banking_reference.dart';
import 'banking_transaction.dart';

abstract interface class BankAccountDataSource {
  Future<BankingAccount> getAccount(BankingAccountReference reference);
  Future<List<BankingBalance>> getBalances(BankingAccountReference reference);
  Future<BankingTransactionsPage> getTransactions(BankingAccountReference reference, {BankingTransactionQuery query = const BankingTransactionQuery()});
}
