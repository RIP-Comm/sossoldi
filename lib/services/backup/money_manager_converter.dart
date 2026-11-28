import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../../constants/constants.dart';
import '../../model/bank_account.dart';
import '../../model/category_transaction.dart';
import '../../model/transaction.dart';

/// Thrown when a Money Manager export cannot be read or converted.
class MoneyManagerFormatException implements Exception {
  const MoneyManagerFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Rows ready to be inserted into the Sossoldi tables.
class MoneyManagerImportData {
  const MoneyManagerImportData({
    required this.accounts,
    required this.categories,
    required this.transactions,
    required this.skippedRows,
  });

  final List<Map<String, Object?>> accounts;
  final List<Map<String, Object?>> categories;
  final List<Map<String, Object?>> transactions;

  /// Rows of the export that could not be converted (unknown type, missing
  /// date, account or category, Transfer-In duplicates).
  final int skippedRows;
}

/// Reads the spreadsheet exported by Money Manager ("Export to Excel"), either
/// as the original `.xlsx` or saved as `.csv`, into rows of strings.
class MoneyManagerReader {
  const MoneyManagerReader._();

  static List<List<String>> readCsv(String content) {
    final rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(content.replaceAll('\r\n', '\n'));
    return [
      for (final row in rows) [for (final cell in row) cell.toString()],
    ];
  }

  static List<List<String>> readXlsx(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const MoneyManagerFormatException('The file is not a valid .xlsx');
    }

    XmlDocument? parse(String name) {
      final file = archive.findFile(name);
      if (file == null) return null;
      return XmlDocument.parse(utf8.decode(file.readBytes()!));
    }

    final sheetName = archive.findFile('xl/worksheets/sheet1.xml') != null
        ? 'xl/worksheets/sheet1.xml'
        : archive.files
              .map((f) => f.name)
              .where(
                (n) => n.startsWith('xl/worksheets/') && n.endsWith('.xml'),
              )
              .firstOrNull;
    final sheet = sheetName == null ? null : parse(sheetName);
    if (sheet == null) {
      throw const MoneyManagerFormatException('The .xlsx contains no sheet');
    }

    final sharedStrings = <String>[
      for (final si
          in parse('xl/sharedStrings.xml')?.findAllElements('si') ??
              const <XmlElement>[])
        si.descendantElements
            .where(
              (e) => e.localName == 't' && e.parentElement?.localName != 'rPh',
            )
            .map((e) => e.innerText)
            .join(),
    ];

    final rows = <List<String>>[];
    for (final row in sheet.findAllElements('row')) {
      final cells = <int, String>{};
      var nextColumn = 0;
      for (final cell in row.findElements('c')) {
        final ref = cell.getAttribute('r');
        final column = ref == null ? nextColumn : _columnIndex(ref);
        nextColumn = column + 1;
        final value = cell.getElement('v')?.innerText ?? '';
        cells[column] = switch (cell.getAttribute('t')) {
          's' => sharedStrings[int.parse(value)],
          'inlineStr' =>
            cell.findAllElements('t').map((e) => e.innerText).join(),
          _ => value,
        };
      }
      final width = cells.isEmpty
          ? 0
          : cells.keys.reduce((a, b) => a > b ? a : b) + 1;
      rows.add([for (var i = 0; i < width; i++) cells[i] ?? '']);
    }
    return rows;
  }

  /// "A1" -> 0, "L7" -> 11, "AA3" -> 26.
  static int _columnIndex(String ref) {
    var index = 0;
    for (final unit in ref.codeUnits) {
      if (unit < 0x41 || unit > 0x5A) break;
      index = index * 26 + (unit - 0x40);
    }
    return index - 1;
  }
}

/// Converts the rows of a Money Manager export into Sossoldi rows.
///
/// Accounts and categories are rebuilt from the names used by the
/// transactions: Money Manager does not export them separately, nor their
/// icons, colours or starting balances (balances are kept through the
/// "Modified Bal." transactions, which are imported as well).
class MoneyManagerConverter {
  const MoneyManagerConverter._();

