// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

// Models
import '/model/category_transaction.dart';

class CategoryMarkedAsDeleted extends Migration {
  CategoryMarkedAsDeleted()
      : super(
          version: 3,
          description: 'Add deleted column to CategoryTransaction model',
        );

  @override
  Future<void> up(Database db) async {
    const integerNotNull = 'INTEGER NOT NULL';

    // CategoryTransactionTable
    await db.execute('''
      ALTER TABLE `$categoryTransactionTable` ADD COLUMN `${CategoryTransactionFields.deleted}` $integerNotNull DEFAULT 0;
    ''');
  }
}
