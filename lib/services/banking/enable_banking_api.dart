import 'dart:convert';

import 'package:http/http.dart' as http;

import 'enable_banking_auth.dart';
import 'enable_banking_config.dart';
import 'enable_banking_credentials_store.dart';
import 'enable_banking_exception.dart';
import 'models/aspsp.dart';
import 'models/eb_auth.dart';
import 'models/eb_balance.dart';
import 'models/eb_session.dart';
import 'models/eb_transactions_page.dart';

const _kBaseUrl = 'https://api.enablebanking.com';

String _formatDate(DateTime date) {
  final utc = date.toUtc();
  final year = utc.year.toString().padLeft(4, '0');
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Thin REST client for the Enable Banking API.
///
/// Every request is authenticated with a fresh RS256 JWT (via [_auth]) and
/// mapped onto the DTOs in `models/`; HTTP errors (status >= 400) become
/// [EnableBankingException].
class EnableBankingApi {
  final EnableBankingAuth _auth;
  final EnableBankingCredentialsStore _store;
  final http.Client _client;

  EnableBankingApi({
    required EnableBankingAuth auth,
    required EnableBankingCredentialsStore store,
    http.Client? client,
  }) : _auth = auth,
       _store = store,
       _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async => {
    'Authorization': 'Bearer ${await _auth.getValidToken(_store)}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void _check(http.Response response) {
    if (response.statusCode < 400) return;

    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }
    throw EnableBankingException(
      statusCode: response.statusCode,
      error: body?['error'] as String?,
      message: body?['message'] as String?,
    );
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    final uri = Uri.parse('$_kBaseUrl$path').replace(
      queryParameters: query != null && query.isNotEmpty ? query : null,
    );
    final response = await _client.get(uri, headers: await _headers());
    _check(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_kBaseUrl$path');
    final response = await _client.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );
    _check(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> _delete(String path) async {
    final uri = Uri.parse('$_kBaseUrl$path');
    final response = await _client.delete(uri, headers: await _headers());
    _check(response);
  }

  Future<List<Aspsp>> getAspsps({
    required String country,
    String psuType = 'personal',
  }) async {
    final json = await _get('/aspsps', {
      'country': country,
      'psu_type': psuType,
    });
    return ((json['aspsps'] as List?) ?? const [])
        .map((e) => Aspsp.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EbAuthorization> startAuthorization({
    required String aspspName,
    required String aspspCountry,
    required String state,
    required DateTime validUntil,
    String psuType = 'personal',
    String? language,
  }) async {
    final json = await _post('/auth', {
      'access': {
        'valid_until': validUntil.toUtc().toIso8601String(),
        'balances': true,
        'transactions': true,
      },
      'aspsp': {'name': aspspName, 'country': aspspCountry},
      'state': state,
      'redirect_url': kEbRedirectUri,
      'psu_type': psuType,
      'language': ?language,
    });
    return EbAuthorization.fromJson(json);
  }

  Future<EbSession> createSession(String code) async {
    final json = await _post('/sessions', {'code': code});
    return EbSession.fromJson(json);
  }

  Future<EbSession> getSession(String sessionId) async {
    final json = await _get('/sessions/$sessionId');
    return EbSession.fromJson(json);
  }

  Future<void> deleteSession(String sessionId) async {
    await _delete('/sessions/$sessionId');
  }

  Future<List<EbBalance>> getBalances(String accountUid) async {
    final json = await _get('/accounts/$accountUid/balances');
    return ((json['balances'] as List?) ?? const [])
        .map((e) => EbBalance.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EbTransactionsPage> getTransactions(
    String accountUid, {
    DateTime? dateFrom,
    DateTime? dateTo,
    String? continuationKey,
    String? transactionStatus,
  }) async {
    final json = await _get('/accounts/$accountUid/transactions', {
      if (dateFrom != null) 'date_from': _formatDate(dateFrom),
      if (dateTo != null) 'date_to': _formatDate(dateTo),
      'continuation_key': ?continuationKey,
      'transaction_status': ?transactionStatus,
    });
    return EbTransactionsPage.fromJson(json);
  }
}
