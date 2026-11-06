enum BankSyncStatus {
  success,
  noChange,
  partial,
  retryableFailure,
  terminalFailure,
  skipped,
}

/// Diagnostics contain codes and counts only, never response bodies or bank IDs.
class BankSyncResult {
  final int accountId;
  final BankSyncStatus status;
  final int inserted;
  final int updated;
  final int cancelled;
  final int rejected;
  final List<String> warnings;

  const BankSyncResult({
    required this.accountId,
    required this.status,
    this.inserted = 0,
    this.updated = 0,
    this.cancelled = 0,
    this.rejected = 0,
    this.warnings = const [],
  });

  bool get completed =>
      status == BankSyncStatus.success || status == BankSyncStatus.noChange;
}

class BankSyncSummary {
  final List<BankSyncResult> accounts;

  BankSyncSummary(Iterable<BankSyncResult> accounts)
    : accounts = List.unmodifiable(accounts);

  BankSyncStatus get status {
    if (accounts.isEmpty) return BankSyncStatus.skipped;
    if (accounts.every((result) => result.completed)) {
      return accounts.every(
            (result) => result.status == BankSyncStatus.noChange,
          )
          ? BankSyncStatus.noChange
          : BankSyncStatus.success;
    }
    if (accounts.any(
      (result) => result.completed || result.status == BankSyncStatus.partial,
    )) {
      return BankSyncStatus.partial;
    }
    if (accounts.any(
      (result) => result.status == BankSyncStatus.retryableFailure,
    )) {
      return BankSyncStatus.retryableFailure;
    }
    if (accounts.every((result) => result.status == BankSyncStatus.skipped)) {
      return BankSyncStatus.skipped;
    }
    return BankSyncStatus.terminalFailure;
  }
}

/// A validated batch cannot reconcile against the existing financial baseline.
class BankSyncIntegrityException implements Exception {
  final String code;
  const BankSyncIntegrityException(this.code);
}
