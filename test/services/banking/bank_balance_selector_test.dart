import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_data_mapper.dart';
import 'package:sossoldi/services/banking/banking_balance.dart';
import 'package:sossoldi/services/banking/sync/bank_balance_selector.dart';
import 'package:sossoldi/services/banking/sync/bank_remote_transaction.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_amount.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_balance.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_transaction.dart';

import '../../support/bank_sync_harness.dart';

void main() {
  final serverTime = DateTime.utc(2026, 9, 7, 12);
  final transactions = [
    BankRemoteTransaction.fromTransaction(
      const EnableBankingDataMapper().transaction(
        EbTransaction.fromJson(bankRecord()),
      ),
      'EUR',
    ),
  ];

  BankingBalance balance({
    String type = 'ITBD',
    String amount = '232.75',
    String currency = 'EUR',
    DateTime? at,
    String marker = 'ref-1',
  }) => const EnableBankingDataMapper().balance(
    EbBalance(
      name: 'Synthetic',
      balanceType: type,
      balanceAmount: EbAmount(
        amount: num.parse(amount),
        currency: currency,
        decimalAmount: amount,
      ),
      lastChangeDateTime: at ?? serverTime.subtract(const Duration(hours: 1)),
      lastCommittedTransaction: marker,
    ),
  );

  test('newer booked snapshot wins over an older closing balance', () {
    final selected = selectBankBalance(
      [
        balance(
          type: 'CLBD',
          amount: '305.89',
          at: DateTime.utc(2026, 9, 6, 23),
        ),
        balance(),
      ],
      transactions,
      'EUR',
      serverTime,
    );
    expect(selected?.money.decimal, '232.75');
  });
  test('same-time conflicting amounts are ambiguous', () {
    expect(
      selectBankBalance(
        [balance(), balance(amount: '300.00')],
        transactions,
        'EUR',
        serverTime,
      ),
      isNull,
    );
  });
  test(
    'currency mismatch, future timestamp and absent anchor cannot reconcile',
    () {
      expect(
        selectBankBalance(
          [balance(currency: 'USD')],
          transactions,
          'EUR',
          serverTime,
        ),
        isNull,
      );
      expect(
        selectBankBalance(
          [balance(at: serverTime.add(const Duration(seconds: 1)))],
          transactions,
          'EUR',
          serverTime,
        ),
        isNull,
      );
      expect(
        selectBankBalance(
          [balance(marker: 'unknown')],
          transactions,
          'EUR',
          serverTime,
        ),
        isNull,
      );
    },
  );
  test(
    'balance date parsing refuses malformed calendar dates and local timestamps',
    () {
      final base = <String, dynamic>{
        'name': 'Synthetic',
        'balance_amount': {'amount': '1.00', 'currency': 'EUR'},
        'balance_type': 'CLBD',
      };
      expect(
        () => EbBalance.fromJson({...base, 'reference_date': '2026-02-30'}),
        throwsFormatException,
      );
      expect(
        () => EbBalance.fromJson({
          ...base,
          'last_change_date_time': '2026-09-07T12:00:00',
        }),
        throwsFormatException,
      );
      expect(
        () => EbBalance.fromJson({
          ...base,
          'last_change_date_time': '2026-02-30T12:00:00Z',
        }),
        throwsFormatException,
      );
      expect(
        EbBalance.fromJson({
          ...base,
          'reference_date': '2026-09-07',
        }).referenceDate,
        DateTime.utc(2026, 9, 7),
      );
    },
  );
}
