import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_data_mapper.dart';
import 'package:sossoldi/services/banking/sync/bank_money.dart';
import 'package:sossoldi/services/banking/sync/bank_remote_transaction.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_transaction.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_transactions_page.dart';

Map<String, dynamic> _record({
  String? reference,
  String? id,
  String date = '2026-09-06',
  String amount = '73.14',
  String indicator = 'DBIT',
}) => {
  'entry_reference': reference,
  'transaction_id': id,
  'booking_date': date,
  'transaction_amount': {'amount': amount, 'currency': 'EUR'},
  'credit_debit_indicator': indicator,
  'status': 'BOOK',
  'remittance_information': ['Synthetic purchase'],
};

void main() {
  for (final currency in ['EUR', 'USD', 'GBP', 'CHF']) {
    test(
      '$currency preserves decimal addition without floating point arithmetic',
      () {
        final total =
            BankMoney.parse('0.10', currency) +
            BankMoney.parse('0.20', currency);
        expect(total.minorUnits, BigInt.from(30));
        expect(total.decimal, '0.30');
        expect(
          BankMoney.parse('305.89', currency) -
              BankMoney.parse('73.14', currency),
          isA<BankMoney>().having(
            (value) => value.decimal,
            'balance',
            '232.75',
          ),
        );
      },
    );
  }
  test('zero and three decimal currencies retain their native precision', () {
    expect(BankMoney.parse('123', 'JPY').minorUnits, BigInt.from(123));
    expect(BankMoney.parse('1.234', 'KWD').minorUnits, BigInt.from(1234));
    expect(BankMoney.fromMinor('-1234', 'KWD').decimal, '-1.234');
    expect(() => BankMoney.parse('1.1', 'JPY'), throwsFormatException);
    expect(() => BankMoney.parse('1.2345', 'KWD'), throwsFormatException);
  });
  test(
    'invalid currencies, non-decimals and unsafe projections fail closed',
    () {
      for (final value in ['NaN', 'Infinity', '1e3', '1,00', '', ' 1.00']) {
        expect(() => BankMoney.parse(value, 'EUR'), throwsFormatException);
      }
      expect(() => BankMoney.parse('1', 'XXX'), throwsFormatException);
      expect(() => BankMoney.parse('1', 'eur'), throwsFormatException);
      expect(
        () => BankMoney.parse('1', 'EUR') + BankMoney.parse('1', 'USD'),
        throwsFormatException,
      );
      expect(
        () => BankMoney.parse('999999999999999.01', 'EUR').projection,
        throwsFormatException,
      );
    },
  );
  test(
    'fallback identity ignores transaction ID and surrounding whitespace',
    () {
      final first = BankRemoteTransaction.fromTransaction(
        const EnableBankingDataMapper().transaction(
          EbTransaction.fromJson(_record(reference: ' ', id: 'transient-1')),
        ),
        'EUR',
      );
      final second = BankRemoteTransaction.fromTransaction(
        const EnableBankingDataMapper().transaction(
          EbTransaction.fromJson(_record(id: 'transient-2')),
        ),
        'EUR',
      );
      expect(first.key, second.key);
      expect(first.entryReference, isNull);
      expect(first.money.decimal, '-73.14');
    },
  );
  test('semantic invalidity never invents a date or direction', () {
    for (final json in [
      _record(indicator: 'DBDT'),
      _record(indicator: 'OTHER'),
      _record(amount: '-1'),
      _record()..remove('booking_date'),
    ]) {
      expect(
        () => BankRemoteTransaction.fromTransaction(
          const EnableBankingDataMapper().transaction(
            EbTransaction.fromJson(json),
          ),
          'EUR',
        ),
        throwsFormatException,
      );
    }
    expect(
      () => EbTransaction.fromJson(_record(date: '2026-02-30')),
      throwsFormatException,
    );
    expect(
      () => EbTransaction.fromJson(_record(date: 'yesterday')),
      throwsFormatException,
    );
  });
  test('a malformed page item stays observable alongside valid records', () {
    final page = EbTransactionsPage.fromJson({
      'transactions': [
        _record(reference: 'ok'),
        {'status': 'BOOK'},
        'bad',
      ],
      'continuation_key': '  ',
    }, collectRejectedRecords: true);
    expect(page.transactions, hasLength(1));
    expect(page.rejectedRecords, 2);
    expect(page.continuationKey, isNull);
    expect(() => EbTransactionsPage.fromJson({}), throwsFormatException);
  });
}
