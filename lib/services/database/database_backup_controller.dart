part of 'sossoldi_database.dart';


Future<bool> checkTableExists(sql.Database db, String tableName) async {
  final List<Map<String, dynamic>> maps = await db.rawQuery(
    'SELECT name FROM sqlite_master WHERE type="table" AND name=?',
    [tableName],
  );

  return maps.isNotEmpty;
}

// Utils:
String sanitizeAlphaNumeric(String text) {
  return text
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
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

extension DatabaseBackupController on SossoldiDatabase
{

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

  // I consider being called in a try catch
  Future<bool> importCsvFromMoneyManager(String csvFilePath, DateTime from, DateTime to, bool reset) async {
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

      final db = SossoldiDatabase._database;

      if(db == null)
      {
        return false;
      }

      if(reset)
      {
        await resetDatabase();
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
              BankAccountFields.countNetWorth: 1,
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
                  BankAccountFields.countNetWorth: 1,
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

          if(dateTime.isBefore(from)  ||  dateTime.isAfter(to))
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

  Future<Uint8List> exportDatabase() async {

    String dbPath = await sql.getDatabasesPath();
    String path = join(dbPath, SossoldiDatabase.dbName);

    return  await File(path).readAsBytes();
  }

  Future<bool> importDatabase(File sourceFile) async {
    final dbPath = await getDatabasesPath();
    final destPath = join(dbPath, SossoldiDatabase.dbName);
    final backupPath = join(dbPath, "${SossoldiDatabase.dbName}.bak");

    if (SossoldiDatabase._database != null) {
      await SossoldiDatabase._database!.close();
      SossoldiDatabase._database = null;
    }

    try {

      final currentDbFile = File(destPath);
      if (await currentDbFile.exists()) {
        await currentDbFile.copy(backupPath);
      }

      await sourceFile.copy(destPath);

      final newDb = await openDatabase(destPath);
      bool isValid = await checkTableExists(newDb, bankAccountTable);

      if (isValid) {
        SossoldiDatabase._database = newDb;
        final bakFile = File(backupPath);
        if (await bakFile.exists()) await bakFile.delete();
        return true;
      } else {
        await newDb.close();
        throw Exception("Validation failed: Table missing");
      }
    } catch (e) {
      final bakFile = File(backupPath);
      if (await bakFile.exists()) {
        await bakFile.copy(destPath);
        await bakFile.delete();
      }

      SossoldiDatabase._database = await openDatabase(destPath);
      return false;
    }
  }

  // Ignore datetime start and to
  Future<String> exportToCSV(DateTime from, DateTime to) async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final String csvDir = join(documentsDir.path, 'sossoldi_exports');

    final db = SossoldiDatabase._database;

    if(db == null)
    {
      return '';
    }

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

          if(tableName == transactionTable)
          {
            DateTime trDate = DateTime(row[TransactionFields.date]);
            if(trDate.isBefore(from) || trDate.isAfter(to)) continue;
          }

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

  Future<Map<String, bool>> importFromCSV(File file, DateTime from, DateTime to, bool reset) async {
    final db = SossoldiDatabase._database;

    if(db == null)
    {
      return {};
    }

    Map<String, bool> results = {};

    try {
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
          int indexOfDate = headers.indexOf(TransactionFields.date);
          try {
            // Clear existing data
            if(reset){
              await txn.delete(tableName);
            }


            // Insert new data
            for (int i = 1; i < tableRows.length; i++) {
              final Map<String, dynamic> row = {};
              for (int j = 0; j < headers.length; j++) {
                if (j != tableNameIndex) {
                  // Skip the table_name column
                  final String header = headers[j];
                  final dynamic value = tableRows[i][j];

                  if(tableName == transactionTable)
                  {
                    String dateString = tableRows[i][indexOfDate];
                    DateTime? dt = parseFlexibleDate(dateString);
                    DateTime currentDate = dt ?? DateTime.parse(dateString);
                    if(currentDate.isBefore(from)  ||  currentDate.isAfter(to))
                    {
                      continue;
                    }

                  }
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

  // I consider being called in a try catch
  Future<bool> importDBFromMoneyManager(File file, DateTime from, DateTime to, bool reset) async {

    try {
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      Database mmDb = await openDatabase(
        file.path,
        readOnly: false,
        singleInstance: true,
      );

      if(!await checkTableExists(mmDb, MMAccount.tableName))
      {
        return false;
      }

      final myDb = SossoldiDatabase._database;

      if(myDb == null) {
        return false;
      }

      if(reset)
      {
        await resetDatabase();
      }

      List<Map<String,dynamic>> list = await mmDb.query(
          columns: [MMAccount.uidColumn, MMAccount.timeColumn, MMAccount.groupNameColumn, MMAccount.countNethWorthColumn],
          MMAccount.tableName
      );
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
              BankAccountFields.countNetWorth: a.countInNet ? 1 : 0,
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
          if(tr.date.isBefore(from)  ||  tr.date.isAfter(to))
          {
            continue;
          }
          await insertTransactionFromMoneyManager(txn: txn, transaction: tr);
        }
      });

      return true;


    } catch (e) {
      throw Exception('Failed to load database');
    }
  }


}