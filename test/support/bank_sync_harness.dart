import 'dart:async';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_provider.dart';
import 'package:sossoldi/services/banking/bank_authorization_context.dart';
import 'package:sossoldi/services/banking/banking_exception.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_api.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_auth.dart';
import 'package:sossoldi/services/banking/enable_banking/enable_banking_credentials_store.dart';
import 'package:sossoldi/services/banking/sync/bank_sync_service.dart';
import 'package:sossoldi/services/database/migration_manager.dart';
import 'package:sossoldi/services/database/repositories/bank_sync_repository.dart';
import 'package:sossoldi/services/database/repositories/account_repository.dart';
import 'package:sossoldi/services/database/sossoldi_database.dart';
import 'package:sqflite/sqflite.dart';

class _SyntheticAuth extends EnableBankingAuth {
  @override
  Future<String> getValidToken(EnableBankingCredentialsStore store) async =>
      'synthetic-test-token';
}

class NativeContractDatabase extends SossoldiDatabase {
  final Database value;
  NativeContractDatabase(this.value);

  @override
  Future<Database> get database async => value;
}

Map<String, dynamic> bankRecord({
  String? reference = 'ref-1',
  String? id = 'temporary-1',
  String amount = '73.14',
  String currency = 'EUR',
  String status = 'BOOK',
  String date = '2026-09-06',
  String indicator = 'DBIT',
  String note = 'Synthetic purchase',
}) => {
  'entry_reference': reference,
  'transaction_id': id,
  'booking_date': date,
  'transaction_amount': {'amount': amount, 'currency': currency},
  'credit_debit_indicator': indicator,
  'status': status,
  'remittance_information': [note],
};

class BankSyncHarness {
  final DatabaseFactory factory;
  late Database db;
  late String path;
  late BankSyncRepository repository;
  late EnableBankingApi api;
  late BankSyncService service;
  DateTime serverTime = DateTime.utc(2026, 9, 7, 12);
  DateTime localTime = DateTime.utc(2026, 9, 7, 12);
  Duration elapsed = Duration.zero;
  String currency = 'EUR';
  String bankCurrency = 'EUR';
  String? applicationId = 'synthetic-app';
  String balance = '232.75';
  String? balanceMarker = 'ref-1';
  String balanceType = 'ITBD';
  DateTime? balanceTime;
  List<String> requiredHeaders = [];
  List<List<Object?>> pages = [
    [bankRecord()],
  ];
  List<http.Request> requests = [];
  List<Duration> sleeps = [];
  Future<http.Response?> Function(http.Request)? intercept;
  bool cycle = false;

  BankSyncHarness(this.factory);