  /// Money Manager's built-in balance adjustment category.
  static const balanceAdjustmentNames = {
    'Modified Bal.',
    'Modifica Saldo',
    'Modificar saldo',
    'Modificar Saldo',
    'Changement de restant',
    'Изменение остатка',
    'Bestand ändern',
  };
  static const balanceAdjustmentLabel = 'Balance adjustment';

  static const accountSymbol = 'account_balance';
  static const categorySymbol = 'question_mark';

  /// Notes Money Manager writes on its own for balance adjustments.
  static const _generatedNotes = {
    'difference',
    'differenza',
    'diferencia',
    'diferença',
    'différence',
    'разница',
  };

  static const _types = {
    'income': _Kind.income,
    'expense': _Kind.expense,
    'transfer-out': _Kind.transferOut,
    'transfer-in': _Kind.transferIn,
    'guadagno': _Kind.income,
    'spesa': _Kind.expense,
    'trasferimento uscita': _Kind.transferOut,
    'ingreso': _Kind.income,
    'gasto': _Kind.expense,
    'dinero gastado': _Kind.transferOut,
    'revenu': _Kind.income,
    'dépense': _Kind.expense,
    'sorties': _Kind.transferOut,
    'receita': _Kind.income,
    'despesa': _Kind.expense,
    'transferência para fora': _Kind.transferOut,
    'доход': _Kind.income,
    'расход': _Kind.expense,
    'снятие': _Kind.transferOut,
    'einkommen': _Kind.income,
    'ausgabe': _Kind.expense,
    'ausgehender transfer': _Kind.transferOut,
  };

  static const _required = [
    'Date',
    'Account',
    'Category',
    'Subcategory',
    'Note',
    'Income/Expense',
    'Description',
    'Amount',
  ];

  static final _emoji = RegExp(
    // The analyzer does not know Unicode property escapes; the VM does.
    // ignore: valid_regexps
    r'[\p{Extended_Pictographic}\p{Emoji_Modifier}\u{FE0F}\u{200D}]',
    unicode: true,
  );
  static final _spaces = RegExp(r'\s+');
  static final _currencyCode = RegExp(r'^[A-Z]{3}$');

  static final _textDateFormats = [
    DateFormat('MM/dd/yyyy HH:mm:ss'),
    DateFormat('MM/dd/yyyy HH:mm'),
    DateFormat('MM/dd/yy HH:mm:ss'),
    DateFormat('MM/dd/yy HH:mm'),
  ];

