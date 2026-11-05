import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/budget.dart';

class BudgetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getBudgetsWithSpent(int month, int year) async {
    final db = await _dbHelper.database;
    final monthStr = month.toString().padLeft(2, '0');
    final pattern = '$year-$monthStr-%';

    final result = await db.rawQuery('''
      SELECT b.*, c.name as categoryName, c.color as categoryColor,
      COALESCE((
        SELECT SUM(t.amount) 
        FROM transactions t 
        WHERE t.categoryId = b.categoryId 
          AND t.type = 'expense' 
          AND t.date LIKE ?
      ), 0) as spentAmount
      FROM budgets b
      JOIN categories c ON b.categoryId = c.id
      WHERE b.month = ? AND b.year = ?
    ''', [pattern, month, year]);

    return result;
  }

  Future<int> insertBudget(Budget budget) async {
    final db = await _dbHelper.database;
    return await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteBudget(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}