// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

// Models
import '/model/category_transaction.dart';

class UncategorizedDefaultCategory extends Migration {
  UncategorizedDefaultCategory()
      : super(
          version: 4,
          description: 'Create default "Uncategorized" category',
        );

  @override
  Future<void> up(Database db) async {

    // Default "Uncategorized" Category
    await db.execute('''
      INSERT INTO `$categoryTransactionTable`(`${CategoryTransactionFields.id}`, `${CategoryTransactionFields.name}`, `${CategoryTransactionFields.type}`, `${CategoryTransactionFields.symbol}`, `${CategoryTransactionFields.color}`, `${CategoryTransactionFields.note}`, `${CategoryTransactionFields.parent}`, `${CategoryTransactionFields.deleted}`, `${CategoryTransactionFields.createdAt}`, `${CategoryTransactionFields.updatedAt}`) VALUES
        (0, "Uncategorized", "IN", "question_mark", 0, 'This is a default category for no categorized transactions', null, '0', '${DateTime.now()}', '${DateTime.now()}'),
        (1, "Uncategorized", "OUT", "question_mark", 0, 'This is a default category for no categorized transactions', null, '0', '${DateTime.now()}', '${DateTime.now()}');
    ''');
  }
}