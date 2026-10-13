// dart format width=400

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../banking_exception.dart';
import 'enable_banking_auth.dart';
import 'enable_banking_exception.dart';

const enableBankingId = 'enable_banking';

Future<T> withEnableBankingErrors<T>(Future<T> Function() operation) async {
  const id = enableBankingId;
  try {
    return await operation();
  } on EnableBankingException catch (error) {
    final failure = switch (error.kind) {
      EnableBankingFailureKind.sessionExpired => BankingFailure.connectionExpired,
      EnableBankingFailureKind.sessionRevoked => BankingFailure.connectionRevoked,
      EnableBankingFailureKind.sessionClosed => BankingFailure.connectionClosed,
      EnableBankingFailureKind.notFound => BankingFailure.notFound,
      EnableBankingFailureKind.applicationAuthentication => error.statusCode == 403 ? BankingFailure.forbidden : BankingFailure.authentication,
      EnableBankingFailureKind.rateLimited => BankingFailure.rateLimited,
      EnableBankingFailureKind.timeout || EnableBankingFailureKind.server || EnableBankingFailureKind.network => BankingFailure.unavailable,
      EnableBankingFailureKind.invalidResponse => BankingFailure.invalidResponse,
      _ => switch (error.statusCode) {
        401 => BankingFailure.authentication,
        403 => BankingFailure.forbidden,
        429 => BankingFailure.rateLimited,
        int code when code >= 500 => BankingFailure.unavailable,
        _ => BankingFailure.rejected,
      },
    };
    throw BankingException(providerId: id, failure: failure);
  } on EnableBankingAuthException {
    throw const BankingException(providerId: id, failure: BankingFailure.authentication);
  } on TimeoutException {
    throw const BankingException(providerId: id, failure: BankingFailure.unavailable);
  } on http.ClientException {
    throw const BankingException(providerId: id, failure: BankingFailure.unavailable);
  } on SocketException {
    throw const BankingException(providerId: id, failure: BankingFailure.unavailable);
  } on FormatException {
    throw const BankingException(providerId: id, failure: BankingFailure.invalidResponse);
  } on TypeError {
    throw const BankingException(providerId: id, failure: BankingFailure.invalidResponse);
  }
}
