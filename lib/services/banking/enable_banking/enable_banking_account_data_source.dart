// dart format width=400

import '../bank_account_data_source.dart';
import '../banking_account.dart';
import '../banking_balance.dart';
import '../banking_exception.dart';
import '../banking_reference.dart';
import '../banking_transaction.dart';
import 'enable_banking_account_mapper.dart';
import 'enable_banking_api.dart';
import 'enable_banking_data_mapper.dart';
import 'enable_banking_errors.dart';
import 'enable_banking_reference.dart';

class EnableBankingAccountDataSource implements BankAccountDataSource {
  final EnableBankingApi _api;
  final _accounts = const EnableBankingAccountMapper();
  final _data = const EnableBankingDataMapper();

  EnableBankingAccountDataSource(this._api);

  @override
  Future<BankingAccount> getAccount(BankingAccountReference reference) => withEnableBankingErrors(() async {
    checkEnableBankingReference(reference.providerId, reference.remoteId);
    final account = await _api.getAccount(reference.remoteId);
    if (account.uid != reference.remoteId) throw const FormatException('Account identity mismatch');
    return _accounts.account(account);
  });

  @override
  Future<List<BankingBalance>> getBalances(BankingAccountReference reference) => withEnableBankingErrors(() async {
    checkEnableBankingReference(reference.providerId, reference.remoteId);
    return List.unmodifiable((await _api.getBalances(reference.remoteId)).map(_data.balance));
  });

  @override
  Future<BankingTransactionsPage> getTransactions(BankingAccountReference reference, {BankingTransactionQuery query = const BankingTransactionQuery()}) => withEnableBankingErrors(() async {
    checkEnableBankingReference(reference.providerId, reference.remoteId);
    if (query.status == BankingTransactionStatus.unknown) throw const BankingException(providerId: enableBankingId, failure: BankingFailure.rejected);
    final from = query.dateFrom;
    final to = query.dateTo;
    if (from != null && to != null && DateTime.utc(from.year, from.month, from.day).isAfter(DateTime.utc(to.year, to.month, to.day))) throw const BankingException(providerId: enableBankingId, failure: BankingFailure.rejected);
    final status = switch (query.status) {
      BankingTransactionStatus.booked => 'BOOK',
      BankingTransactionStatus.pending => 'PDNG',
      _ => null,
    };
    return _data.transactions(await _api.getTransactions(reference.remoteId, dateFrom: from, dateTo: to, continuationKey: query.cursor, transactionStatus: status));
  });
}
