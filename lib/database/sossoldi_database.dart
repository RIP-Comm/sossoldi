import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Models
import '../model/bank_account.dart';
import '../model/transaction.dart';
import '../model/recurring_transaction_amount.dart';
import '../model/category_transaction.dart';
import '../model/budget.dart';
import '../model/currency.dart';

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
    await database.execute('''
      CREATE TABLE `$bankAccountTable`(
        `${BankAccountFields.id}` $integerPrimaryKeyAutoincrement,
        `${BankAccountFields.name}` $textNotNull,
        `${BankAccountFields.value}` $realNotNull,
        `${BankAccountFields.mainAccount}` $booleanNotNull CHECK (${BankAccountFields.mainAccount} IN (0, 1)),
        `${BankAccountFields.createdAt}` $textNotNull,
        `${BankAccountFields.updatedAt}` $textNotNull
      )
      ''');

    // Transactions Table
    await database.execute('''
      CREATE TABLE `$transactionTable`(
        `${TransactionFields.id}` $integerPrimaryKeyAutoincrement,
        `${TransactionFields.date}` $textNotNull,
        `${TransactionFields.amount}` $realNotNull,
        `${TransactionFields.type}` $integerNotNull,
        `${TransactionFields.note}` $text,
        `${TransactionFields.idCategory}` $integerNotNull,
        `${TransactionFields.idBankAccount}` $integerNotNull,
        `${TransactionFields.idBankAccountTransfer}` $integer,
        `${TransactionFields.recurring}` $booleanNotNull CHECK (${TransactionFields.recurring} IN (0, 1)),
        `${TransactionFields.recurrencyType}` $text,
        `${TransactionFields.recurrencyPayDay}` $integer,
        `${TransactionFields.recurrencyFrom}` $textNotNull,
        `${TransactionFields.recurrencyTo}` $textNotNull,
        `${TransactionFields.createdAt}` $textNotNull,
        `${TransactionFields.updatedAt}` $textNotNull
      )
    ''');

    // Recurring Transactions Amount Table
    await database.execute('''
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
    await database.execute('''
      CREATE TABLE `$categoryTransactionTable`(
        `${CategoryTransactionFields.id}` $integerPrimaryKeyAutoincrement,
        `${CategoryTransactionFields.name}` $textNotNull,
        `${CategoryTransactionFields.symbol}` $textNotNull,
        `${CategoryTransactionFields.note}` $text,
        `${CategoryTransactionFields.parent}` $integer,
        `${CategoryTransactionFields.createdAt}` $textNotNull,
        `${CategoryTransactionFields.updatedAt}` $textNotNull
      )
    ''');

    // Budget Table
    await database.execute('''
      CREATE TABLE `$budgetTable`(
        `${BudgetFields.id}` $integerPrimaryKeyAutoincrement,
        `${BudgetFields.idCategory}` $integerNotNull,
        `${BudgetFields.name}` $textNotNull,
        `${BudgetFields.amountLimit}` $realNotNull,
        `${BudgetFields.active}` $integerNotNull  CHECK (${BudgetFields.active} IN (0, 1)),
        `${BudgetFields.createdAt}` $textNotNull,
        `${BudgetFields.updatedAt}` $textNotNull
      )
    ''');

    // Currencies Table
    await database.execute('''
      CREATE TABLE `$currencyTable`(
        `${CurrencyFields.id}` $integerPrimaryKeyAutoincrement,
        `${CurrencyFields.symbol}` $textNotNull,
        `${CurrencyFields.code}` $textNotNull,
        `${CurrencyFields.name}` $textNotNull,
        `${CurrencyFields.mainCurrency}` $booleanNotNull CHECK (${CurrencyFields.mainCurrency} IN (0, 1))
      )
      ''');

    // TEMP Insert Demo data
    await database.execute('''
      INSERT INTO bankAccount(name, value, mainAccount, createdAt, updatedAt) VALUES
        ("main", 1235.10, true, '${DateTime.now()}', '${DateTime.now()}'),
        ("N26", 3823.56, false, '${DateTime.now()}', '${DateTime.now()}'),
        ("Fineco", 0.07, false, '${DateTime.now()}', '${DateTime.now()}');
    ''');
    await database.execute('''
      INSERT INTO categoryTransaction(name, symbol, note, parent, createdAt, updatedAt) VALUES
        ("Out", "restaurant", '', '', '${DateTime.now()}', '${DateTime.now()}'),
        ("Home", "home", '', '', '${DateTime.now()}', '${DateTime.now()}'),
        ("Furniture", "home", '', 2, '${DateTime.now()}', '${DateTime.now()}'),
        ("Shopping", "shopping_cart", '', '', '${DateTime.now()}', '${DateTime.now()}'),
        ("Leisure", "subscriptions", '', '', '${DateTime.now()}', '${DateTime.now()}');
    ''');

    await database.execute('''
      INSERT INTO currency(symbol, code, name, mainCurrency) VALUES
        ("€", "EUR", "Euro", true),
        ("\$", "USD", "United States Dollar", false),
        ("CHF", "CHF", "Switzerland Franc", false),
        ("£", "GBP", "United Kingdom Pound", false);
    ''');

    await database.execute('''
      INSERT INTO budget(idCategory, name, amountLimit, active, createdAt, updatedAt) VALUES
        (2, "Car", 400.00, 1, '${DateTime.now()}', '${DateTime.now()}'),
        (3, "Home", 123.45, 0, '${DateTime.now()}', '${DateTime.now()}');
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
