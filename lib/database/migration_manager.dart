// lib/database/migration_manager.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'migrations/migration_base.dart';
import 'migrations/migration_registry.dart';

class MigrationManager {
  final List<Migration> _migrations = getMigrations();

  /// Get highest migration version
  int get latestVersion => getLatestVersion();

  Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    if (kDebugMode) {
      print('Migrating database from $oldVersion to $newVersion');
    }

    for (var migration in _migrations) {
      if (migration.version > oldVersion && migration.version <= newVersion) {
        if (kDebugMode) {
          print('Running migration ${migration.version}: ${migration.description}');
        }
        await migration.up(db);
      }
    }
  }
}