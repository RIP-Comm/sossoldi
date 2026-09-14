// dart format width=400

// ignore_for_file: file_names
// dart format width=400

import 'package:sqflite/sqflite.dart';

import '../../../model/bank_connection.dart';
import '../migration_base.dart';

class AddBankProviderIdentity extends Migration {
  AddBankProviderIdentity() : super(version: 9, description: 'Namespace persisted connections by banking provider');

  @override
  Future<void> up(Database db) async {
    await db.execute("ALTER TABLE `$bankConnectionTable` ADD COLUMN `${BankConnectionFields.providerId}` TEXT NOT NULL DEFAULT 'enable_banking'");
    await db.execute('DROP INDEX idx_bank_connection_session');
    await db.execute('DROP INDEX idx_bank_connection_pending_authorization');
    await db.execute('CREATE UNIQUE INDEX idx_bank_connection_session ON `$bankConnectionTable` (`${BankConnectionFields.providerId}`, `${BankConnectionFields.remoteConnectionId}`) WHERE `${BankConnectionFields.remoteConnectionId}` IS NOT NULL');
    await db.execute('CREATE UNIQUE INDEX idx_bank_connection_pending_authorization ON `$bankConnectionTable` (`${BankConnectionFields.providerId}`, `${BankConnectionFields.pendingAuthorizationId}`) WHERE `${BankConnectionFields.pendingAuthorizationId}` IS NOT NULL');
  }
}
