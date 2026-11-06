import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/services/csv/csv_format.dart';
import 'package:sossoldi/services/database/repositories/transactions_repository.dart';
import 'package:sossoldi/services/database/sossoldi_database.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

void main() {
  late SossoldiDatabase sossoldiDatabase;
  late sqflite.Database db;

  setUpAll(() async {
    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
    sossoldiDatabase = SossoldiDatabase(dbName: 'csv_format_test.db');
    db = await sossoldiDatabase.database;
  });

  setUp(() async => await sossoldiDatabase.clearDatabase());

  tearDownAll(() => sossoldiDatabase.close());

  test('columns match the model fields and flag required ones', () async {
    final columns = await CsvFormat.columns(db);

    expect(columns.keys, CsvFormat.tableFields.keys);
    columns.forEach((table, tableColumns) {
      expect(
        tableColumns.map((c) => c.name).toSet(),
        CsvFormat.tableFields[table]!.toSet(),
        reason: table,
      );
    });

    final transactionColumns = {
      for (final c in columns[transactionTable]!) c.name: c.required,
    };
    expect(transactionColumns[TransactionFields.amount], isTrue);
    expect(transactionColumns[TransactionFields.idBankAccount], isTrue);
    expect(transactionColumns[TransactionFields.note], isFalse);
    expect(transactionColumns[TransactionFields.id], isFalse);
  });

  test('template can be imported and read back by the app', () async {
    final dir = await Directory.systemTemp.createTemp('csv_format_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/template.csv');
    await file.writeAsString(CsvFormat.template());

    final results = await sossoldiDatabase.importFromCSV(file.path);

    expect(
      results.keys,
      unorderedEquals(['bankAccount', 'categoryTransaction', 'transaction']),
    );
    expect(results.values, everyElement(isTrue));

    final transactions = await TransactionsRepository(
      database: sossoldiDatabase,
    ).selectAll();
    expect(transactions, hasLength(1));
    expect(transactions.first.note, 'Supermarket');
    expect(transactions.first.type, TransactionType.expense);
    expect(transactions.first.amount, 25.5);
    expect(transactions.first.categoryName, 'Groceries');
    expect(transactions.first.bankAccountName, 'Main account');
  });
}
