import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../model/transaction.dart';
import '../database/repositories/transactions_repository.dart';

class PendingWalletTransactionImporter {
  static const _fileName = 'pending_wallet_transactions.jsonl';

  static Future<int> importPending(WidgetRef ref) async {
    final file = await _pendingFile();
    if (!await file.exists()) return 0;

    final lines = await file.readAsLines();
    final remainingLines = <String>[];
    var importedCount = 0;

    for (final line in lines.where((line) => line.trim().isNotEmpty)) {
      try {
        final pendingTransaction = _PendingWalletTransaction.fromJson(
          jsonDecode(line) as Map<String, Object?>,
        );
        await ref
            .read(transactionsRepositoryProvider)
            .insert(pendingTransaction.toTransaction());
        importedCount++;
      } catch (_) {
        remainingLines.add(line);
      }
    }

    if (remainingLines.isEmpty) {
      await file.delete();
    } else {
      await file.writeAsString('${remainingLines.join('\n')}\n');
    }

    return importedCount;
  }

  static Future<File> _pendingFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(path.join(directory.path, _fileName));
  }
}

class _PendingWalletTransaction {
  _PendingWalletTransaction({
    required this.amount,
    required this.merchant,
    required this.card,
    required this.createdAt,
  });

  final String amount;
  final String merchant;
  final String card;
  final DateTime createdAt;

  static _PendingWalletTransaction fromJson(Map<String, Object?> json) {
    return _PendingWalletTransaction(
      amount: json['amount'] as String,
      merchant: json['merchant'] as String? ?? '',
      card: json['card'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Transaction toTransaction() {
    final parsedAmount = _parseAmount(amount);
    return Transaction(
      date: createdAt,
      amount: parsedAmount.abs(),
      type: parsedAmount < 0 ? TransactionType.income : TransactionType.expense,
      note: merchant.isEmpty ? 'Apple Pay transaction' : merchant,
      idBankAccount: 0,
      idCategory: null,
      recurring: false,
    );
  }

  static num _parseAmount(String value) {
    final trimmed = value.trim();
    final locale = PlatformDispatcher.instance.locale.toString();
    final formatters = [
      NumberFormat.currency(locale: locale),
      NumberFormat.decimalPattern(locale),
    ];

    for (final formatter in formatters) {
      try {
        return formatter.parse(trimmed);
      } catch (_) {
        // Try the next formatter, then the normalized fallback.
      }
    }

    return num.parse(_normalizedDecimalString(trimmed));
  }

  static String _normalizedDecimalString(String value) {
    final filtered = value.replaceAll(RegExp(r'[^0-9,.-]'), '');
    final lastDot = filtered.lastIndexOf('.');
    final lastComma = filtered.lastIndexOf(',');

    if (lastDot == -1) {
      return filtered.replaceAll(',', '.');
    }
    if (lastComma == -1) {
      return filtered;
    }

    final decimalSeparator = lastDot > lastComma ? '.' : ',';
    final groupingSeparator = decimalSeparator == '.' ? ',' : '.';

    return filtered
        .replaceAll(groupingSeparator, '')
        .replaceAll(decimalSeparator, '.');
  }
}
