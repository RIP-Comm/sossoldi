import 'bank_money.dart';
import 'bank_remote_transaction.dart';
import '../banking_balance.dart';

class BankBalanceSnapshot {
  final BankMoney money;
  final DateTime at;

  const BankBalanceSnapshot(this.money, this.at);
}

/// Reconciliation uses booked balances whose last entry is in this fetched batch.
BankBalanceSnapshot? selectBankBalance(
  List<BankingBalance> balances,
  List<BankRemoteTransaction> transactions,
  String currency,
  DateTime? serverTime,
) {
  if (serverTime == null) return null;
  final booked = transactions.where((item) => item.status == 'BOOK').toList();
  final candidates = <BankBalanceSnapshot>[];
  for (final balance in balances) {
    if (balance.amount.currency != currency ||
        !const {
          BankingBalanceKind.closingBooked,
          BankingBalanceKind.interimBooked,
        }.contains(balance.kind)) {
      continue;
    }
    final marker = BankRemoteTransaction.normalizeId(
      balance.lastCommittedEntryId,
    );
    final reference = balance.referenceDate;
    final at =
        balance.observedAt ??
        (reference == null
            ? null
            : DateTime.utc(
                reference.year,
                reference.month,
                reference.day,
                23,
                59,
                59,
              ));
    if (at == null ||
        at.isAfter(serverTime) ||
        serverTime.difference(at) > const Duration(days: 2)) {
      continue;
    }
    if (booked.any((item) => item.date.isAfter(at))) continue;
    final money = BankMoney.parse(balance.amount.decimalAmount, currency);
    final emptyZero =
        booked.isEmpty && marker == null && money.minorUnits == BigInt.zero;
    if (!emptyZero) {
      if (marker == null ||
          !booked.any((item) => item.entryReference == marker)) {
        continue;
      }
      final markerDate = booked
          .firstWhere((item) => item.entryReference == marker)
          .date;
      if (booked.any((item) => item.date.isAfter(markerDate))) continue;
    }
    money.projection;
    candidates.add(BankBalanceSnapshot(money, at));
  }
  candidates.sort((first, second) => second.at.compareTo(first.at));
  if (candidates.isEmpty) return null;
  final newest = candidates.first;
  if (candidates.any(
    (item) =>
        item.at == newest.at &&
        item.money.minorUnits != newest.money.minorUnits,
  )) {
    return null;
  }
  return newest;
}