  static MoneyManagerImportData convert(
    List<List<String>> rows, {
    DateTime? now,
  }) {
    if (rows.isEmpty) {
      throw const MoneyManagerFormatException('The file is empty');
    }
    final columns = _Columns.find([for (final h in rows.first) h.trim()]);

    final parsed = <_Row>[];
    final unknownTypes = <String>{};
    var skipped = 0;
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      String cell(int index) => index < row.length ? row[index].trim() : '';
      if (row.every((c) => c.trim().isEmpty)) continue;

      final typeLabel = cell(columns.type);
      final kind = _kind(typeLabel);
      if (kind == null) {
        unknownTypes.add(typeLabel);
        continue;
      }
      final type = switch (kind) {
        _Kind.income => TransactionType.income,
        _Kind.expense => TransactionType.expense,
        _Kind.transferOut => TransactionType.transfer,
        _Kind.transferIn => null, // Transfer-In mirrors a Transfer-Out row
      };
      final date = _parseDate(cell(columns.date));
      final amount = _parseAmount(cell(columns.amount));
      final account = _cleanName(cell(columns.account));
      final category = _cleanName(cell(columns.category));
      if (type == null ||
          date == null ||
          amount == null ||
          account.isEmpty ||
          category.isEmpty) {
        skipped++;
        continue;
      }
      parsed.add(
        _Row(
          index: i,
          date: date,
          type: type,
          amount: amount.abs(),
          account: account,
          category:
              type != TransactionType.transfer &&
                  balanceAdjustmentNames.contains(category)
              ? balanceAdjustmentLabel
              : category,
          subcategory: _cleanName(cell(columns.subcategory)),
          note: _note(cell(columns.note), cell(columns.description)),
        ),
      );
    }
    if (unknownTypes.isNotEmpty) {
      throw MoneyManagerFormatException(
        'Transaction types not recognised: '
        '${unknownTypes.map((t) => '"$t"').join(', ')}. '
        'Export again from Money Manager with the app in English.',
      );
    }
    parsed.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.index.compareTo(b.index);
    });

    final createdAt = (now ?? DateTime.now()).toIso8601String();

    // Accounts: most used first, the most used one is the main account.
    final usage = <String, int>{};
    for (final row in parsed) {
      usage[row.account] = (usage[row.account] ?? 0) + 1;
      if (row.type == TransactionType.transfer) {
        usage[row.category] = (usage[row.category] ?? 0) + 1;
      }
    }
    final accountNames = usage.keys.toList()
      ..sort((a, b) => usage[b]!.compareTo(usage[a]!));
    final accountIds = <String, int>{};
    final accounts = <Map<String, Object?>>[];
    for (final (i, name) in accountNames.indexed) {
      accountIds[name] = i + 1;
      accounts.add({
        BankAccountFields.id: i + 1,
        BankAccountFields.name: name,
        BankAccountFields.symbol: accountSymbol,
        BankAccountFields.color: i % accountColorList.length,
        BankAccountFields.startingValue: 0.0,
        BankAccountFields.active: 1,
        BankAccountFields.countNetWorth: 1,
        BankAccountFields.mainAccount: i == 0 ? 1 : 0,
        BankAccountFields.order: i,
        BankAccountFields.createdAt: createdAt,
        BankAccountFields.updatedAt: createdAt,
      });
    }

    // Categories: parents sorted by name, then their subcategories.
    final parents = <String, _Category>{};
    for (final row in parsed.where((r) => r.type != TransactionType.transfer)) {
      final parent = parents.putIfAbsent(row.category, _Category.new)
        ..types.add(row.type);
      if (row.subcategory.isNotEmpty) {
        parent.subcategories
            .putIfAbsent(row.subcategory, _Category.new)
            .types
            .add(row.type);
      }
    }
    final parentNames = parents.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final categories = <Map<String, Object?>>[];
    Map<String, Object?> categoryRow(
      String name,
      _Category category,
      int color,
      int? parentId,
    ) {
      category.id = categories.length + 1;
      return {
        CategoryTransactionFields.id: category.id,
        CategoryTransactionFields.name: name,
        CategoryTransactionFields.type: category.typeCode,
        CategoryTransactionFields.symbol: categorySymbol,
        CategoryTransactionFields.color: color,
        CategoryTransactionFields.parent: parentId,
        CategoryTransactionFields.order: categories.length,
        CategoryTransactionFields.createdAt: createdAt,
        CategoryTransactionFields.updatedAt: createdAt,
      };
    }

    for (final (i, name) in parentNames.indexed) {
      categories.add(
        categoryRow(name, parents[name]!, i % categoryColorList.length, null),
      );
    }
    for (final (i, name) in parentNames.indexed) {
      final parent = parents[name]!;
      final subNames = parent.subcategories.keys.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      for (final sub in subNames) {
        categories.add(
          categoryRow(
            sub,
            parent.subcategories[sub]!,
            i % categoryColorList.length,
            parent.id,
          ),
        );
      }
    }

    final transactions = <Map<String, Object?>>[];
    for (final row in parsed) {
      final date = row.date.toIso8601String();
      final isTransfer = row.type == TransactionType.transfer;
      final parent = isTransfer ? null : parents[row.category]!;
      transactions.add({
        TransactionFields.id: transactions.length + 1,
        TransactionFields.date: date,
        TransactionFields.amount: row.amount,
        TransactionFields.type: row.type.code,
        TransactionFields.note: row.note,
        TransactionFields.idCategory: parent == null
            ? null
            : (parent.subcategories[row.subcategory]?.id ?? parent.id),
        TransactionFields.idBankAccount: accountIds[row.account],
        TransactionFields.idBankAccountTransfer: isTransfer
            ? accountIds[row.category]
            : null,
        TransactionFields.recurring: 0,
        TransactionFields.idRecurringTransaction: null,
        TransactionFields.createdAt: date,
        TransactionFields.updatedAt: date,
      });
    }

    return MoneyManagerImportData(
      accounts: accounts,
      categories: categories,
      transactions: transactions,
      skippedRows: skipped,
    );
  }

  /// Removes emoji from account and category names ("🍜 Cibo" -> "Cibo").
  static String _cleanName(String name) =>
      name.replaceAll(_emoji, '').replaceAll(_spaces, ' ').trim();

  static String _normalize(String text) => text.toLowerCase().trim();

  static _Kind? _kind(String label) => _types[_normalize(label)];

  static String? _note(String note, String description) {
    final parts = [
      if (!_generatedNotes.contains(_normalize(note))) note,
      description,
    ].where((p) => p.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' - ');
  }

  static double? _parseAmount(String text) =>
      double.tryParse(text) ??
      (text.contains('.') ? null : double.tryParse(text.replaceAll(',', '.')));

  /// The .xlsx stores dates as Excel serial numbers (days since 1899-12-30,
  /// local time); a CSV saved from it contains them as text.
  static DateTime? _parseDate(String text) {
    final serial = double.tryParse(text);
    if (serial != null) {
      final utc = DateTime.utc(1899, 12, 30).add(
        Duration(microseconds: (serial * Duration.microsecondsPerDay).round()),
      );
      return DateTime(
        utc.year,
        utc.month,
        utc.day,
        utc.hour,
        utc.minute,
        utc.second,
        utc.millisecond,
      );
    }
    for (final format in _textDateFormats) {
      try {
        return format.parseStrict(text);
      } on FormatException {
        continue;
      }
    }
    return DateTime.tryParse(text);
  }
}

