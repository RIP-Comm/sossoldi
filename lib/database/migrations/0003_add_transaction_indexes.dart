import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

class AddTransactionIndexes extends Migration {
  AddTransactionIndexes()
      : super(
            version: 3,
            description:
                'Add transaction indexes for better query performance');

  @override
  Future<void> up(Database db) async {
    // Create indexes for common query patterns
    await db
        .execute('CREATE INDEX idx_transaction_date ON "transaction"(date)');
    await db
        .execute('CREATE INDEX idx_transaction_type ON "transaction"(type)');
    await db.execute(
        'CREATE INDEX idx_transaction_id_bank_account ON "transaction"(idBankAccount)');
  }
}
