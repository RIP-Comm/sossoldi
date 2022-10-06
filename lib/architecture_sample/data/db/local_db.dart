import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category_model.dart';

class LocalDb {
  static final LocalDb instance = LocalDb._init();

  static Database? _database;

  LocalDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('sossoldi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // On Android, it is typically data/data//databases.
    // On iOS and MacOS, it is the Documents directory.
    // final databasePath = await getDatabasesPath();
    Directory databasePath = await getApplicationDocumentsDirectory();

    final path = join(databasePath.path, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database database, int version) async {
    const integerPrimaryKeyAutoincrement = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const booleanNotNull = 'BOOLEAN NOT NULL';
    const integerNotNull = 'INTEGER NOT NULL';
    const textNotNull = 'TEXT NOT NULL';

    // If you want to create a new table you must duplicate the code below
    // by changing the name and the fields.
    // (and obviously create a new model for your table)
    await database.execute('''
      CREATE TABLE $tableCategory(
        ${CategoryFields.id} $integerPrimaryKeyAutoincrement,
        ${CategoryFields.name} $textNotNull,
        ${CategoryFields.createdAt} $textNotNull,
        ${CategoryFields.updatedAt} $textNotNull
      )
      ''');
  }
}
