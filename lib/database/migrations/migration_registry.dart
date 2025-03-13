import 'migration_base.dart';

List<Migration> getMigrations() {
  return [
    //CreateInitialTables(),
    //AddTransactionIndexes(),
  ];
}

int getLatestVersion() {
  final migrations = getMigrations();
  return migrations.isEmpty ? 1 : migrations.last.version;
}