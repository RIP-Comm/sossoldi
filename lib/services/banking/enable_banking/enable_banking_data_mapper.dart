// dart format width=400

import '../banking_balance.dart';
import '../banking_money.dart';
import '../banking_transaction.dart';
import 'models/eb_amount.dart';
import 'models/eb_balance.dart';
import 'models/eb_transaction.dart';
import 'models/eb_transactions_page.dart';

class EnableBankingDataMapper {
  const EnableBankingDataMapper();

  BankingMoney money(EbAmount value) => BankingMoney(decimalAmount: value.exactAmount, currency: value.currency);

  BankingBalance balance(EbBalance value) => BankingBalance(
    name: value.name,
    amount: money(value.balanceAmount),
    kind: switch (value.balanceType) {
      'CLBD' => BankingBalanceKind.closingBooked,
      'ITBD' => BankingBalanceKind.interimBooked,
      'CLAV' || 'ITAV' || 'FWAV' => BankingBalanceKind.available,
      _ => BankingBalanceKind.other,
    },
    referenceDate: value.referenceDate,
    observedAt: value.lastChangeDateTime,
    lastCommittedEntryId: value.lastCommittedTransaction,
  );

  BankingTransaction transaction(EbTransaction value) {
    final amount = money(value.transactionAmount);
    if (amount.decimalAmount.startsWith('-')) throw const FormatException('Negative transaction magnitude');
    return BankingTransaction(
      entryId: value.entryReference,
      transactionId: value.transactionId,
      status: switch (value.status) {
        'BOOK' => BankingTransactionStatus.booked,
        'PDNG' => BankingTransactionStatus.pending,
        _ => BankingTransactionStatus.unknown,
      },
      direction: switch (value.creditDebitIndicator) {
        'CRDT' => BankingDirection.credit,
        'DBIT' => BankingDirection.debit,
        _ => BankingDirection.unknown,
      },
      amount: amount,
      bookingDate: value.bookingDate,
      valueDate: value.valueDate,
      transactionDate: value.transactionDate,
      creditorName: value.creditorName,
      debtorName: value.debtorName,
      note: value.note,
      remittanceInformation: value.remittanceInformation,
    );
  }

  BankingTransactionsPage transactions(EbTransactionsPage value) => BankingTransactionsPage(transactions: value.transactions.map(transaction).toList(), nextCursor: value.continuationKey?.trim().isEmpty == true ? null : value.continuationKey);
}
