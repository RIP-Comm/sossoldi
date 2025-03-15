import 'package:sqflite/sqflite.dart';
import '../migration_base.dart';

// Models
import '/model/bank_account.dart';
import '/model/budget.dart';
import '/model/category_transaction.dart';
import '/model/currency.dart';
import '/model/recurring_transaction.dart';
import '/model/transaction.dart';

class InitialSchema extends Migration {
  InitialSchema() : super(
      version: 1,
      description: 'Initial database schema creation'
  );

  @override
  Future<void> up(Database db) async {
    const integerPrimaryKeyAutoincrement = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const integerNotNull = 'INTEGER NOT NULL';
    const integer = 'INTEGER';
    const realNotNull = 'REAL NOT NULL';
    const textNotNull = 'TEXT NOT NULL';
    const text = 'TEXT';

    // Bank accounts Table
    await db.execute('''
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
    await db.execute('''
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
        `${TransactionFields.idRecurringTransaction}` $integer,
        `${TransactionFields.createdAt}` $textNotNull,
        `${TransactionFields.updatedAt}` $textNotNull
      )
    ''');

    // Recurring Transactions Amount Table
    await db.execute('''
      CREATE TABLE `$recurringTransactionTable`(
        `${RecurringTransactionFields.id}` $integerPrimaryKeyAutoincrement,
        `${RecurringTransactionFields.fromDate}` $textNotNull,
        `${RecurringTransactionFields.toDate}` $text,
        `${RecurringTransactionFields.amount}` $realNotNull,
        `${RecurringTransactionFields.note}` $textNotNull,
        `${RecurringTransactionFields.recurrency}` $textNotNull,
        `${RecurringTransactionFields.idCategory}` $integerNotNull,
        `${RecurringTransactionFields.idBankAccount}` $integerNotNull,
        `${RecurringTransactionFields.lastInsertion}` $text,
        `${RecurringTransactionFields.createdAt}` $textNotNull,
        `${RecurringTransactionFields.updatedAt}` $textNotNull
      )
    ''');

    // Category Transaction Table
    await db.execute('''
      CREATE TABLE `$categoryTransactionTable`(
        `${CategoryTransactionFields.id}` $integerPrimaryKeyAutoincrement,
        `${CategoryTransactionFields.name}` $textNotNull,
        `${CategoryTransactionFields.type}` $textNotNull,
        `${CategoryTransactionFields.symbol}` $textNotNull,
        `${CategoryTransactionFields.color}` $integerNotNull,
        `${CategoryTransactionFields.note}` $text,
        `${CategoryTransactionFields.parent}` $integer,
        `${CategoryTransactionFields.createdAt}` $textNotNull,
        `${CategoryTransactionFields.updatedAt}` $textNotNull
      )
    ''');

    // Budget Table
    await db.execute('''
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
    await db.execute('''
      CREATE TABLE `$currencyTable`(
        `${CurrencyFields.id}` $integerPrimaryKeyAutoincrement,
        `${CurrencyFields.symbol}` $textNotNull,
        `${CurrencyFields.code}` $textNotNull,
        `${CurrencyFields.name}` $textNotNull,
        `${CurrencyFields.mainCurrency}` $integerNotNull CHECK (${CurrencyFields.mainCurrency} IN (0, 1))
      )
      ''');

    await db.execute('''
      INSERT INTO `$currencyTable`(`${CurrencyFields.symbol}`, `${CurrencyFields.code}`, `${CurrencyFields.name}`, `${CurrencyFields.mainCurrency}`) VALUES
        ("€", "EUR", "Euro", 1),
        ("\$", "USD", "United States Dollar", 0),
        ("CHF", "CHF", "Switzerland Franc", 0),
        ("£", "GBP", "United Kingdom Pound", 0);
    ''');
  }
}
