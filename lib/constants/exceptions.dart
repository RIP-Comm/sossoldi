class CsvNotFoundException implements Exception {
  @override
  String toString() => 'CsvNotFoundException: CSV file not found';
}

class CsvEmptyException implements Exception {
  @override
  String toString() => 'CsvEmptyException: CSV file is empty';
}

class CsvExpectedColumnException implements Exception {
  final String column;
  CsvExpectedColumnException({required this.column});

  @override
  String toString() =>
      'CsvExpectedColumnException: CSV file missing $column column';
}

class CsvImportTableException implements Exception {
  final String tableName;
  final Object error;
  CsvImportTableException({required this.tableName, required this.error});

  @override
  String toString() =>
      'CsvImportTableException: Failed to import table $tableName: $error';
}
