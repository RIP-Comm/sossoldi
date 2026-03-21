import 'dart:math'; // used for random number generation in demo data
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sql;

// Models
import '../../model/bank_account.dart';
import '../../model/budget.dart';
import '../../model/category_transaction.dart';
import '../../model/currency.dart';
import '../../model/recurring_transaction.dart';
import '../../model/transaction.dart';

import 'migration_manager.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../../constants/constants.dart';
import 'money_manager_objects.dart';
part 'sossoldi_database.g.dart';
part 'database_backup_controller.dart';

@Riverpod(keepAlive: true)
SossoldiDatabase database(Ref ref) => SossoldiDatabase.instance;

class SossoldiDatabase {
  static final SossoldiDatabase instance = SossoldiDatabase._init();
  final MigrationManager _migrationManager = MigrationManager();
  static Database? _database;
  static String dbName = 'sossoldi.db';

  // Zero args constructor needed to extend this class
  SossoldiDatabase({String? dbName}) {
    dbName = dbName ?? 'sossoldi.db';
  }

  SossoldiDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, filePath);
    return await openDatabase(
      path,
      version: _migrationManager.latestVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  static Future _createDB(Database database, int version) async {
    // Use the migration manager to apply all migrations from version 0
    // This will run the InitialSchema migration (version 1) first
    await instance._migrationManager.migrate(database, 0, version);
  }

  static Future _upgradeDB(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    await instance._migrationManager.migrate(database, oldVersion, newVersion);
  }

  Future fillDemoData({int countOfGeneratedTransaction = 10000}) async {
    // Add fake accounts
    await _database?.execute('''
      INSERT INTO bankAccount(id, name, symbol, color, startingValue, active, countNetWorth, mainAccount, position, createdAt, updatedAt) VALUES
        (70, 'Revolut', 'payments', 1, 1235.10, 1, 1, 1, 0, '${DateTime.now()}', '${DateTime.now()}'),
        (71, 'N26', 'credit_card', 2, 3823.56, 1, 1, 0, 1, '${DateTime.now()}', '${DateTime.now()}'),
        (72, 'Fineco', 'account_balance', 3, 0.00, 1, 1, 0, 2, '${DateTime.now()}', '${DateTime.now()}');
    ''');

    // Add fake categories and subcategories
    await _database?.execute('''
      INSERT INTO categoryTransaction(id, name, type, symbol, color, note, parent, position, createdAt, updatedAt) VALUES
        (10, 'Out', 'OUT', 'restaurant', 0, '', null, 0, '${DateTime.now()}', '${DateTime.now()}'),
        (11, 'Home', 'OUT', 'home', 1, '', null, 1, '${DateTime.now()}', '${DateTime.now()}'),
        (12, 'Furniture','OUT', 'home', 1, '', 11, 2, '${DateTime.now()}', '${DateTime.now()}'),
        (13, 'Shopping', 'OUT', 'shopping_cart', 3, '', null, 3, '${DateTime.now()}', '${DateTime.now()}'),
        (14, 'Leisure', 'OUT', 'subscriptions', 4, '', null, 4, '${DateTime.now()}', '${DateTime.now()}'),
        (15, 'Transports', 'OUT', 'directions_car', 6, '', null, 5, '${DateTime.now()}', '${DateTime.now()}'),
        (16, 'Salary', 'IN', 'work', 5, '', null, 6, '${DateTime.now()}', '${DateTime.now()}');
    ''');

    // Add currencies
    await _database?.execute('''
      INSERT INTO currency(symbol, code, name, mainCurrency) VALUES
        ('€', 'EUR', 'Euro', 1),
        ('\$', 'USD', 'United States Dollar', 0),
        ('CHF', 'CHF', 'Switzerland Franc', 0),
        ('£', 'GBP', 'United Kingdom Pound', 0);
    ''');

    // Add fake budgets
    await _database?.execute('''
      INSERT INTO budget(idCategory, name, amountLimit, active, createdAt, updatedAt) VALUES
        (13, 'Grocery', 900.00, 1, '${DateTime.now()}', '${DateTime.now()}'),
        (11, 'Home', 123.45, 0, '${DateTime.now()}', '${DateTime.now()}');
    ''');

    // Add fake recurring transactions
    await _database?.execute('''
      INSERT INTO recurringTransaction(fromDate, toDate, amount, type, note, recurrency, idCategory, idBankAccount, createdAt, updatedAt) VALUES
        ('2024-02-23', null, 10.99, 'OUT', '404 Books', 'MONTHLY', 14, 70, '${DateTime.now()}', '${DateTime.now()}'),
        ('2023-12-13', null, 4.97, 'OUT', 'ETF Consultant Parcel', 'DAILY', 14, 70, '${DateTime.now()}', '${DateTime.now()}'),
        ('2023-02-11', '2028-02-11', 1193.40, 'OUT', 'Car Loan', 'QUARTERLY', 15, 72, '${DateTime.now()}', '${DateTime.now()}');
    ''');

    // Add fake transactions
    // First initialize some config stuff
    final rnd = Random();
    var accounts = [70, 71, 72];
    var outNotes = [
      'Grocery',
      'Tolls',
      'Toys',
      'Boardgames',
      'Concert',
      'Clothing',
      'Pizza',
      'Drugs',
      'Laundry',
      'Taxes',
      'Health insurance',
      'Furniture',
      'Car Fuel',
      'Train',
      'Amazon',
      'Delivery',
      'CHEK dividends',
      'Babysitter',
      'sono.pove.ro Fees',
      'Quingentole trip',
    ];
    var categories = [10, 11, 12, 13, 14];
    double maxAmountOfSingleTransaction = 250.00;
    int dateInPastMaxRange =
        (countOfGeneratedTransaction / 90).round() *
        30; // we want simulate about 90 transactions per month
    num fakeSalary = 5000;
    DateTime now = DateTime.now();

    // start building mega-query
    const insertDemoTransactionsQuery =
        '''INSERT INTO `transaction` (date, amount, type, note, idCategory, idBankAccount, idBankAccountTransfer, recurring, idRecurringTransaction, createdAt, updatedAt) VALUES ''';

    // init a List with transaction values
    final List<String> demoTransactions = [];

    // Start a loop
    for (int i = 0; i < countOfGeneratedTransaction; i++) {
      num randomAmount = 0;

      // we are more likely to give low amounts
      if (rnd.nextInt(10) < 8) {
        randomAmount = rnd.nextDouble() * (19.99 - 1) + 1;
      } else {
        randomAmount =
            rnd.nextDouble() * (maxAmountOfSingleTransaction - 100) + 100;
      }

      var randomType = 'OUT';
      var randomAccount = accounts[rnd.nextInt(accounts.length)];
      var randomNote = outNotes[rnd.nextInt(outNotes.length)];
      int? randomCategory = categories[rnd.nextInt(categories.length)];
      int? idBankAccountTransfer;
      DateTime randomDate = now.subtract(
        Duration(
          days: rnd.nextInt(dateInPastMaxRange),
          hours: rnd.nextInt(20),
          minutes: rnd.nextInt(50),
        ),
      );

      if (i % (countOfGeneratedTransaction / 100) == 0) {
        // simulating a transfer every 1% of total iterations
        randomType = 'TRSF';
        randomNote = 'Transfer';
        randomAccount =
            70; // sender account is hardcoded with the one that receives our fake salary
        randomCategory = null; // transfers have no category
        idBankAccountTransfer = accounts[rnd.nextInt(accounts.length)];
        randomAmount = (fakeSalary / 100) * 70;

        // be sure our FROM/TO accounts are not the same
        while (idBankAccountTransfer == randomAccount) {
          idBankAccountTransfer = accounts[rnd.nextInt(accounts.length)];
        }
      }

      // put generated transaction in our list
      demoTransactions.add(
        '''('$randomDate', ${randomAmount.toStringAsFixed(2)}, '$randomType', '$randomNote', $randomCategory, $randomAccount, $idBankAccountTransfer, 0, null, '$randomDate', '$randomDate')''',
      );
    }

    // add salary every month
    for (int i = 1; i < dateInPastMaxRange / 30; i++) {
      DateTime randomDate = now.subtract(Duration(days: 30 * i));
      var time = randomDate.toLocal();
      DateTime salaryDateTime = DateTime(
        time.year,
        time.month,
        27,
        time.hour,
        time.minute,
        time.second,
        time.millisecond,
        time.microsecond,
      );
      demoTransactions.add(
        '''('$salaryDateTime', $fakeSalary, 'IN', 'Salary', 16, 70, null, 0, null, '$salaryDateTime', '$salaryDateTime')''',
      );
    }

    // finalize query and write!
    await _database?.execute(
      "$insertDemoTransactionsQuery ${demoTransactions.join(",")};",
    );
  }

  Future resetDatabase() async {
    // delete database
    try {
      await _database?.transaction((txn) async {
        var batch = txn.batch();
        // drop tables
        batch.execute('DROP TABLE IF EXISTS $bankAccountTable');
        batch.execute('DROP TABLE IF EXISTS `$transactionTable`');
        batch.execute('DROP TABLE IF EXISTS $recurringTransactionTable');
        batch.execute('DROP TABLE IF EXISTS $categoryTransactionTable');
        batch.execute('DROP TABLE IF EXISTS $budgetTable');
        batch.execute('DROP TABLE IF EXISTS $currencyTable');
        await batch.commit();
      });
    } catch (error) {
      throw Exception('DbBase.resetDatabase: $error');
    }
    await _createDB(_database!, _migrationManager.latestVersion);
  }

  Future clearDatabase() async {
    try {
      await _database?.transaction((txn) async {
        var batch = txn.batch();
        batch.delete(bankAccountTable);
        batch.delete(transactionTable);
        batch.delete(recurringTransactionTable);
        batch.delete(categoryTransactionTable);
        batch.delete(budgetTable);
        batch.delete(currencyTable);
        await batch.commit();
      });
    } catch (error) {
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
    final path = join(databasePath, dbName);
    databaseFactory.deleteDatabase(path);
  }
}
