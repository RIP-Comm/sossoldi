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
    print(path);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database database, int version) async {
    const integerPrimaryKeyAutoincrement = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const booleanNotNull = 'BOOLEAN NOT NULL';
    const integerNotNull = 'INTEGER NOT NULL';
    const textNotNull = 'TEXT NOT NULL';

    // Bank accounts Table
    await database.execute(
        '''
      CREATE TABLE `$bankAccountTable`(
        `${BankAccountFields.id}` $integerPrimaryKeyAutoincrement,
        `${BankAccountFields.name}` $textNotNull,
        `${BankAccountFields.value}` $textNotNull,
        `${BankAccountFields.createdAt}` $textNotNull,
        `${BankAccountFields.updatedAt}` $textNotNull
      )
      ''');

    // Transactions Table
    await database.execute(
        '''
      CREATE TABLE `$transactionTable`(
        `${TransactionFields.id}` $integerPrimaryKeyAutoincrement,
        `${TransactionFields.date}` $textNotNull,
        `${TransactionFields.amount}` $textNotNull,
        `${TransactionFields.type}` $textNotNull,
        `${TransactionFields.note}` $textNotNull,
        `${TransactionFields.idBankAccount}` $textNotNull,
        `${TransactionFields.idBudget}` $textNotNull,
        `${TransactionFields.idCategory}` $textNotNull,
        `${TransactionFields.idRecurringTransaction}` $textNotNull,
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
        `${RecurringTransactionFields.idCategoryRecurring}` $textNotNull,
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
        `${RecurringTransactionAmountFields.amount}` $textNotNull,
        `${RecurringTransactionAmountFields.idRecurringTransaction}` $textNotNull,
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
        `${BudgetFields.amountLimit}` $textNotNull,
        `${BudgetFields.createdAt}` $textNotNull,
        `${BudgetFields.updatedAt}` $textNotNull
      )
    ''');
  }

  Future<BankAccount> create(BankAccount example) async {
    final database = await instance.database;

    // final json = example.toJson();
    // final columns =
    //     '${ExampleFields.title}, ${ExampleFields.description}, ${ExampleFields.dataTime}';
    // final values =
    //     '${json[ExampleFields.title]}, ${json[ExampleFields.description]}, ${json[ExampleFields.dataTime]}';
    // final id = await database
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final id = await database.insert(bankAccountTable, example.toJson());

    return example.copy(id: id);
  }

  Future<BankAccount> read(int id) async {
    final database = await instance.database;

    final maps = await database.query(
      bankAccountTable,
      columns: BankAccountFields.allFields,
      where: '${BankAccountFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return BankAccount.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
      // reutrn null;
    }
  }

  Future<List<BankAccount>> readAll() async {
    final database = await instance.database;

    final orderByASC = '${BankAccountFields.createdAt} ASC';

    // final result = await database.rawQuery('SELECT * FROM $tableExample ORDER BY $orderByASC')
    final result = await database.query(bankAccountTable, orderBy: orderByASC);

    return result.map((json) => BankAccount.fromJson(json)).toList();
  }

  Future<int> update(BankAccount example) async {
    final database = await instance.database;

    // You can use `rawUpdate` to write the query in SQL
    return database.update(
      bankAccountTable,
      example.toJson(),
      where:
          '${BankAccountFields.id} = ?', // Use `:` if you will not use `sqflite_common_ffi`
      whereArgs: [example.id],
    );
  }

  Future<int> delete(int id) async {
    Database database = await instance.database;

    return await database.delete(bankAccountTable,
        where:
            '${BankAccountFields.id} = ?', // Use `:` if you will not use `sqflite_common_ffi`
        whereArgs: [id]);
  }

  Future close() async {
    final database = await instance.database;
    database.close();
  }

  // FOR DEV/TEST PURPOSES ONLY!!
  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'sossoldi.db');
    databaseFactory.deleteDatabase(path);
  }
}
