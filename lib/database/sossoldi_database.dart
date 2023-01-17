import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Models
import '../model/bank_account.dart';
import '../model/transaction.dart';
import '../model/recurring_transaction.dart';
import '../model/recurring_transaction_amount.dart';
import '../model/category_transaction.dart';
import '../model/category_recurring_transaction.dart';
import '../model/budget.dart';

class SossoldiDatabase {
  static final SossoldiDatabase instance = SossoldiDatabase._init();
  static Database? _database;

  // Zero args constructor needed to extend this class
  SossoldiDatabase();

  SossoldiDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('sossoldi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // On Android, it is typically data/data//databases.
    // On iOS and MacOS, it is the Documents directory.
    final databasePath = await getDatabasesPath();
    // Directory databasePath = await getApplicationDocumentsDirectory();

    final path = join(databasePath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database database, int version) async {
    const integerPrimaryKeyAutoincrement = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const booleanNotNull = 'BOOLEAN NOT NULL';
    const integerNotNull = 'INTEGER NOT NULL';
    const integer = 'INTEGER';
    const realNotNull = 'REAL NOT NULL';
    const textNotNull = 'TEXT NOT NULL';
    const text = 'TEXT';

    // Bank accounts Table
    await database.execute(
        '''
      CREATE TABLE `$bankAccountTable`(
        `${BankAccountFields.id}` $integerPrimaryKeyAutoincrement,
        `${BankAccountFields.name}` $textNotNull,
        `${BankAccountFields.value}` $realNotNull,
        `${BankAccountFields.mainAccount}` $booleanNotNull CHECK (${BankAccountFields.mainAccount} IN (0, 1)),
        `${BankAccountFields.createdAt}` $textNotNull,
        `${BankAccountFields.updatedAt}` $text
      )
      ''');

    // Transactions Table
    await database.execute(
        '''
      CREATE TABLE `$transactionTable`(
        `${TransactionFields.id}` $integerPrimaryKeyAutoincrement,
        `${TransactionFields.date}` $textNotNull,
        `${TransactionFields.amount}` $realNotNull,
        `${TransactionFields.type}` $integerNotNull,
        `${TransactionFields.note}` $text,
        `${TransactionFields.idBankAccount}` $integerNotNull,
        `${TransactionFields.idBudget}` $integerNotNull,
        `${TransactionFields.idCategory}` $integerNotNull,
        `${TransactionFields.idRecurringTransaction}` $integer,
        `${TransactionFields.createdAt}` $textNotNull,
        `${TransactionFields.updatedAt}` $textNotNull
      )
    ''');

    // Recurring Transactions Table
    await database.execute(
        '''
      CREATE TABLE `$recurringTransactionTable`(
        `${RecurringTransactionFields.id}` $integerPrimaryKeyAutoincrement,
        `${RecurringTransactionFields.from}` $textNotNull,
        `${RecurringTransactionFields.to}` $textNotNull,
        `${RecurringTransactionFields.payDay}` $textNotNull,
        `${RecurringTransactionFields.recurrence}` $textNotNull,
        `${RecurringTransactionFields.idCategoryRecurring}` $integerNotNull,
        `${RecurringTransactionFields.createdAt}` $textNotNull,
        `${RecurringTransactionFields.updatedAt}` $textNotNull
      )
    ''');

    // Recurring Transactions Amount Table
    await database.execute(
        '''
      CREATE TABLE `$recurringTransactionAmountTable`(
        `${RecurringTransactionAmountFields.id}` $integerPrimaryKeyAutoincrement,
        `${RecurringTransactionAmountFields.from}` $textNotNull,
        `${RecurringTransactionAmountFields.to}` $textNotNull,
        `${RecurringTransactionAmountFields.amount}` $realNotNull,
        `${RecurringTransactionAmountFields.idRecurringTransaction}` $integerNotNull,
        `${RecurringTransactionAmountFields.createdAt}` $textNotNull,
        `${RecurringTransactionAmountFields.updatedAt}` $textNotNull
      )
    ''');

    // Category Transaction Table
    await database.execute(
        '''
      CREATE TABLE `$categoryTransactionTable`(
        `${CategoryTransactionFields.id}` $integerPrimaryKeyAutoincrement,
        `${CategoryTransactionFields.name}` $textNotNull,
        `${CategoryTransactionFields.symbol}` $textNotNull,
        `${CategoryTransactionFields.note}` $textNotNull,
        `${CategoryTransactionFields.createdAt}` $textNotNull,
        `${CategoryTransactionFields.updatedAt}` $textNotNull
      )
    ''');

    // Category Recurring Transaction Table
    await database.execute(
        '''
      CREATE TABLE `$categoryRecurringTransactionTable`(
        `${CategoryRecurringTransactionFields.id}` $integerPrimaryKeyAutoincrement,
        `${CategoryRecurringTransactionFields.name}` $textNotNull,
        `${CategoryRecurringTransactionFields.symbol}` $textNotNull,
        `${CategoryRecurringTransactionFields.note}` $textNotNull,
        `${CategoryRecurringTransactionFields.createdAt}` $textNotNull,
        `${CategoryRecurringTransactionFields.updatedAt}` $textNotNull
      )
    ''');

    // Budget Table
    await database.execute(
        '''
      CREATE TABLE `$budgetTable`(
        `${BudgetFields.id}` $integerPrimaryKeyAutoincrement,
        `${BudgetFields.name}` $textNotNull,
        `${BudgetFields.amountLimit}` $realNotNull,
        `${BudgetFields.createdAt}` $textNotNull,
        `${BudgetFields.updatedAt}` $textNotNull
      )
    ''');

    // TEMP Insert Demo data
    await database.execute(
        '''
      INSERT INTO bankAccount(name, value, mainAccount, createdAt, updatedAt) VALUES
        ("DB main", 1235.10, true, '${DateTime.now()}', '${DateTime.now()}'),
        ("DB N26", 3823.56, false, '${DateTime.now()}', '${DateTime.now()}'),
        ("DB Fineco", 0.07, false, '${DateTime.now()}', '${DateTime.now()}');
    ''');

  }

  Future close() async {
    final database = await instance.database;
    database.close();
  }

  // WARNING: FOR DEV/TEST PURPOSES ONLY!!
  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'sossoldi.db');
    databaseFactory.deleteDatabase(path);
  }
}
