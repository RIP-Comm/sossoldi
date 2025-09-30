import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

// Models
import '/model/recurring_transaction.dart';

class RecurringTransactionType extends Migration {
  RecurringTransactionType()
      : super(
            version: 3, description: 'Add type to recurring transaction table');

  @override
  Future<void> up(Database db) async {
    const textNotNull = 'TEXT NOT NULL';

    // Bank accounts Table
    await db.execute('''
      ALTER TABLE `$recurringTransactionTable` ADD COLUMN `${RecurringTransactionFields.type}` $textNotNull DEFAULT 'OUT';
      ''');
  }
}
