import 'dart:io';
import 'dart:math'; // used for random number generation in demo data
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sql;

// Models
import '../../constants/constants.dart';
import '../../model/bank_account.dart';
import '../../model/budget.dart';
import '../../model/category_transaction.dart';
import '../../model/currency.dart';
import '../../model/recurring_transaction.dart';
import '../../model/transaction.dart';
import 'migration_manager.dart';
import 'money_manager_objects.dart';
part 'sossoldi_database.g.dart';


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
        dev.log('Error exporting table $tableName: $e');
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
        throw Exception('CSV file not found');
      }

      final String csvData = await file.readAsString();
      final List<List<dynamic>> rows = const CsvToListConverter().convert(
        csvData,
      );

      if (rows.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // First row contains headers
      final List<String> headers = rows.first.map((e) => e.toString()).toList();
      final int tableNameIndex = headers.indexOf('table_name');

      if (tableNameIndex == -1) {
        throw Exception('CSV file missing table_name column');
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
            dev.log('Error importing table $tableName: $e');
            results[tableName] = false;
          }
        }
      });
    } catch (e) {
      dev.log('Error during import: $e');
      rethrow;
    }

    return results;
  }

  Future insertTransactionFromMoneyManager( {required sql.Transaction txn,required MMTransaction transaction}) async {
    Map<String, dynamic> row = {};
    String currentDate = transaction.date.toIso8601String();
    String code = transaction.type.code;
    if(transaction.account == -1)
    {
      return;
    }

    switch(transaction.type)
    {
      case TransactionType.income:
      case TransactionType.expense:
        if(transaction.category == -1)
        {
          return;
        }

        row = {
          TransactionFields.date: currentDate,
          TransactionFields.amount: transaction.amount,
          TransactionFields.type: code,
          TransactionFields.note: transaction.description,
          TransactionFields.idCategory: transaction.category,
          TransactionFields.idBankAccount: transaction.account,
          TransactionFields.recurring: 0,
          TransactionFields.idRecurringTransaction: null,
          TransactionFields.createdAt: currentDate,
          TransactionFields.updatedAt: DateTime.now().toIso8601String(),
        };
        break;
      case TransactionType.transfer:
        if(transaction.destinationAccount == null)
        {
          return;
        }
        row = {
          TransactionFields.date : currentDate,
          TransactionFields.amount : transaction.amount,
          TransactionFields.type: code,
          TransactionFields.note: transaction.description,
          TransactionFields.idBankAccount: transaction.account,
          TransactionFields.idBankAccountTransfer : transaction.destinationAccount,
          TransactionFields.recurring: 0,
          TransactionFields.idRecurringTransaction: null,
          TransactionFields.createdAt: currentDate,
          TransactionFields.updatedAt: DateTime.now().toIso8601String(),
        };
        break;
    }
    txn.insert(transactionTable, row);

  }

  Future<int?> insertCategoryFromMoneyManager({required sql.Transaction txn, required MMCategory category, required String code}) async
  {
    List<Map<String, dynamic>> maps = await txn.query(
      categoryTransactionTable,
      columns: [CategoryTransactionFields.name],
      where: '${CategoryTransactionFields.type} = ?',
      whereArgs: [code],
    );

    List<String> currentCategories = maps.map((
        row) => row[CategoryTransactionFields.name] as String).toList();


    int randomColor = Random().nextInt(categoryColorList.length);
    String randomIcon = householdIconList.keys.elementAt(
        Random().nextInt(householdIconList.length));

    if (currentCategories.contains(category.name)) {
      return null;
    }

    Map<String, dynamic> row = {
      CategoryTransactionFields.name: category.name,
      CategoryTransactionFields.type: code,
      CategoryTransactionFields.symbol: randomIcon,
      CategoryTransactionFields.color: randomColor,
      CategoryTransactionFields.createdAt: category.cUTime.toIso8601String(),
      CategoryTransactionFields.updatedAt: category.cUTime.toIso8601String(),
    };
    return await txn.insert(categoryTransactionTable, row);
  }

  Future<int?> insertSubCategoryFromMoneyManager({required sql.Transaction txn, required MMCategory sub, required String code, required int parent}) async
  {
    List<Map<String, dynamic>> maps = await txn.query(
      categoryTransactionTable,
      columns: [CategoryTransactionFields.name],
      where: '${CategoryTransactionFields.parent} = ?',
      whereArgs: [parent],
    );

    List<String> currentCategories = maps.map((
        row) => row[CategoryTransactionFields.name] as String).toList();


    int randomColor = Random().nextInt(categoryColorList.length);
    String randomIcon = householdIconList.keys.elementAt(
        Random().nextInt(householdIconList.length));

    if (currentCategories.contains(sub.name)) {
      return null;
    }

    Map<String, dynamic> row = {
      CategoryTransactionFields.name: sub.name,
      CategoryTransactionFields.type: code,
      CategoryTransactionFields.symbol: randomIcon,
      CategoryTransactionFields.color: randomColor,
      CategoryTransactionFields.createdAt: sub.cUTime.toIso8601String(),
      CategoryTransactionFields.updatedAt: sub.cUTime.toIso8601String(),
      CategoryTransactionFields.parent : parent
    };
    return await txn.insert(categoryTransactionTable, row);
  }

  Future<Map<String, int>> insertCategoriesFromMoneyManager({required sql.Transaction txn, required Map<MMCategory,List<MMCategory>> categoryMap, required String code}) async
  {
    Map<String, int> ret = {};
    List<Map<String, dynamic>> maps  = await txn.query(
      categoryTransactionTable,
      columns: [CategoryTransactionFields.name],
      where: '${CategoryTransactionFields.type} = ?',
      whereArgs: [code],
    );

    List<String> currentCategories = maps.map((row) => row[CategoryTransactionFields.name] as String).toList();
    for (var entry in categoryMap.entries) {
      var c = entry.key;
      List<MMCategory> list = entry.value;


      int randomColor = Random().nextInt(categoryColorList.length);
      String randomIcon = householdIconList.keys.elementAt(Random().nextInt(householdIconList.length));
      if(currentCategories.contains(c.name))
      {
        continue;
      }

      Map<String, dynamic> row = {
        CategoryTransactionFields.name: c.name,
        CategoryTransactionFields.type: code,
        CategoryTransactionFields.symbol:randomIcon ,
        CategoryTransactionFields.color:  randomColor,
        CategoryTransactionFields.createdAt: c.cUTime.toIso8601String(),
        CategoryTransactionFields.updatedAt: c.cUTime.toIso8601String(),
      };
      int newId = await txn.insert(categoryTransactionTable, row);
      ret[c.textUid] = newId;
      if(list.isEmpty) {
        continue;
      }

      for(var subCategory in list)
      {
        Map<String, dynamic> row = {
          CategoryTransactionFields.name: subCategory.name,
          CategoryTransactionFields.type: code,
          CategoryTransactionFields.symbol: randomIcon,
          CategoryTransactionFields.color:  randomColor,
          CategoryTransactionFields.parent : newId,
          CategoryTransactionFields.createdAt: subCategory.cUTime.toIso8601String(),
          CategoryTransactionFields.updatedAt: subCategory.cUTime.toIso8601String(),
        };
        int subUid =
        await txn.insert(categoryTransactionTable, row);
        ret[subCategory.textUid] =subUid;
      }
    }
    return ret;
  }


  // I consider being called in a try catch
  Future<bool> importDBFromMoneyManager(String filePath) async {
    await resetDatabase();

    final myDb = await database;


    final file = File(filePath);

    try {
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      Database mmDb = await openDatabase(
        filePath,
        readOnly: false,
        singleInstance: true,
      );

      List<Map<String,dynamic>> list = await mmDb.rawQuery('SELECT uid,A_UTIME,NIC_NAME, ZDATA2  FROM ASSETS');
      List<MMAccount> accountsList = list.map((map) => MMAccount.fromMap(map)).toList();
      // Fetching the categories
      List<Map<String, dynamic>> rawOutCategories = await mmDb.query(
        MMCategory.tableName,
        columns: [
          MMCategory.uidColumn,
          MMCategory.creationTimeColumn,
          MMCategory.textUidColumn,
          MMCategory.parentUidColumn,
          MMCategory.nameColumn,
        ],
        where: '${MMCategory.typeColumn} = ?',
        whereArgs: [1],
      );

      List<Map<String, dynamic>> rawInCategories = await mmDb.query(
        MMCategory.tableName,
        columns: [
          MMCategory.uidColumn,
          MMCategory.creationTimeColumn,
          MMCategory.textUidColumn,
          MMCategory.parentUidColumn,
          MMCategory.nameColumn,
        ],
        where: '${MMCategory.typeColumn} = ?',
        whereArgs: [0],
      );
      List<MMCategory> categoryInList = rawInCategories
          .map((map) => MMCategory.fromMap(map))
          .toList();

      List<MMCategory> categoryOutList = rawOutCategories
          .map((map) => MMCategory.fromMap(map))
          .toList();

      List<Map<String, dynamic>> rawCurrencies = await mmDb.query(
        MMCurrency.tableName,
        columns: [
          MMCurrency.uidColumn,
          MMCurrency.nameColumn,
          MMCurrency.treeLetterCodeColumn,
          MMCurrency.symbolColumn,
          MMCurrency.mainCurrencyColumn,
        ],
      );

      List<MMCurrency> currencyList = rawCurrencies
          .map((map) => MMCurrency.fromMap(map))
          .toList();

      Map<String, String> currencyUidToIso = {};

      for (var entry in rawCurrencies) {
        currencyUidToIso[entry[MMCurrency.uidColumn]!] = entry[MMCurrency.treeLetterCodeColumn]!;
      }

      Map<MMCategory, List<MMCategory>> expenseCategories = {};
      Map<MMCategory, List<MMCategory>> incomeCategories = {};

      void populateCategories(Map<MMCategory, List<MMCategory>>  map,List<MMCategory> list) {
        List<MMCategory> subs = [];
        for (var cat in list) {
          if(cat.parent == null || (cat.parent != null && cat.parent  == '0'))
          {
            map[cat] = [];
          }
          else {
            subs.add(cat);
          }
        }

        map.forEach((MMCategory cat, List<MMCategory> list)
        {
          for (var subCat in subs) {
            if(subCat.parent == cat.textUid)
            {
              list.add(subCat);
            }
          }
        });
      }
      populateCategories(expenseCategories, categoryOutList);
      populateCategories(incomeCategories, categoryInList);

      List<Map<String, dynamic>> maps = await myDb.query(
        bankAccountTable,
        columns: [BankAccountFields.name],
      );

      List<String> currentAccounts = List.generate(maps.length, (i) {
        return maps[i][BankAccountFields.name] as String;
      });

      Map<String, int> mmUidToAccountID = {};

      List<Map<String, dynamic>> rawTxns = await mmDb.query(
          MMTransaction.tableName,
          columns: [MMTransaction.groupIdColumn, MMTransaction.destinationGroupIdColumn, MMTransaction.categoryIdColumn, MMTransaction.destinationGroupIdColumn, MMTransaction.dateColumn, MMTransaction.amountColumn, MMTransaction.typeColumn, MMTransaction.currencyIdColumn ]);

      await myDb.transaction((txn) async {


        for (var a in accountsList) {
          if (!currentAccounts.contains(a.accountGroupName)) {
            Map<String, dynamic> row = {
              BankAccountFields.name: a.accountGroupName,
              BankAccountFields.symbol: accountIconList.keys.elementAt(
                  Random().nextInt(accountIconList.length)),
              BankAccountFields.color: Random().nextInt(
                  accountColorList.length),
              BankAccountFields.startingValue: 0.0,
              BankAccountFields.active: 1,
              BankAccountFields.countNetWorth: a.countInNet,
              BankAccountFields.mainAccount: 0,
              BankAccountFields.createdAt: a.useTime.toIso8601String(),
              BankAccountFields.updatedAt: a.useTime.toIso8601String(),
            };
            int newId = await txn.insert(bankAccountTable, row);
            mmUidToAccountID[a.uuid] = newId;
          }
        }

        Map<String, int> mmUidToIdIncomes = await insertCategoriesFromMoneyManager(txn: txn, categoryMap: incomeCategories, code: 'IN');
        Map<String, int> mmUidToIdExpense = await insertCategoriesFromMoneyManager(txn: txn, categoryMap: expenseCategories, code: 'OUT');

        List<Map<String, dynamic>> maps = await txn.query(
          currencyTable,
          columns: [CurrencyFields.code],
        );

        List<String> currentCurrencies = maps.map((row) => row[CurrencyFields.code] as String).toList();

        for(var c in currencyList) {
          if (currentCurrencies.contains(c.iso)) {
            continue;
          }
          Map<String, dynamic> row = {

            CurrencyFields.symbol: c.symbol,
            CurrencyFields.code: c.iso,
            CurrencyFields.name: c.name,
            CurrencyFields.mainCurrency: (c.mainCurrency ? 1: 0),
          };

          txn.insert(
            currencyTable,
            row,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );

        }

        Map<String, dynamic> row = {
          CategoryTransactionFields.name: 'Modified balance',
          CategoryTransactionFields.type: 'IN',
          CategoryTransactionFields.symbol: 'balance',
          CategoryTransactionFields.color:  0,
          CategoryTransactionFields.updatedAt: DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String(),
          CategoryTransactionFields.createdAt: DateTime.fromMicrosecondsSinceEpoch(0).toIso8601String(),
        };

        int inMod = await txn.insert(categoryTransactionTable, row);
        row[CategoryTransactionFields.type] = 'OUT';
        int outMod = await txn.insert(categoryTransactionTable, row);

        List<MMTransaction> transactions = rawTxns.map((m) => MMTransaction.fromMap(m,mmUidToAccountID,mmUidToIdIncomes,mmUidToIdExpense,currencyUidToIso, inMod,outMod)).toList();

        for(var tr in transactions)
        {
          await insertTransactionFromMoneyManager(txn: txn, transaction: tr);
        }
      });



      return true;


    } catch (e) {
      throw Exception('Failed to load database');
    }
  }

  String sanitizeAlphaNumeric(String text) {
    return text
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<int?> getBankAccountId({required sql.Transaction txn, required String name}) async {
    final List<Map<String, dynamic>> maps = await txn.rawQuery(
      'SELECT id FROM $bankAccountTable WHERE name = ? LIMIT 1',
      [name],
    );

    if (maps.isEmpty) {
      return null;
    }

    return maps.first['id'] as int;
  }

  DateTime? parseFlexibleDate(String dateString) {
    // List your potential formats in order of preference
    List<String> formats = [
      "MM/dd/yyyy HH:mm:ss",
      "MM/dd/yy HH:mm:ss",
      "MM/dd/yy HH:mm",
    ];

    for (String format in formats) {
      try {
        return DateFormat(format).parseStrict(dateString);
      } catch (e) {
        // Move to the next format if this one fails
        continue;
      }
    }

    // Return null if none of the formats worked
    return null;
  }

  // I consider being called in a try catch
  Future<bool> importFromCsvFromMoneyManager(String csvFilePath) async {

    await resetDatabase();

    final db = await database;

    try {
      final file = File(csvFilePath);

      if (!await file.exists()) {
        throw Exception('CSV file not found');
      }

      final String csvData = await file.readAsString();
      final List<List<dynamic>> rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(
        csvData,
      );

      if (rows.isEmpty) {
        throw Exception('CSV file is empty');
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
          throw Exception('Column $str not found in CSV file');
        }
      }

      // We can discard the headers
      rows.removeAt(0);

      Set<String> currencies = {};

      Map<String, int> uidToAccountID = {};
      Map<String, int> expensesUidToCategoryId = {};
      Map<String, int> incomesUidToCategoryId = {};
      Map<String, int> expensesUidToSubCategoryId = {};
      Map<String, int> incomesUidToSubCategoryId = {};

      List<Map<String, dynamic>> maps = await db.query(
        bankAccountTable,
        columns: [BankAccountFields.name],
      );

      List<String> currentAccounts = List.generate(maps.length, (i) {
        return maps[i][BankAccountFields.name] as String;
      });

      await db.transaction((txn) async {
        for (var row in rows) {
          DateTime? dateTime = parseFlexibleDate(row[0]);

          if(dateTime == null)
          {
            continue;
          }
          String accountName = sanitizeAlphaNumeric(row[1]);

          if (!currentAccounts.contains(accountName)) {
            Map<String, dynamic> row = {
              BankAccountFields.name: accountName,
              BankAccountFields.symbol: accountIconList.keys.elementAt(
                  Random().nextInt(accountIconList.length)),
              BankAccountFields.color: Random().nextInt(
                  accountColorList.length),
              BankAccountFields.startingValue: 0.0,
              BankAccountFields.active: 1,
              BankAccountFields.countNetWorth: true,
              BankAccountFields.mainAccount: 0,
              BankAccountFields.createdAt: dateTime.toIso8601String(),
              BankAccountFields.updatedAt: DateTime.now().toIso8601String(),
            };
            int newId = await txn.insert(bankAccountTable, row);
            uidToAccountID[accountName] = newId;
            // Do not repeat
            currentAccounts.add(accountName);
          }

          TransactionType tt = getCSVTransactionTypeFromName(row[6]);

          String catName = sanitizeAlphaNumeric(row[2]);
          String sub = sanitizeAlphaNumeric(row[3]);

          MMCategory newCategory = MMCategory(id: 0, cUTime: dateTime, textUid: '', name: catName, parent: null);

          switch(tt) {
            case TransactionType.expense:
              int? newId = await insertCategoryFromMoneyManager(txn: txn, category: newCategory, code: 'OUT');

              if(newId == null) {
                break;
              }

              expensesUidToCategoryId[catName] = newId;

              if(sub.isNotEmpty)
              {
                MMCategory subCategory = MMCategory(id: 0, cUTime: dateTime, textUid: '', name: sub, parent: '');
                int? subId = await insertSubCategoryFromMoneyManager(txn: txn, sub: subCategory, code: 'OUT', parent: newId);
                if(subId != null) {
                  expensesUidToSubCategoryId[sub] = subId;
                }
              }

              break;
            case TransactionType.income:
              int? newId = await insertCategoryFromMoneyManager(txn: txn, category: newCategory, code: 'IN');

              if(newId == null) {
                break;
              }

              incomesUidToCategoryId[catName] = newId;

              if(sub.isNotEmpty)
              {
                MMCategory subCategory = MMCategory(id: 0, cUTime: dateTime, textUid: '', name: sub, parent: '');
                int? subId = await insertSubCategoryFromMoneyManager(txn: txn, sub: subCategory, code: 'IN', parent: newId);
                if(subId != null) {
                  incomesUidToSubCategoryId[sub] = subId;
                }
              }
              break;
            case TransactionType.transfer:
              if (!currentAccounts.contains(catName)) {
                Map<String, dynamic> row = {
                  BankAccountFields.name: catName,
                  BankAccountFields.symbol: accountIconList.keys.elementAt(
                      Random().nextInt(accountIconList.length)),
                  BankAccountFields.color: Random().nextInt(
                      accountColorList.length),
                  BankAccountFields.startingValue: 0.0,
                  BankAccountFields.active: 1,
                  BankAccountFields.countNetWorth: true,
                  BankAccountFields.mainAccount: 0,
                  BankAccountFields.createdAt: dateTime.toIso8601String(),
                  BankAccountFields.updatedAt: DateTime.now().toIso8601String(),
                };
                int newId = await txn.insert(bankAccountTable, row);
                uidToAccountID[catName] = newId;
                // Do not repeat
                currentAccounts.add(catName);
              }

              break;
          }
          currencies.add(row[9]);
        }


      List<MMTransaction> transactions = [];

      for(var row in rows)
      {
        TransactionType tt = getCSVTransactionTypeFromName(row[6]);
        DateTime? dateTime = parseFlexibleDate(row[0]);
        double money = double.parse(row[8]);

        if(dateTime == null)
        {
          continue;
        }
        int? accountUid = uidToAccountID[sanitizeAlphaNumeric(row[1])];
        String cat = sanitizeAlphaNumeric(row[2]);
        String sub = sanitizeAlphaNumeric(row[3]);

        switch(tt) {
          case TransactionType.expense:
            if (!expensesUidToCategoryId.containsKey(cat)) {
              break;
            }

            int? categoryId = expensesUidToCategoryId[cat];

            if (expensesUidToSubCategoryId.containsKey(sub)) {
              categoryId = expensesUidToSubCategoryId[sub];
            }

            transactions.add(MMTransaction.expense(date: dateTime, account: accountUid!,category : categoryId, amount: money, currency: row[9],sub: sub,note: row[4], description: row[7]));
            break;

          case TransactionType.income:
            if (!incomesUidToCategoryId.containsKey(cat)) {
              break;
            }

            int? categoryId = incomesUidToCategoryId[cat];

            if (incomesUidToSubCategoryId.containsKey(sub)) {
              categoryId = incomesUidToSubCategoryId[sub];
            }

            transactions.add(MMTransaction.income(date: dateTime, account: accountUid!,category : categoryId, amount: money, currency: row[9],sub: sub,note: row[4], description: row[7]));
            break;

          case TransactionType.transfer:
            transactions.add(MMTransaction.transfer(date: dateTime, account: accountUid!, dAccount: uidToAccountID[cat]!,  amount: money, currency: row[9],note: row[4], description: row[7]));
            break;
        }
      }
      for(var tr in transactions)
      {
        await insertTransactionFromMoneyManager(txn: txn, transaction: tr);
      }

      });

      return true;

    } catch (e) {
      dev.log('Error during import: $e');
      rethrow;
    }
  }

  Future<void> exportDatabase() async {

    String dbPath = await getDatabasesPath();
    String path = join(dbPath, dbName);

    Uint8List bytes = await File(path).readAsBytes();
    await FilePicker.platform.saveFile(
      dialogTitle: 'Salva backup database',
      fileName: 'backup.db',
      bytes: bytes
    );

  }

  Future<void> importDatabase() async {
    final db = await database;

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    db.close();

    if (result != null) {
      File sourceFile = File(result.files.single.path!);

      String dbPath = await getDatabasesPath();
      String destPath = join(dbPath, dbName);


      await sourceFile.copy(destPath);

      _database = await openDatabase(destPath);

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
