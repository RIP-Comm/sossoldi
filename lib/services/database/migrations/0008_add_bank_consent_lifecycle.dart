// dart format width=400

// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';

import '../../../model/bank_account.dart';
import '../../../model/bank_connection.dart';
import '../migration_base.dart';

class AddBankConsentLifecycle extends Migration {
  AddBankConsentLifecycle() : super(version: 8, description: 'Add bank consent lifecycle and stable account identity');

  @override
  Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE `$bankConnectionTable` (
        `${BankConnectionFields.id}` INTEGER PRIMARY KEY AUTOINCREMENT,
        `${BankConnectionFields.institutionName}` TEXT NOT NULL,
        `${BankConnectionFields.institutionCountry}` TEXT NOT NULL,
        `${BankConnectionFields.applicationId}` TEXT NOT NULL,
        `${BankConnectionFields.remoteConnectionId}` TEXT,
        `${BankConnectionFields.pendingRemoteConnectionId}` TEXT,
        `${BankConnectionFields.pendingAuthorizationId}` TEXT,
        `${BankConnectionFields.validUntil}` TEXT,
        `${BankConnectionFields.pendingValidUntil}` TEXT,
        `${BankConnectionFields.status}` TEXT NOT NULL CHECK (
          `${BankConnectionFields.status}` IN (
            'AUTHORIZING', 'AWAITING_IMPORT', 'ACTIVE', 'EXPIRED',
            'REVOKED', 'REAUTH_REQUIRED', 'REVOCATION_PENDING', 'DISCONNECTED'
          )
        ),
        `${BankConnectionFields.psuType}` TEXT NOT NULL DEFAULT 'personal'
          CHECK (`${BankConnectionFields.psuType}` = 'personal'),
        `${BankConnectionFields.createdAt}` TEXT NOT NULL,
        `${BankConnectionFields.updatedAt}` TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX `idx_bank_connection_session`
      ON `$bankConnectionTable` (`${BankConnectionFields.remoteConnectionId}`)
      WHERE `${BankConnectionFields.remoteConnectionId}` IS NOT NULL
    ''');
    await db.execute('''
      CREATE UNIQUE INDEX `idx_bank_connection_pending_authorization`
      ON `$bankConnectionTable`
      (`${BankConnectionFields.pendingAuthorizationId}`)
      WHERE `${BankConnectionFields.pendingAuthorizationId}` IS NOT NULL
    ''');

    await db.execute(
      'ALTER TABLE `$bankAccountTable` ADD COLUMN '
      '`${BankAccountFields.ebAccountUid}` TEXT',
    );
    await db.execute(
      'ALTER TABLE `$bankAccountTable` ADD COLUMN '
      '`${BankAccountFields.ebConnectionId}` INTEGER',
    );
    await db.execute(
      'ALTER TABLE `$bankAccountTable` ADD COLUMN '
      '`${BankAccountFields.identificationHash}` TEXT',
    );
    await db.execute(
      'ALTER TABLE `$bankAccountTable` ADD COLUMN '
      '`${BankAccountFields.identificationHashes}` TEXT',
    );
    await db.execute(
      'ALTER TABLE `$bankAccountTable` ADD COLUMN '
      '`${BankAccountFields.iban}` TEXT',
    );
    await db.execute(
      'ALTER TABLE `$bankAccountTable` ADD COLUMN '
      '`${BankAccountFields.lastSyncAt}` TEXT',
    );

    await db.execute('''
      CREATE TABLE `$bankAccountIdentityTable` (
        `${BankAccountIdentityFields.connectionId}` INTEGER NOT NULL,
        `${BankAccountIdentityFields.bankAccountId}` INTEGER NOT NULL,
        `${BankAccountIdentityFields.identificationHash}` TEXT NOT NULL,
        PRIMARY KEY (
          `${BankAccountIdentityFields.connectionId}`,
          `${BankAccountIdentityFields.identificationHash}`
        ),
        UNIQUE (
          `${BankAccountIdentityFields.bankAccountId}`,
          `${BankAccountIdentityFields.identificationHash}`
        )
      )
    ''');
    await db.execute('''
      CREATE INDEX `idx_bank_account_connection`
      ON `$bankAccountTable` (`${BankAccountFields.ebConnectionId}`)
    ''');
  }
}
