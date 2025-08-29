// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import '../../../model/recurring_transaction.dart';
import '../migration_base.dart';

// Model
import '../../../model/transaction.dart';

class RecurrentTransactionLocation extends Migration {
  RecurrentTransactionLocation()
      : super(
          version: 3,
          description: 'Add lat, lon, and locationName to recurrent transaction table',
        );

  @override
  Future<void> up(Database db) async {
    await db.execute('''
      ALTER TABLE `$recurringTransactionTable` ADD COLUMN `${TransactionFields.lat}` REAL;
    ''');

    await db.execute('''
      ALTER TABLE `$recurringTransactionTable` ADD COLUMN `${TransactionFields.lon}` REAL;
    ''');

    await db.execute('''
      ALTER TABLE `$recurringTransactionTable` ADD COLUMN `${TransactionFields.locationName}` TEXT;
    ''');
  }
}
