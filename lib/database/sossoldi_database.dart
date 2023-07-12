import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'dart:math'; // used for random number generation in demo data

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
        `${BankAccountFields.symbol}` $textNotNull,
        `${BankAccountFields.color}` $integerNotNull,
        `${BankAccountFields.startingValue}` $realNotNull,
        `${BankAccountFields.active}` $integerNotNull CHECK (${BankAccountFields.active} IN (0, 1)),
        `${BankAccountFields.mainAccount}` $integerNotNull CHECK (${BankAccountFields.mainAccount} IN (0, 1)),
        `${BankAccountFields.createdAt}` $textNotNull,
        `${BankAccountFields.updatedAt}` $textNotNull
      )
      ''');

    // Transactions Table
    await database.execute('''
      CREATE TABLE `$transactionTable`(
        `${TransactionFields.id}` $integerPrimaryKeyAutoincrement,
        `${TransactionFields.date}` $text,
        `${TransactionFields.amount}` $realNotNull,
        `${TransactionFields.type}` $integerNotNull,
        `${TransactionFields.note}` $text,
        `${TransactionFields.idCategory}` $integer,
        `${TransactionFields.idBankAccount}` $integerNotNull,
        `${TransactionFields.idBankAccountTransfer}` $integer,
        `${TransactionFields.recurring}` $integerNotNull CHECK (${TransactionFields.recurring} IN (0, 1)),
        `${TransactionFields.recurrencyType}` $text,
        `${TransactionFields.recurrencyPayDay}` $integer,
        `${TransactionFields.recurrencyFrom}` $text,
        `${TransactionFields.recurrencyTo}` $text,
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
        `${RecurringTransactionAmountFields.idTransaction}` $integerNotNull,
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
        `${CategoryTransactionFields.color}` $integerNotNull,
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
        `${CurrencyFields.mainCurrency}` $integerNotNull CHECK (${CurrencyFields.mainCurrency} IN (0, 1))
      )
      ''');

  }

  Future fillDemoData() async {
    // Add some fake accounts
    await _database?.execute('''
      INSERT INTO bankAccount(id, name, symbol, color, startingValue, active, mainAccount, createdAt, updatedAt) VALUES
        (70, "Revolut", 'payments', 1, 1235.10, 1, 1, '${DateTime.now()}', '${DateTime.now()}'),
        (71, "N26", 'credit_card', 2, 3823.56, 1, 0, '${DateTime.now()}', '${DateTime.now()}'),
        (72, "Fineco", 'account_balance', 3, 0.00, 1, 0, '${DateTime.now()}', '${DateTime.now()}');
    ''');

    // Add fake categories
    await _database?.execute('''
      INSERT INTO categoryTransaction(id, name, symbol, color, note, parent, createdAt, updatedAt) VALUES
        (10, "Out", "restaurant", 0, '', null, '${DateTime.now()}', '${DateTime.now()}'),
        (11, "Home", "home", 1, '', null, '${DateTime.now()}', '${DateTime.now()}'),
        (12, "Furniture", "home", 2, '', 11, '${DateTime.now()}', '${DateTime.now()}'),
        (13, "Shopping", "shopping_cart", 3, '', null, '${DateTime.now()}', '${DateTime.now()}'),
        (14, "Leisure", "subscriptions", 4, '', null, '${DateTime.now()}', '${DateTime.now()}'),
        (15, "Salary", "work", 5, '', null, '${DateTime.now()}', '${DateTime.now()}');
    ''');

    // Add currencies
    await _database?.execute('''
      INSERT INTO currency(symbol, code, name, mainCurrency) VALUES
        ("€", "EUR", "Euro", 1),
        ("\$", "USD", "United States Dollar", 0),
        ("CHF", "CHF", "Switzerland Franc", 0),
        ("£", "GBP", "United Kingdom Pound", 0);
    ''');

    // Add fake budgets
    await _database?.execute('''
      INSERT INTO budget(idCategory, name, amountLimit, active, createdAt, updatedAt) VALUES
        (13, "Grocery", 400.00, 1, '${DateTime.now()}', '${DateTime.now()}'),
        (11, "Home", 123.45, 0, '${DateTime.now()}', '${DateTime.now()}');
    ''');

    // Add fake transactions
    // First initialize some config stuff
    final rnd = Random();
    var accounts = [70,71,72];
    var outNotes = ['Grocery', 'Tolls', 'Toys', 'Tobacco', 'Concert', 'Clothing', 'Pizza', 'Drugs', 'Laundry', 'Taxes', 'Health insurance', 'Furniture', 'Car Fuel', 'Train', 'Amazon', 'Delivery', 'CHEK dividends', 'Babysitter', 'sono.pove.ro Fees', 'Quingentole trip'];
    var categories = [10,11,12,13,14];
    int countOfGeneratedTransaction = 10000;
    double maxAmountOfSingleTransaction = 250.00;
    int dateInPastMaxRange = (countOfGeneratedTransaction / 90 ).round() * 30; // we want simulate about 90 transactions per month
    num fakeSalary = 5000;
    DateTime now = DateTime.now();

    // start building mega-query
    const insertDemoTransactionsQuery = '''INSERT INTO `transaction` (date, amount, type, note, idCategory, idBankAccount, idBankAccountTransfer, recurring, recurrencyType, recurrencyPayDay, recurrencyFrom, recurrencyTo, createdAt, updatedAt) VALUES ''';

    // init a List with transaction values
    final List<String> demoTransactions = [];

    // Start a loop
    for (int i = 0; i < countOfGeneratedTransaction; i++) {
      num randomAmount = 0;

      // we are more likely to give low amounts
      if (rnd.nextInt(10) < 8) {
        randomAmount = rnd.nextDouble() * (19.99 - 1) + 1;
      } else {
        randomAmount = rnd.nextDouble() * (maxAmountOfSingleTransaction - 100) + 100;
      }

      var randomType = 'OUT';
      var randomAccount = accounts[rnd.nextInt(accounts.length)];
      var randomNote = outNotes[rnd.nextInt(outNotes.length)];
      var randomCategory = categories[rnd.nextInt(categories.length)];
      var idBankAccountTransfer;
      DateTime randomDate =  now.subtract(Duration(days: rnd.nextInt(dateInPastMaxRange), hours: rnd.nextInt(20), minutes: rnd.nextInt(50)));

      if (i % (countOfGeneratedTransaction/100) == 0) {
        // simulating a transfer every 1% of total iterations
        randomType = 'TRSF';
        randomNote = 'Transfer';
        randomAccount = 70; // sender account is hardcoded with the one that receives our fake salary
        idBankAccountTransfer = accounts[rnd.nextInt(accounts.length)];
        randomAmount = (fakeSalary/100)*70;

        // be sure our FROM/TO accounts are not the same
        while (idBankAccountTransfer == randomAccount) {
          idBankAccountTransfer = accounts[rnd.nextInt(accounts.length)];
        }
      }

      // put generated transaction in our list
      demoTransactions.add('''('$randomDate', ${randomAmount.toStringAsFixed(2)}, '$randomType', '$randomNote', $randomCategory, $randomAccount, $idBankAccountTransfer, 0, null, null, null, null, '$randomDate', '$randomDate')''');
    }

    // add salary every month
    for (int i = 1; i < dateInPastMaxRange/30; i++) {
      DateTime randomDate =  now.subtract(Duration(days: 30*i));
      var time = randomDate.toLocal();
      DateTime salaryDateTime = DateTime(time.year, time.month, 27, time.hour, time.minute, time.second, time.millisecond, time.microsecond);
      demoTransactions.add('''('$salaryDateTime', $fakeSalary, 'IN', 'Salary', 15, 70, null, 0, null, null, null, null, '$salaryDateTime', '$salaryDateTime')''');
    }

    // add some recurring payment too
    demoTransactions.add('''(null, 7.99, 'OUT', 'Netflix', 14, 71, null, 1, 'monthly', 19, '2022-11-14', null, '2022-11-14 03:33:36.048611', '2022-11-14 03:33:36.048611')''');
    demoTransactions.add('''(null, 292.39, 'OUT', 'Car Loan', 13, 70, null, 1, 'monthly', 27, '2019-10-03', '2024-10-02', '2022-10-04 03:33:36.048611', '2022-10-04 03:33:36.048611')''');

    // finalize query and write!
    await _database?.execute("$insertDemoTransactionsQuery ${demoTransactions.join(",")};");
  }

  Future clearDatabase() async {
    try{
      await _database?.transaction((txn) async {
        var batch = txn.batch();
        batch.delete(bankAccountTable);
        batch.delete(transactionTable);
        batch.delete(recurringTransactionAmountTable);
        batch.delete(categoryTransactionTable);
        batch.delete(budgetTable);
        batch.delete(currencyTable);
        await batch.commit();
      });
    } catch(error){
      throw Exception('DbBase.cleanDatabase: $error');
    }
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