enum _Kind { income, expense, transferOut, transferIn }

class _Columns {
  const _Columns({
    required this.date,
    required this.account,
    required this.category,
    required this.subcategory,
    required this.note,
    required this.type,
    required this.description,
    required this.amount,
  });

  final int date;
  final int account;
  final int category;
  final int subcategory;
  final int note;
  final int type;
  final int description;
  final int amount;

  factory _Columns.find(List<String> header) {
    // The column named after the main currency (e.g. "EUR") holds the amount
    // converted to it; "Amount" is in the transaction's own currency.
    final mainAmount = header.indexWhere(
      MoneyManagerConverter._currencyCode.hasMatch,
    );
    if (MoneyManagerConverter._required.every(header.contains)) {
      int col(String name) => header.indexOf(name);
      return _Columns(
        date: col('Date'),
        account: col('Account'),
        category: col('Category'),
        subcategory: col('Subcategory'),
        note: col('Note'),
        type: col('Income/Expense'),
        description: col('Description'),
        amount: mainAmount != -1 ? mainAmount : col('Amount'),
      );
    }
    if (mainAmount != 5 || header.length < 11) {
      throw const MoneyManagerFormatException(
        'This file does not look like a Money Manager export',
      );
    }
    return _Columns(
      date: 0,
      account: 1,
      category: 2,
      subcategory: 3,
      note: 4,
      amount: 5,
      type: 6,
      description: header.length >= 12 ? 8 : 7,
    );
  }
}

class _Row {
  _Row({
    required this.index,
    required this.date,
    required this.type,
    required this.amount,
    required this.account,
    required this.category,
    required this.subcategory,
    required this.note,
  });

  final int index;
  final DateTime date;
  final TransactionType type;
  final double amount;
  final String account;
  final String category;
  final String subcategory;
  final String? note;
}

class _Category {
  final types = <TransactionType>{};
  final subcategories = <String, _Category>{};
  int? id;

  String get typeCode => switch ((
    types.contains(TransactionType.income),
    types.contains(TransactionType.expense),
  )) {
    (true, true) => CategoryTransactionType.incomeAndExpense.code,
    (true, false) => CategoryTransactionType.income.code,
    _ => CategoryTransactionType.expense.code,
  };
}
