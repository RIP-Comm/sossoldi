class CsvExportingErrorException implements Exception {
  final String tableName;
  CsvExportingErrorException({required this.tableName});

  @override
  String toString() => 'ExportingErrorException: Failed to export table: $tableName';
}

class CsvNotFoundException implements Exception {
  @override
  String toString() => 'CsvNotFoundException: The specified CSV file was not found.';
}

class CsvEmptyException implements Exception {
  @override
  String toString() => 'CsvEmptyException: The CSV file is empty.';
}

class CsvExpectedColumnException implements Exception {
  final String column;
  CsvExpectedColumnException({required this.column});

  @override
  String toString() => 'CsvExpectedColumnException: Missing expected column: $column';
}

class CsvUnexpectedValueException implements Exception {
  final String value;
  CsvUnexpectedValueException({required this.value});

  @override
  String toString() => 'CsvUnexpectedValueException: Found an unexpected value: $value';
}

class CsvImportGeneralErrorException implements Exception {
  final String text;
  CsvImportGeneralErrorException({required this.text});
  @override
  String toString() => 'CsvImportGeneralErrorException: A general error occurred during CSV import. Reason: $text';
}

class CsvTransactionImportErrorException implements Exception {
  final String date;
  CsvTransactionImportErrorException({required this.date});

  @override
  String toString() => 'CsvTransactionImportErrorException: Failed to import transaction on date: $date';
}

class CleanDatabaseException implements Exception {
  final String text;
  CleanDatabaseException({required this.text});

  @override
  String toString() => 'CleanDatabaseException: Failed to clean the database. Reason: $text';
}

class ResetDatabaseException implements Exception {
  final String text;
  ResetDatabaseException({required this.text});

  @override
  String toString() => 'ResetDatabaseException: Failed to reset the database. Reason: $text';
}