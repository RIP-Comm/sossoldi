import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import 'enable_banking_auth.dart';
import 'enable_banking_config.dart';
import 'enable_banking_credentials_store.dart';
import 'enable_banking_exception.dart';
import 'models/aspsp.dart';
import 'models/eb_account.dart';
import 'models/eb_application.dart';
import 'models/eb_auth.dart';
import 'models/eb_balance.dart';
import 'models/eb_session.dart';
import 'models/eb_session_details.dart';
import 'models/eb_transactions_page.dart';

const _kBaseUrl = 'https://api.enablebanking.com';

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
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
  final Duration _timeout;

  EnableBankingApi({
    required EnableBankingAuth auth,
    required EnableBankingCredentialsStore store,
    http.Client? client,
    Duration timeout = const Duration(seconds: 30),
  }) : _auth = auth,
       _store = store,
       _client = client ?? http.Client(),
       _timeout = timeout;

  Map<String, String> _headersForToken(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _headers() async =>
      _headersForToken(await _auth.getValidToken(_store));

  void _check(http.Response response) {
    if (response.statusCode < 400) return;

    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }
    final rawError = body?['error'];
    final code = switch (rawError) {
      String value => value,
      Map<String, dynamic> value =>
        _string(value['code']) ?? _string(value['error']),
      _ => _string(body?['code']) ?? _string(body?['error_code']),
    };
    final rawMessage =
        body?['message'] ??
        (rawError is Map<String, dynamic> ? rawError['message'] : null) ??
        body?['error_description'];
    throw EnableBankingException(
      statusCode: response.statusCode,
      error: code,
      message: rawMessage is String ? rawMessage : null,
      kind: _failureKind(response.statusCode, code),
    );
  }

  String? _string(Object? value) => value is String ? value : null;

  EnableBankingFailureKind _failureKind(int statusCode, String? code) {
    switch (code?.toUpperCase()) {
      case 'EXPIRED_SESSION':
        return EnableBankingFailureKind.sessionExpired;
      case 'REVOKED_SESSION':
        return EnableBankingFailureKind.sessionRevoked;
      case 'CLOSED_SESSION':
        return EnableBankingFailureKind.sessionClosed;
    }
    return switch (statusCode) {
      400 => EnableBankingFailureKind.invalidRequest,
      401 || 403 => EnableBankingFailureKind.applicationAuthentication,
      404 => EnableBankingFailureKind.notFound,
      429 => EnableBankingFailureKind.rateLimited,
      >= 500 => EnableBankingFailureKind.server,
      _ => EnableBankingFailureKind.unknown,
    };
  }

  Future<http.Response> _request(Future<http.Response> request) async {
    try {
      return await request.timeout(_timeout);
    } on TimeoutException {
      throw const EnableBankingException(
        message: 'Enable Banking request timed out',
        kind: EnableBankingFailureKind.timeout,
      );
    } on http.ClientException catch (error) {
      throw EnableBankingException(
        message: error.message,
        kind: EnableBankingFailureKind.network,
      );
    }
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error) {
      throw EnableBankingException(
        statusCode: response.statusCode,
        message: 'Malformed Enable Banking response: $error',
        kind: EnableBankingFailureKind.invalidResponse,
      );
    }
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? query,
  ]) async {
    final uri = Uri.parse('$_kBaseUrl$path').replace(
      queryParameters: query != null && query.isNotEmpty ? query : null,
    );
    final response = await _request(
      _client.get(uri, headers: await _headers()),
    );
    _check(response);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> _getWithToken(String path, String token) async {
    final uri = Uri.parse('$_kBaseUrl$path');
    final response = await _request(
      _client.get(uri, headers: _headersForToken(token)),
    );
    _check(response);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_kBaseUrl$path');
    final response = await _request(
      _client.post(uri, headers: await _headers(), body: jsonEncode(body)),
    );
    _check(response);
    return _decodeObject(response);
  }

  Future<void> _delete(String path) async {
    final uri = Uri.parse('$_kBaseUrl$path');
    final response = await _request(
      _client.delete(uri, headers: await _headers()),
    );
    _check(response);
  }

  Future<List<Aspsp>> getAspsps({
    String? country,
    String psuType = 'personal',
  }) async {
    final json = await _get('/aspsps', {
      'country': ?country,
      'psu_type': psuType,
    });
    return (json['aspsps'] as List)
        .map((e) => Aspsp.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EbApplication> getApplication() async {
    final json = await _get('/application');
    return EbApplication.fromJson(json);
  }

  /// Verifies a candidate app-id/key pair before it is persisted.
  Future<EbApplication> verifyApplicationCredentials({
    required String appId,
    required String privateKeyPem,
  }) async {
    final token = _auth.buildJwt(appId: appId, privateKeyPem: privateKeyPem);
    final json = await _getWithToken('/application', token);
    final application = EbApplication.fromJson(json);
    if (application.kid != appId) {
      throw const EnableBankingException(
        message: 'The application returned a different key ID',
      );
    }
    _auth.clearCache();
    return application;
  }

  Future<EbAuthorization> startAuthorization({
    required String aspspName,
    required String aspspCountry,
    required String state,
    required DateTime validUntil,
    String psuType = 'personal',
    String? language,
    String redirectUri = kEbRedirectUri,
  }) async {
    validateEnableBankingRedirect(redirectUri);
    final json = await _post('/auth', {
      'access': {
        'valid_until': validUntil.toUtc().toIso8601String(),
        'balances': true,
        'transactions': true,
      },
      'aspsp': {'name': aspspName, 'country': aspspCountry},
      'state': state,
      'redirect_url': redirectUri,
      'psu_type': psuType,
      'language': ?language,
    });
    return EbAuthorization.fromJson(json);
  }

  Future<EbSession> createSession(String code) async {
    final json = await _post('/sessions', {'code': code});
    return EbSession.fromJson(json);
  }

  Future<EbSessionDetails> getSession(String sessionId) async {
    final json = await _get('/sessions/${Uri.encodeComponent(sessionId)}');
    return EbSessionDetails.fromJson(json);
  }

  Future<void> deleteSession(String sessionId) async {
    await _delete('/sessions/${Uri.encodeComponent(sessionId)}');
  }

  Future<EbAccount> getAccount(String accountUid) async {
    final json = await _get(
      '/accounts/${Uri.encodeComponent(accountUid)}/details',
    );
    return EbAccount.fromJson(json);
  }

  Future<List<EbBalance>> getBalances(String accountUid) async {
    final json = await _get(
      '/accounts/${Uri.encodeComponent(accountUid)}/balances',
    );
    return (json['balances'] as List)
        .map((e) => EbBalance.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Treats [dateFrom] and [dateTo] as calendar dates, preserving their year, month and day without timezone conversion.
  Future<EbTransactionsPage> getTransactions(
    String accountUid, {
    DateTime? dateFrom,
    DateTime? dateTo,
    String? continuationKey,
    String? transactionStatus,
  }) async {
    final json = await _get(
      '/accounts/${Uri.encodeComponent(accountUid)}/transactions',
      {
        if (dateFrom != null) 'date_from': _formatDate(dateFrom),
        if (dateTo != null) 'date_to': _formatDate(dateTo),
        'continuation_key': ?continuationKey,
        'transaction_status': ?transactionStatus,
      },
    );
    return EbTransactionsPage.fromJson(json);
  }
}
