import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/model/bank_account.dart';
import 'package:sossoldi/model/transaction.dart';
import 'package:sossoldi/services/database/sossoldi_database.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;

void main() {
  late SossoldiDatabase sossoldiDatabase;
  late sqflite.Database db;
  late Directory dir;

  setUpAll(() async {
    sqflite_ffi.sqfliteFfiInit();
    sqflite_ffi.databaseFactory = sqflite_ffi.databaseFactoryFfi;
    sossoldiDatabase = SossoldiDatabase(dbName: 'import_from_csv_test.db');
    db = await sossoldiDatabase.database;
  });

  setUp(() async {
    await sossoldiDatabase.clearDatabase();
    await sossoldiDatabase.fillDemoData(countOfGeneratedTransaction: 2000);
    dir = await Directory.systemTemp.createTemp('import_from_csv_test');
  });

  tearDown(() async {
    await dir.delete(recursive: true);
    await sossoldiDatabase.clearDatabase();
  });

  tearDownAll(() => sossoldiDatabase.close());

  Future<int> count(String table) async =>
      sqflite.Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM "$table"'),
      ) ??
      0;

  Future<String> writeCsv(String content) async {
    final file = File('${dir.path}/import.csv');
    await file.writeAsString(content);
    return file.path;
  }

  const header =
      'table_name,id,name,symbol,color,startingValue,active,mainAccount,'
      'createdAt,updatedAt';

  test('a failing table leaves every table untouched', () async {
    final accountsBefore = await count(bankAccountTable);
    final transactionsBefore = await count(transactionTable);
    // The second account row misses the required "name" column
    final path = await writeCsv(
      '$header\r\n'
      'bankAccount,1,Main,payments,0,10,1,1,2026-01-01,2026-01-01\r\n'
      'bankAccount,2,,payments,0,10,1,0,2026-01-01,2026-01-01',
    );

    await expectLater(
      sossoldiDatabase.importFromCSV(path),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('bankAccount'),
        ),
      ),
    );

    expect(await count(bankAccountTable), accountsBefore);
    expect(await count(transactionTable), transactionsBefore);
  });

  test('a valid file replaces the imported tables', () async {
    final path = await writeCsv(
      '$header\r\n'
      'bankAccount,1,Main,payments,0,10,1,1,2026-01-01,2026-01-01',
    );

    final results = await sossoldiDatabase.importFromCSV(path);

    expect(results, {bankAccountTable: true});
    expect(await count(bankAccountTable), 1);
  });
}
