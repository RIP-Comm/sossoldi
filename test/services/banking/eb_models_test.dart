import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:sossoldi/services/banking/enable_banking/models/aspsp.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_application.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_account.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_balance.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_session.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_session_details.dart';
import 'package:sossoldi/services/banking/enable_banking/models/eb_transactions_page.dart';

Map<String, dynamic> _loadJson(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('EbApplication.fromJson', () {
    test('parses server-derived environment and available countries', () {
      final application = EbApplication.fromJson(
        _loadJson('eb_application.json'),
      );

      expect(application.kid, 'app-123');
      expect(application.environment.name, 'production');
      expect(application.active, isTrue);
      expect(application.countries, ['GB', 'IT']);
      expect(application.redirectUrls, ['sossoldi://eb-callback']);
      expect(application.services, ['AIS']);
    });

    test('rejects an unknown server environment', () {
      expect(
        () => EbApplication.fromJson({
          'name': 'Broken',
          'kid': 'app-1',
          'environment': 'STAGING',
          'active': true,
        }),
        throwsFormatException,
      );
    });
  });

  group('Aspsp.fromJson', () {
    test('parses fields including psu_types and nested sandbox', () {
      final aspsp = Aspsp.fromJson(_loadJson('eb_aspsp.json'));

      expect(aspsp.name, 'Mock ASPSP');
      expect(aspsp.country, 'IT');
      expect(aspsp.logo, 'https://example.com/logo.png');
      expect(aspsp.psuTypes, ['personal', 'business']);
      expect(aspsp.maximumConsentValidity, 7776000);
      expect(aspsp.beta, false);
      expect(aspsp.sandbox, isNotNull);
      expect(aspsp.sandbox!.users, isNotEmpty);
    });

    test('null sandbox and missing psu_types are handled', () {
      final aspsp = Aspsp.fromJson({'name': 'X', 'country': 'FR'});

      expect(aspsp.sandbox, isNull);
      expect(aspsp.psuTypes, isEmpty);
      expect(aspsp.beta, false);
      expect(aspsp.maximumConsentValidity, isNull);
    });
  });

  group('EbAccount.fromJson', () {
    test('reads nested account_id.iban', () {
      final account = EbAccount.fromJson(_loadJson('eb_account.json'));

      expect(account.uid, 'acc-uid-123');
      expect(account.iban, 'IT60X0542811101000000123456');
      expect(account.name, 'Main Account');
      expect(account.currency, 'EUR');
      expect(account.cashAccountType, 'CACC');
      expect(account.usage, 'PRIV');
      expect(account.identificationHash, 'idhash-abc');
    });

    test('missing account_id yields null iban', () {
      final account = EbAccount.fromJson({'uid': 'only-uid'});

      expect(account.uid, 'only-uid');
      expect(account.iban, isNull);
    });
  });

  group('EbBalance.fromJson', () {
    test('parses string amount into num', () {
      final balance = EbBalance.fromJson(_loadJson('eb_balance.json'));

      expect(balance.name, 'Closing booked');
      expect(balance.balanceAmount.amount, 1234.56);
      expect(balance.balanceAmount.currency, 'EUR');
      expect(balance.balanceType, 'CLBD');
    });
  });

  group('EbTransactionsPage.fromJson', () {
    late EbTransactionsPage page;

    setUp(() {
      page = EbTransactionsPage.fromJson(_loadJson('eb_transactions.json'));
    });

    test('parses envelope with continuation_key', () {
      expect(page.continuationKey, 'next-page-123');
      expect(page.transactions.length, 2);
    });

    test('credit transaction: positive signedAmount, stableId, isBooked', () {
      final credit = page.transactions[0];

      expect(credit.transactionAmount.amount, 10.33);
      expect(credit.signedAmount, 10.33);
      expect(credit.creditDebitIndicator, 'CRDT');
      expect(credit.stableId, 'ref-001');
      expect(credit.isBooked, isTrue);
      expect(credit.creditorName, 'Alice');
      expect(credit.debtorName, 'Bob');
      expect(credit.remittanceInformation, ['Salary', 'January']);
      expect(credit.bookingDate, DateTime.parse('2025-01-15'));
    });

    test('debit transaction: negative signedAmount, fallback stableId', () {
      final debit = page.transactions[1];

      expect(debit.signedAmount, -25.00);
      expect(debit.creditDebitIndicator, 'DBIT');
      // entry_reference is null → stableId falls back to transaction_id.
      expect(debit.stableId, 'tx-002');
      expect(debit.isBooked, isFalse);
      expect(debit.bookingDate, isNull);
      expect(debit.note, 'supermarket');
    });
  });

  group('EbSession.fromJson', () {
    test('reads nested aspsp and access.valid_until', () {
      final session = EbSession.fromJson(_loadJson('eb_session.json'));

      expect(session.sessionId, 'sess-789');
      expect(session.aspspName, 'Mock ASPSP');
      expect(session.aspspCountry, 'IT');
      expect(session.psuType, 'personal');
      expect(session.validUntil, DateTime.parse('2025-04-15T10:00:00.000Z'));
      expect(session.accounts.length, 1);
      expect(session.accounts.first.iban, 'IT60X0542811101000000123456');
    });
  });

  group('EbSessionDetails.fromJson', () {
    test('parses the GET session response without a session_id', () {
      final session = EbSessionDetails.fromJson(
        _loadJson('eb_get_session.json'),
      );

      expect(session.status, EbSessionStatus.authorized);
      expect(session.accountUids, ['497f6eca-6276-4993-bfeb-53cbbbba6f08']);
      expect(session.accountsData.single.identificationHash, 'primary-hash');
      expect(session.accountsData.single.identificationHashes, [
        'primary-hash',
        'alternate-hash',
      ]);
      expect(session.aspspName, 'Nordea');
      expect(session.aspspCountry, 'FI');
      expect(session.psuType, 'business');
      expect(session.psuIdHash, 'psu-hash');
      expect(session.created, DateTime.parse('2026-08-01T11:55:00.000Z'));
      expect(session.closed, isNull);
    });

    test('rejects an unknown session status', () {
      final json = _loadJson('eb_get_session.json');
      json['status'] = 'UNKNOWN';

      expect(() => EbSessionDetails.fromJson(json), throwsFormatException);
    });

    test('account data tolerates a missing stable hash', () {
      final account = EbSessionAccount.fromJson({'uid': 'session-only-uid'});

      expect(account.uid, 'session-only-uid');
      expect(account.identificationHash, isNull);
      expect(account.identificationHashes, isEmpty);
    });
  });
}
