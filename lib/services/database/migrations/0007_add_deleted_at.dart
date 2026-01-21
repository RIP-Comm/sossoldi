// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import '../../../model/bank_account.dart';
import '../migration_base.dart';

// Models
import '/model/category_transaction.dart';

class AddDeletedAt extends Migration {
  AddDeletedAt()
    : super(
        version: 6,
        description: 'Add deletedAt column to account and category tables',
      );

  @override
  Future<void> up(Database db) async {
    await db.execute(
      'ALTER TABLE $bankAccountTable ADD COLUMN ${BankAccountFields.deletedAt} TEXT',
    );
    await db.execute(
      'ALTER TABLE $categoryTransactionTable ADD COLUMN ${CategoryTransactionFields.deletedAt} TEXT',
    );
  }
}
