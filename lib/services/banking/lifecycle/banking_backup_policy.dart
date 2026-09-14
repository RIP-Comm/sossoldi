// dart format width=400

import '../../../model/bank_account.dart';
import '../../../model/bank_connection.dart';

class BankingBackupPolicy {
  const BankingBackupPolicy._();

  static Map<String, Object?> sanitizeForExport(String table, Map<String, Object?> row) {
    final sanitized = Map<String, Object?>.from(row);
    if (table == bankConnectionTable) {
      sanitized[BankConnectionFields.remoteConnectionId] = null;
      sanitized[BankConnectionFields.pendingRemoteConnectionId] = null;
      sanitized[BankConnectionFields.pendingAuthorizationId] = null;
      sanitized[BankConnectionFields.pendingValidUntil] = null;
      sanitized[BankConnectionFields.status] = BankConnectionStatus.reauthRequired.code;
    } else if (table == bankAccountTable) {
      sanitized[BankAccountFields.ebAccountUid] = null;
      sanitized[BankAccountFields.lastSyncAt] = null;
    }
    return sanitized;
  }

  static Map<String, Object?> sanitizeForRestore(String table, Map<String, Object?> row) => sanitizeForExport(table, row);
}
