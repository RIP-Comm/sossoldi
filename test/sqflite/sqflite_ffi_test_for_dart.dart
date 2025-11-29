// You can also write regular dart test. Instead of using openDatabase
// (which is flutter only) you have use the proper SqfliteDatabaseFactory
// to open a database:

@TestOn('vm')
library;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

void main() {
  // Init ffi loader if needed.
  sqfliteFfiInit();
  test('Simple test', () async {
    var factory = databaseFactoryFfi;
    var db = await factory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE Test (id INTEGER PRIMARY KEY, value TEXT)',
          );
        },
      ),
    );
    // Insert some data
    await db.insert('Test', {'value': 'my_value'});

    // Check content
    expect(await db.query('Test'), [
      {'id': 1, 'value': 'my_value'},
    ]);

    await db.close();
  });
}
