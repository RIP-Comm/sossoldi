// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

// Models
import '/model/category_transaction.dart';

class AddCategoryOrder extends Migration {
  AddCategoryOrder()
    : super(
        version: 4,
        description: 'Add position column to category transaction',
      );

  @override
  Future<void> up(Database db) async {
    await db.execute(
      'ALTER TABLE $categoryTransactionTable ADD COLUMN ${CategoryTransactionFields.order} INTEGER NOT NULL DEFAULT 0',
    );

    final rows = await db.query(categoryTransactionTable, orderBy: 'id');

    for (int i = 0; i < rows.length; i++) {
      await db.update(
        categoryTransactionTable,
        {CategoryTransactionFields.order: i},
        where: '${CategoryTransactionFields.id} = ?',
        whereArgs: [rows[i][CategoryTransactionFields.id]],
      );
    }
  }
}
