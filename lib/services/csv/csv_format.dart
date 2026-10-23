import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/bank_account.dart';
import '../../model/base_entity.dart';
import '../../model/budget.dart';
import '../../model/category_transaction.dart';
import '../../model/currency.dart';
import '../../model/recurring_transaction.dart';
import '../../model/transaction.dart';

class CsvColumn {
  const CsvColumn(this.name, {required this.required});

  final String name;
  final bool required;
}

// Describes the CSV format used by import/export and builds a template file
class CsvFormat {
  const CsvFormat._();

  static const String tableNameColumn = 'table_name';

  static final Map<String, List<String>> tableFields = {
    bankAccountTable: BankAccountFields.allFields,
    categoryTransactionTable: CategoryTransactionFields.allFields,
    transactionTable: TransactionFields.allFields,
    recurringTransactionTable: RecurringTransactionFields.allFields,
    budgetTable: BudgetFields.allFields,
    currencyTable: CurrencyFields.allFields,
  };

  // Columns of each importable table, read from the database schema so that
  // NOT NULL columns without a default are reported as required
  static Future<Map<String, List<CsvColumn>>> columns(Database db) async {
    final Map<String, List<CsvColumn>> result = {};
    for (final table in tableFields.keys) {
      final info = await db.rawQuery('PRAGMA table_info("$table")');
      result[table] = info
          .map(
            (column) => CsvColumn(
              column['name'] as String,
              required:
                  column['notnull'] == 1 &&
                  column['dflt_value'] == null &&
                  column['pk'] == 0,
            ),
          )
          .toList();
    }
    return result;
  }

  // A small example file (one account, one category, one transaction)
  // in the same layout produced by the export
  static String template() {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day, 12).toIso8601String();
    final timestamp = now.toIso8601String();

    final Map<String, Map<String, Object?>> examples = {
      bankAccountTable: {
        BaseEntityFields.id: 1,
        BankAccountFields.name: 'Main account',
        BankAccountFields.symbol: 'account_balance',
        BankAccountFields.color: 0,
        BankAccountFields.startingValue: 1000,
        BankAccountFields.active: 1,
        BankAccountFields.countNetWorth: 1,
        BankAccountFields.mainAccount: 1,
        BankAccountFields.order: 0,
      },
      categoryTransactionTable: {
        BaseEntityFields.id: 1,
        CategoryTransactionFields.name: 'Groceries',
        CategoryTransactionFields.type: CategoryTransactionType.expense.code,
        CategoryTransactionFields.symbol: 'shopping_cart',
        CategoryTransactionFields.color: 3,
        CategoryTransactionFields.order: 0,
      },
      transactionTable: {
        BaseEntityFields.id: 1,
        TransactionFields.date: date,
        TransactionFields.amount: 25.5,
        TransactionFields.type: TransactionType.expense.code,
        TransactionFields.note: 'Supermarket',
        TransactionFields.idCategory: 1,
        TransactionFields.idBankAccount: 1,
        TransactionFields.recurring: 0,
      },
    };

    final headers = <String>{
      tableNameColumn,
      for (final fields in tableFields.values) ...fields,
    }.toList();

    final rows = <List<Object?>>[headers];
    examples.forEach((table, values) {
      final row = {
        tableNameColumn: table,
        BaseEntityFields.createdAt: timestamp,
        BaseEntityFields.updatedAt: timestamp,
        ...values,
      };
      rows.add(headers.map((header) => row[header] ?? '').toList());
    });

    return const ListToCsvConverter().convert(rows);
  }
}
