// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

// Models
import '/model/bank_account.dart';

class AddAccountOrder extends Migration {
  AddAccountOrder()
    : super(version: 5, description: 'Add position column to account');

  @override
  Future<void> up(Database db) async {
    await db.execute(
      'ALTER TABLE $bankAccountTable ADD COLUMN ${BankAccountFields.order} INTEGER NOT NULL DEFAULT 0',
    );

    final rows = await db.query(bankAccountTable, orderBy: 'id');

    for (int i = 0; i < rows.length; i++) {
      await db.update(
        bankAccountTable,
        {BankAccountFields.order: i},
        where: '${BankAccountFields.id} = ?',
        whereArgs: [rows[i][BankAccountFields.id]],
      );
    }
  }
}
