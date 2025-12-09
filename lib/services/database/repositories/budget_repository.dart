import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../model/budget.dart';
import '../../../model/category_transaction.dart';
import '../../../model/transaction.dart';
import '../sossoldi_database.dart';

part 'budget_repository.g.dart';

@riverpod
BudgetRepository budgetRepository(Ref ref) {
  return BudgetRepository(database: ref.watch(databaseProvider));
}

class BudgetRepository {
  BudgetRepository({required SossoldiDatabase database})
    : _sossoldiDB = database;

  final SossoldiDatabase _sossoldiDB;

  Future<Budget> insert(Budget item) async {
    final db = await _sossoldiDB.database;
    final id = await db.insert(budgetTable, item.toJson());
    return item.copy(id: id);
  }

  Future<Budget> insertOrUpdate(Budget item) async {
    final db = await _sossoldiDB.database;

    final exists = await checkIfExists(item);
    if (exists) {
      await db.rawQuery(
        "UPDATE $budgetTable SET amountLimit = ${item.amountLimit} WHERE idCategory = ${item.idCategory}",
      );
    } else {
      await db.insert(budgetTable, item.toJson());
    }

    return item.copy(id: item.id);
  }

  Future<bool> checkIfExists(Budget item) async {
    final db = await _sossoldiDB.database;

    try {
      final exists = await db.rawQuery(
        "SELECT * FROM $budgetTable WHERE ${item.idCategory} = idCategory",
      );
      if (exists.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Budget> selectById(int id) async {
    final db = await _sossoldiDB.database;

    final maps = await db.query(
      budgetTable,
      columns: BudgetFields.allFields,
      where: '${BudgetFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Budget>> selectAll() async {
    final db = await _sossoldiDB.database;
    final orderByASC = '${BudgetFields.createdAt} ASC';
    final result = await db.rawQuery(
      'SELECT bt.*, ct.name FROM $budgetTable as bt LEFT JOIN $categoryTransactionTable as ct ON bt.${BudgetFields.idCategory} = ct.${CategoryTransactionFields.id} ORDER BY $orderByASC',
    );
    return result.map((json) => Budget.fromJson(json)).toList();
  }

  Future<List<Budget>> selectAllActive() async {
    final db = await _sossoldiDB.database;
    final orderByASC = '${BudgetFields.createdAt} ASC';
    final result = await db.rawQuery(
      'SELECT bt.*, ct.name FROM $budgetTable as bt LEFT JOIN $categoryTransactionTable as ct ON bt.${BudgetFields.idCategory} = ct.${CategoryTransactionFields.id} WHERE bt.active = 1 ORDER BY $orderByASC',
    );
    return result.map((json) => Budget.fromJson(json)).toList();
  }

  Future<List<BudgetStats>> selectMonthlyBudgetsStats() async {
    final db = await _sossoldiDB.database;
    var query =
        "SELECT bt.*, SUM(t.amount) as spent FROM $budgetTable as bt  LEFT JOIN $categoryTransactionTable as ct ON bt.${BudgetFields.idCategory} = ct.${CategoryTransactionFields.id}  LEFT JOIN '$transactionTable' as t ON t.${TransactionFields.idCategory} = ct.${CategoryTransactionFields.id}  WHERE bt.active = 1 AND strftime('%m', t.date) = strftime('%m', 'now') AND strftime('%Y', t.date) = strftime('%Y', 'now')  GROUP BY bt.${BudgetFields.idCategory};";
    final result = await db.rawQuery(query);

    List<Budget> allBudgets = await selectAllActive();

    List<BudgetStats> statsList = result
        .map((json) => BudgetStats.fromJson(json))
        .toList();

    Set<int> resultBudgetIds = statsList
        .map((stats) => stats.idCategory)
        .toSet();

    // Check for missing budgets and add them with a spent amount of 0
    for (var budget in allBudgets) {
      if (!resultBudgetIds.contains(budget.idCategory)) {
        statsList.add(
          BudgetStats(
            idCategory: budget.idCategory,
            name: budget.name,
            spent: 0,
            amountLimit: budget.amountLimit,
          ),
        );
      }
    }

    return statsList;
  }

  Future<int> updateItem(Budget item) async {
    final db = await _sossoldiDB.database;

    // You can use `rawUpdate` to write the query in SQL
    return db.update(
      budgetTable,
      item.toJson(update: true),
      where: '${BudgetFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final db = await _sossoldiDB.database;

    return await db.delete(
      budgetTable,
      where: '${BudgetFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteByCategory(int id) async {
    final db = await _sossoldiDB.database;

    return await db.delete(
      budgetTable,
      where: '${BudgetFields.idCategory} = ?',
      whereArgs: [id],
    );
  }
}
