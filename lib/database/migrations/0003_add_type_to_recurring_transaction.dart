import 'package:sqflite/sqflite.dart';

import '../migration_base.dart';
import '../sossoldi_database.dart';
import '0001_initial_schema.dart';

class Migration3AddTypeToRecurringTransaction extends Migration {
  Migration3AddTypeToRecurringTransaction()
      : super(
          version: 2,
          description: 'Add type column to recurringTransaction table',
        );

  @override
  Future<void> up(Database db) async {
    const textNotNull = 'TEXT NOT NULL';
    await db.execute('''
      ALTER TABLE recurringTransaction
      ADD COLUMN type $textNotNull DEFAULT 'expense'
    ''');
  }

  @override
  Future<void> down(Database db) async {
    await db.execute('''
      ALTER TABLE recurringTransaction
      DROP COLUMN type
    ''');
  }
}