  Future<void> open() async {
    path =
        '${await factory.getDatabasesPath()}/bank_sync_contract_${DateTime.now().microsecondsSinceEpoch}.db';
    final manager = MigrationManager();
    db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: manager.latestVersion,
        onCreate: (db, version) => manager.migrate(db, 0, version),
      ),
    );
    await db.insert('bankConnection', {
      'providerId': 'enable_banking',
      'id': 1,
      'aspspName': 'Synthetic Bank',
      'aspspCountry': 'IT',
      'applicationId': 'synthetic-app',
      'sessionId': 'synthetic-session',
      'status': 'ACTIVE',
      'validUntil': '2027-01-01T00:00:00.000Z',
      'createdAt': serverTime.toIso8601String(),
      'updatedAt': serverTime.toIso8601String(),
    });
    await addAccount(1);
    repository = BankSyncRepository.withDatabase(db);
    api = EnableBankingApi(
      auth: _SyntheticAuth(),
      store: const EnableBankingCredentialsStore(),
      client: MockClient(_respond),
    );
    resetService();
  }

  Future<void> addAccount(int id) => db
      .insert('bankAccount', {
        'id': id,
        'name': 'Synthetic account $id',
        'symbol': 'wallet',
        'color': 1,
        'startingValue': 0,
        'active': 1,
        'countNetWorth': 1,
        'mainAccount': 0,
        'position': id,
        'createdAt': serverTime.toIso8601String(),
        'updatedAt': serverTime.toIso8601String(),
        'ebConnectionId': 1,
        'ebAccountUid': 'synthetic-uid-$id',
        'identificationHash': 'stable-$id',
      })
      .then((_) {});

  void resetService({
    BankSyncLimits limits = const BankSyncLimits(
      manualInterval: Duration.zero,
      backgroundInterval: Duration.zero,
    ),
  }) {
    service = BankSyncService(
      accountData: EnableBankingProvider(api).accountData,
      consent: EnableBankingProvider(api).consent,
      institutions: EnableBankingProvider(api).institutions,
      providerId: 'enable_banking',
      repository: repository,
      readContext: () async {
        if (applicationId == null) {
          throw const BankingException(
            providerId: 'enable_banking',
            failure: BankingFailure.authentication,
          );
        }
        return BankAuthorizationContext(
          providerId: 'enable_banking',
          applicationId: applicationId!,
          redirectUri: 'sossoldi://eb-callback',
        );
      },
      limits: limits,
      clock: () => localTime,
      elapsed: () => elapsed,
      jitter: () => 0,
      sleep: (delay) async {
        sleeps.add(delay);
      },
    );
  }

  http.Response response(
    Object body, {
    int status = 200,
    Map<String, String> headers = const {},
  }) => http.Response(
    jsonEncode(body),
    status,
    headers: {
      'content-type': 'application/json',
      'date': HttpDate.format(serverTime),
      ...headers,
    },
  );

  Future<http.Response> _respond(http.Request request) async {
    requests.add(request);
    final overridden = await intercept?.call(request);
    if (overridden != null) return overridden;
    final path = request.url.path;
    if (path == '/aspsps') {
      return response({
        'aspsps': [
          {
            'name': 'Synthetic Bank',
            'country': 'IT',
            'required_psu_headers': requiredHeaders,
          },
        ],
      });
    }
    if (path == '/sessions/synthetic-session') {
      return response({
        'status': 'AUTHORIZED',
        'aspsp': {'name': 'Synthetic Bank', 'country': 'IT'},
        'psu_type': 'personal',
        'access': {'valid_until': DateTime.utc(2027, 1, 1).toIso8601String()},
        'created': DateTime.utc(2026, 9, 1).toIso8601String(),
        'accounts': ['synthetic-uid-1', 'synthetic-uid-2'],
      });
    }
    if (path.endsWith('/details')) return response({'currency': bankCurrency});
    if (path.endsWith('/transactions')) {
      final index = int.parse(
        request.url.queryParameters['continuation_key'] ?? '0',
      );
      return response({
        'transactions': pages[index % pages.length],
        'continuation_key': cycle
            ? '1'
            : index + 1 < pages.length
            ? '${index + 1}'
            : null,
      });
    }
    if (path.endsWith('/balances')) {
      return response({
        'balances': [
          {
            'name': 'Synthetic booked balance',
            'balance_amount': {'amount': balance, 'currency': bankCurrency},
            'balance_type': balanceType,
            'last_change_date_time':
                (balanceTime ?? serverTime.subtract(const Duration(hours: 1)))
                    .toIso8601String(),
            'last_committed_transaction': balanceMarker,
          },
        ],
      });
    }
    throw StateError('Unexpected synthetic API endpoint');
  }

  Future<List<Map<String, Object?>>> transactions() =>
      db.query('transaction', orderBy: 'id');
  Future<Map<String, Object?>> state() async =>
      (await db.query('bankSyncState', where: 'accountId = 1')).single;
  Future<num> total() async => (await AccountRepository(
    database: NativeContractDatabase(db),
  ).selectAll()).firstWhere((account) => account.id == 1).total!;

  Future<void> close() async {
    await db.close();
    await factory.deleteDatabase(path);
  }
}
