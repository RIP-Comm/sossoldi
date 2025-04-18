import 'package:sqflite/sqflite.dart';

import '../migration_base.dart';
import '../../model/recurring_transaction.dart';

class AddTypeToRecurringTransaction extends Migration {
  AddTypeToRecurringTransaction()
      : super(
          version: 3,
          description: 'Add type column to recurringTransaction table',
        );

  @override
  Future<void> up(Database db) async {
    const integerNotNull = 'INTEGER NOT NULL';
    await db.execute('''
      ALTER TABLE $recurringTransactionTable
      ADD COLUMN type $integerNotNull DEFAULT 1
    ''');
  }
}
