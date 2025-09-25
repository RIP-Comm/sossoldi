import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

// Models
import '/model/recurring_transaction.dart';

class RecurringTransactionTypeText extends Migration {
  RecurringTransactionTypeText()
      : super(
            version: 4,
            description:
                'Change type column to text not null with default OUT');

  @override
  Future<void> up(Database db) async {
    // Step 1: Rename existing column
    await db.execute('''
      ALTER TABLE `$recurringTransactionTable` RENAME COLUMN `${RecurringTransactionFields.type}` TO `${RecurringTransactionFields.type}_old`;
      ''');

    // Step 2: Add new column with correct type and default
    await db.execute('''
      ALTER TABLE `$recurringTransactionTable` ADD COLUMN `${RecurringTransactionFields.type}` TEXT NOT NULL DEFAULT 'OUT';
      ''');

    // Step 3: Copy data from old column to new column
    await db.execute('''
      UPDATE `$recurringTransactionTable` SET `${RecurringTransactionFields.type}` = `${RecurringTransactionFields.type}_old`;
      ''');

    // Step 4: Drop the old column
    await db.execute('''
      ALTER TABLE `$recurringTransactionTable` DROP COLUMN `${RecurringTransactionFields.type}_old`;
      ''');
  }
}
