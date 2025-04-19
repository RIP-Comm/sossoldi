import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

// Models
import '/model/bank_account.dart';

class AccountNetWorth extends Migration {
  AccountNetWorth()
      : super(
          version: 2,
          description: 'Add account net worth column',
        );

  @override
  Future<void> up(Database db) async {
    const integerNotNull = 'INTEGER NOT NULL';

    // Bank accounts Table
    await db.execute('''
      ALTER TABLE `$bankAccountTable` ADD COLUMN `${BankAccountFields.countNetWorth}` $integerNotNull CHECK (${BankAccountFields.countNetWorth} IN (0, 1)) DEFAULT 1;
      ''');
  }
}
