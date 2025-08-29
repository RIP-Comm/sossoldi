// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

// Model
import '/model/transaction.dart';

class TransactionLocation extends Migration {
  TransactionLocation()
      : super(
          version: 3,
          description: 'Add lat, lon, and locationName to transaction table',
        );

  @override
  Future<void> up(Database db) async {
    await db.execute('''
      ALTER TABLE `$transactionTable` ADD COLUMN `${TransactionFields.lat}` REAL;
    ''');

    await db.execute('''
      ALTER TABLE `$transactionTable` ADD COLUMN `${TransactionFields.lon}` REAL;
    ''');

    await db.execute('''
      ALTER TABLE `$transactionTable` ADD COLUMN `${TransactionFields.locationName}` TEXT;
    ''');
  }
}
