// In order to use your existing sqflite code in flutter test, you have to setup
// sqflite_common_ffi to replace the global default flutter database factory.
// This can be done in a setUpAll method like this:

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

Future main() async {
  // Setup sqflite_common_ffi for flutter test
  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  });
  test('Simple test', () async {
    var db = await openDatabase(inMemoryDatabasePath, version: 1, onCreate: (db, version) async {
      await db.execute('CREATE TABLE Test (id INTEGER PRIMARY KEY, value TEXT)');
    });
    // Insert some data
    await db.insert('Test', {'value': 'my_value'});
    // Check content
    expect(await db.query('Test'), [
      {'id': 1, 'value': 'my_value'}
    ]);

    await db.close();
  });
}
