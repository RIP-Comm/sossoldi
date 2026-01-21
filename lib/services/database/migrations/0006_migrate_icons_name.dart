// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

// Models
import '../../../model/category_transaction.dart';

class MigrateIconsName extends Migration {
  MigrateIconsName()
    : super(version: 6, description: 'Migrate icons name to match constants');

  @override
  Future<void> up(Database db) async {
    await db.rawUpdate(
      "UPDATE $categoryTransactionTable SET ${CategoryTransactionFields.symbol} = substr(${CategoryTransactionFields.symbol}, 1, length(${CategoryTransactionFields.symbol}) - 8) WHERE ${CategoryTransactionFields.symbol} LIKE '%_rounded'",
    );
  }
}
