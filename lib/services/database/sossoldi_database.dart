import 'dart:io';
import 'dart:math'; // used for random number generation in demo data
import 'dart:developer' as dev;

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

// Models
import '../../constants/constants.dart';
import '../../constants/exceptions.dart';
import '../../model/bank_account.dart';
import '../../model/budget.dart';
import '../../model/category_transaction.dart';
import '../../model/currency.dart';
import '../../model/recurring_transaction.dart';
import '../../model/transaction.dart';
import 'migration_manager.dart';

part 'sossoldi_database.g.dart';



TransactionType? translateTransactionType(String tt)
{
  switch(tt)
      {
    case 'Income':
          return TransactionType.income;
    case 'Expense':
          return TransactionType.expense;
    case 'Transfer-Out':
          return TransactionType.transfer;
    default:
      return null;
  }
}

class MoneyManagerTransaction {
  final DateTime date;
  final String account;
  // In case of transfer
  final String? destinationAccount;
  // Could be also an account fi the type is transaction
  final String category;
  final String? subCategory;
  String? description;
  // Still Don't know the difference between description and note
  String? note;
  String currency;
  final double amount;

  final TransactionType type; // Income o Expense or transaction

  MoneyManagerTransaction({required this.date, required this.account, required this.category, required this.amount, required this.type,required this.currency, this.destinationAccount, this.subCategory, this.description, this.note});
  factory MoneyManagerTransaction.transfer({required DateTime date, required String account, required String dAccount, required amount,required currency, description,note})
  {
    return MoneyManagerTransaction(date: date, account: account,  category: '', amount: amount, type: TransactionType.transfer,currency: currency, destinationAccount : dAccount, description: description, note: note );
  }

  factory MoneyManagerTransaction.income({required DateTime date, required String account, required category, required amount,required currency,sub,description,note})
  {
    return MoneyManagerTransaction(date: date, account: account,  category: category, amount: amount, type: TransactionType.income,currency: currency ,subCategory: sub, description: description, note: note );
  }

  factory MoneyManagerTransaction.expense({required DateTime date, required String account, required category, required amount,required currency,sub,description,note})
  {
    return MoneyManagerTransaction(date: date, account: account,  category: category, amount: amount, type: TransactionType.expense,currency: currency, subCategory: sub , description: description, note: note );
  }

  factory MoneyManagerTransaction.invalid()
  {
    return MoneyManagerTransaction(date: DateTime.now(), account: 'Invalid',  category: 'Invalid', amount: 0.0, type: TransactionType.expense,currency: 'ZWD');
  }


}

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

  Future<String> exportToCSV() async {
    final db = await database;
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final String csvDir = join(documentsDir.path, 'sossoldi_exports');

    // Create exports directory if it doesn't exist
    await Directory(csvDir).create(recursive: true);

    // Get all table names
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
    );

    List<List<dynamic>> allData = [];
    Set<String> allColumns = {'table_name'}; // Start with table_name column

    // First pass: collect all unique columns
    for (var table in tables) {
      final String tableName = table['name'] as String;
      final List<Map<String, dynamic>> rows = await db.query(tableName);
      if (rows.isNotEmpty) {
        allColumns.addAll(rows.first.keys);
      }
    }

    // Create header row
    List<String> headers = allColumns.toList();
    allData.add(headers);

    // Second pass: add data from all tables
    for (var table in tables) {
      final String tableName = table['name'] as String;
      try {
        final List<Map<String, dynamic>> rows = await db.query(tableName);

        for (var row in rows) {
          List<dynamic> csvRow = List.filled(
            headers.length,
            '',
          ); // Initialize with empty strings
          csvRow[0] = tableName; // Set table name

          // Fill in values for existing columns
          row.forEach((col, value) {
            final int index = headers.indexOf(col);
            if (index != -1) {
              csvRow[index] = value?.toString() ?? '';
            }
          });

          allData.add(csvRow);
        }
      } catch (e) {
        throw CsvExportingErrorException(tableName: '$tableName with error: $e');
      }
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(allData);

    return csv;
  }

  Future<Map<String, bool>> importFromCSV(String csvFilePath) async {
    final db = await database;
    Map<String, bool> results = {};

    try {
      final file = File(csvFilePath);
      if (!await file.exists()) {
        throw CsvNotFoundException();
      }

      final String csvData = await file.readAsString();
      final List<List<dynamic>> rows = const CsvToListConverter().convert(
        csvData,
      );

      if (rows.isEmpty) {
        throw CsvEmptyException();
      }

      // First row contains headers
      final List<String> headers = rows.first.map((e) => e.toString()).toList();
      final int tableNameIndex = headers.indexOf('table_name');

      if (tableNameIndex == -1) {
        throw CsvExpectedColumnException(column: 'table_column');
      }

      // Group rows by table
      Map<String, List<List<dynamic>>> tableData = {};
      for (int i = 1; i < rows.length; i++) {
        final String tableName = rows[i][tableNameIndex].toString();
        tableData.putIfAbsent(tableName, () => [headers]);
        tableData[tableName]!.add(rows[i]);
      }

      // Import each table's data
      await db.transaction((txn) async {
        for (var entry in tableData.entries) {
          final String tableName = entry.key;
          final List<List<dynamic>> tableRows = entry.value;

          try {
            // Clear existing data
            await txn.delete(tableName);

            // Insert new data
            for (int i = 1; i < tableRows.length; i++) {
              final Map<String, dynamic> row = {};
              for (int j = 0; j < headers.length; j++) {
                if (j != tableNameIndex) {
                  // Skip the table_name column
                  final String header = headers[j];
                  final dynamic value = tableRows[i][j];

                  // Convert empty strings to null
                  if (value != '') {
                    row[header] = value;
                  }
                }
              }
              await txn.insert(tableName, row);
            }
            results[tableName] = true;
          } catch (e) {
            throw CsvImportGeneralErrorException(text : e.toString());
          }
        }
      });
    } catch (e) {
      throw CsvImportGeneralErrorException(text : e.toString());
    }

    return results;
  }

  String sanitizeAlphaNumeric(String text) {
    return text
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<int?> getBankAccountId({required txn, required String name}) async {
    final List<Map<String, dynamic>> maps = await txn.rawQuery(
      'SELECT id FROM bankAccount WHERE name = ? LIMIT 1',
      [name],
    );

    if (maps.isEmpty) {
      return null;
    }

    return maps.first['id'] as int;
  }

  Future<int?> getCategoryId( {required txn,required String name,required String type}) async {
    String query = 'SELECT id FROM categoryTransaction WHERE name = ?';
    List<dynamic> args = [name];

    query += ' AND type = ?';
    args.add(type);


    query += ' LIMIT 1';

    final List<Map<String, dynamic>> maps = await txn.rawQuery(query, args);

    if (maps.isEmpty) {
      return null;
    }

    return maps.first['id'] as int;
  }

  Future insertTransactionFromMoneyManager( {required txn,required MoneyManagerTransaction transaction}) async {
    var backAccountId = await  getBankAccountId(txn: txn, name: transaction.account);
    Map<String, dynamic> row = {};
    String currentDate = transaction.date.toIso8601String();
    String code = transaction.type.code;

    if(backAccountId == null)
    {
      throw CsvTransactionImportErrorException(date: currentDate);
    }

    switch(transaction.type)
    {
      case TransactionType.income:
      case TransactionType.expense:
        var categoryId =  await getCategoryId(txn: txn, type: code, name: transaction.category);
        if(categoryId == null)
        {
          throw CsvTransactionImportErrorException(date: currentDate);
        }
        row = {
          TransactionFields.date: currentDate,
          TransactionFields.amount: transaction.amount,
          TransactionFields.type: code,
          TransactionFields.note: transaction.description,
          TransactionFields.idCategory: categoryId,
          TransactionFields.idBankAccount: backAccountId,
          TransactionFields.recurring: 0,
          TransactionFields.idRecurringTransaction: null,
          TransactionFields.createdAt: currentDate,
          TransactionFields.updatedAt: DateTime.now().toIso8601String(),
        };
        break;
      case TransactionType.transfer:
        var backAccountReceiverId = await getBankAccountId(txn: txn, name: transaction.destinationAccount!);
        if(backAccountReceiverId == null)
        {
          throw CsvTransactionImportErrorException(date: currentDate);
        }
        row = {
          TransactionFields.date : currentDate,
          TransactionFields.amount : transaction.amount,
          TransactionFields.type: code,
          TransactionFields.note: transaction.description,
          TransactionFields.idBankAccount: backAccountId,
          TransactionFields.idBankAccountTransfer : backAccountReceiverId,
          TransactionFields.recurring: 0,
          TransactionFields.idRecurringTransaction: null,
          TransactionFields.createdAt: currentDate,
          TransactionFields.updatedAt: DateTime.now().toIso8601String(),
        };
        break;
    }
    txn.insert('transaction', row);
  }


  Future insertCategoriesFromMoneyManager({required txn, required Map<String,List<String>> categoryMap, required String code, required DateTime oldestDate}) async
  {
    List<Map<String, dynamic>> maps  = await txn.query(
      categoryTransactionTable,
      columns: [CategoryTransactionFields.name],
      where: '${CategoryTransactionFields.type} = ?',
      whereArgs: [code],
    );


    List<String> currentCategories = maps.map((row) => row[CategoryTransactionFields.name] as String).toList();
    for(var c in categoryMap.keys)
    {
      int randomColor = Random().nextInt(categoryColorList.length);
      if(!currentCategories.contains(c))
      {
        Map<String, dynamic> row = {
          CategoryTransactionFields.name: c,
          CategoryTransactionFields.type: code,
          CategoryTransactionFields.symbol: householdIconList.keys.elementAt(Random().nextInt(householdIconList.length)),
          CategoryTransactionFields.color:  randomColor,
          CategoryTransactionFields.createdAt: oldestDate.toIso8601String(),
          CategoryTransactionFields.updatedAt: oldestDate.toIso8601String(),
        };
        txn.insert(categoryTransactionTable, row);
      }

      List<String> subs = categoryMap[c]!;

      if(subs.isEmpty) {
        continue;
      }

      var categoryId = await getCategoryId(txn: txn, name: c, type: code);

      if(categoryId == null)
      {
        continue;
      }

      for(var subCategory in subs)
      {
        Map<String, dynamic> row = {
          CategoryTransactionFields.name: subCategory,
          CategoryTransactionFields.type: code,
          CategoryTransactionFields.symbol: activitiesIconList.keys.elementAt(Random().nextInt(activitiesIconList.length)),
          CategoryTransactionFields.color:  randomColor,
          CategoryTransactionFields.parent : categoryId,
          CategoryTransactionFields.createdAt: oldestDate.toIso8601String(),
          CategoryTransactionFields.updatedAt: oldestDate.toIso8601String(),
        };

        txn.insert(categoryTransactionTable, row);
      }
    }
  }

  // I consider being called in a try catch
  Future<bool> importFromCsvFromMoneyManager(String csvFilePath) async {

    await resetDatabase();

    final db = await database;

    try {
      final file = File(csvFilePath);

      if (!await file.exists()) {
        throw CsvNotFoundException();
      }

      final String csvData = await file.readAsString();
      final List<List<dynamic>> rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(
        csvData,
      );

      if (rows.isEmpty) {
        throw CsvEmptyException();
      }

      // First row contains headers
      final List<String> headers = rows.first.map((e) => e.toString()).toList();

      const List<String> expectedHeaders = [
        'Date',
        'Account',
        'Category',
        'Subcategory',
        'Note',
        // Still need to check how this column works
        // I think it is the default chosen currency in money manager
        // 'EUR',
        'Income/Expense',
        'Description',
        'Amount',
        'Currency',
        'Account'
      ];

      for (var str in expectedHeaders) {
        if(!headers.contains(str)) {
          throw CsvExpectedColumnException(column: str);
        }
      }

      // We can discard the headers
      rows.removeAt(0);

      List<MoneyManagerTransaction> transactions = [];
      Set<String> accounts = {};
      Map<String, List<String>> expenseCategories = {};
      Map<String, List<String>> incomeCategories = {};
      Set<String> currencies = {};
      DateFormat format = DateFormat("MM/dd/yyyy HH:mm:ss");
      DateTime oldest = DateTime.now();

      // First elaboration
      for (var row in rows) {
        DateTime dateTime = format.parse(row[0]);

        if(dateTime.isBefore(oldest))
        {
          oldest = dateTime;
        }
        TransactionType? tt = translateTransactionType(row[6]);
        String account =sanitizeAlphaNumeric(row[1]);
        String cat = sanitizeAlphaNumeric(row[2]);
        String sub = sanitizeAlphaNumeric(row[3]);
        double money = double.parse(row[8]);

        switch(tt) {
          case TransactionType.expense:
            if (!expenseCategories.containsKey(cat)) {
              expenseCategories[cat] = [];
            }

            if (sub.isNotEmpty) {
              expenseCategories[cat]!.add(sub);
            }

            transactions.add(MoneyManagerTransaction.expense(date: dateTime, account: account, category: cat, amount: money, currency: row[9],sub: sub,note: row[4], description: row[7]));
            break;

          case TransactionType.income:
            if (!incomeCategories.containsKey(cat)) {
              incomeCategories[cat] = [];
            }

            if (sub.isNotEmpty) {
              incomeCategories[cat]!.add(sub);
            }

            transactions.add(MoneyManagerTransaction.income(date: dateTime, account: account, category: cat, amount: money, currency: row[9],sub: sub,note: row[4], description: row[7]));
            break;

          case TransactionType.transfer:
            // It is normal in this case the category is the destination account

            transactions.add(MoneyManagerTransaction.transfer(date: dateTime, account: account, dAccount: cat,  amount: money, currency: row[9],note: row[4], description: row[7]));
            accounts.add(cat);
            break;
          default:
            throw CsvUnexpectedValueException(value: row[6]);

        }
        currencies.add(row[9]);
        accounts.add(account);
      }

      List<Map<String, dynamic>> maps = await db.query(
        bankAccountTable,
        columns: [BankAccountFields.name],
      );

      List<String> currentAccounts = List.generate(maps.length, (i) {
        return maps[i][BankAccountFields.name] as String;
      });

      maps = await db.query(
        currencyTable,
        columns: [CurrencyFields.code],
      );

      List<String> currentCurrencies = maps.map((row) => row[CurrencyFields.code] as String).toList();

      await db.transaction((txn) async {
        for(var a in accounts)
        {
          if(!currentAccounts.contains(a))
          {
            Map<String, dynamic> row = {
              BankAccountFields.name : a,
              BankAccountFields.symbol : accountIconList.keys.elementAt(Random().nextInt(accountIconList.length)),
              BankAccountFields.color : Random().nextInt(accountColorList.length),
              BankAccountFields.startingValue : 0.0,
              BankAccountFields.active : 1,
              BankAccountFields.countNetWorth : 1,
              BankAccountFields.mainAccount : 0,
              BankAccountFields.createdAt : oldest.toIso8601String(),
              BankAccountFields.updatedAt : oldest.toIso8601String(),
            };
            txn.insert(bankAccountTable, row);
          }
        }

        insertCategoriesFromMoneyManager(txn: txn, categoryMap: incomeCategories, code: 'IN', oldestDate: oldest);
        insertCategoriesFromMoneyManager(txn: txn, categoryMap: expenseCategories, code: 'OUT', oldestDate: oldest);


        for(var c in currencies) {
          if (!currentCurrencies.contains(c)) {
            Map<String, dynamic> row = {

              CurrencyFields.symbol: c,
              CurrencyFields.code: c,
              CurrencyFields.name: c,
              CurrencyFields.mainCurrency: 0,
            };

            txn.insert(
              currencyTable,
              row,
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }


        for(var transaction in transactions)
        {
          await insertTransactionFromMoneyManager(txn: txn, transaction: transaction);
        }
      });

      return true;

    } catch (e) {
      throw CsvImportGeneralErrorException(text: e.toString());
    }
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
      throw ResetDatabaseException(text: error.toString());
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
      throw CleanDatabaseException(text : error.toString());
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
