import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/money_transaction.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Lấy danh sách giao dịch theo tháng/năm
  Future<List<MoneyTransaction>> getTransactionsByMonth(int month, int year) async {
    final db = await _dbHelper.database;
    final monthStr = month.toString().padLeft(2, '0');
    final pattern = '$year-$monthStr-%';
    
    final maps = await db.rawQuery('''
      SELECT t.*, c.name as categoryName 
      FROM transactions t
      JOIN categories c ON t.categoryId = c.id
      WHERE t.date LIKE ?
      ORDER BY t.date DESC
    ''', [pattern]);
    
    return maps.map((map) => MoneyTransaction.fromMap(map)).toList();
  }


  // Lấy tổng thu, tổng chi (Dùng cho Dashboard)
  Future<Map<String, int>> getSummary(int month, int year) async {
    final db = await _dbHelper.database;
    final monthStr = month.toString().padLeft(2, '0');
    final pattern = '$year-$monthStr-%';

    final result = await db.rawQuery('''
      SELECT type, SUM(amount) as total 
      FROM transactions 
      WHERE date LIKE ? 
      GROUP BY type
    ''', [pattern]);

    int income = 0;
    int expense = 0;
    for (var row in result) {
      if (row['type'] == 'income') income = row['total'] as int;
      if (row['type'] == 'expense') expense = row['total'] as int;
    }
    return {'income': income, 'expense': expense};
  }

  Future<int> insertTransaction(MoneyTransaction transaction) async {
    final db = await _dbHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<int> deleteTransaction(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
  Future<Database> getDb() async => await _dbHelper.database;

  Future<int> updateTransaction(MoneyTransaction transaction) async {
    final db = await _dbHelper.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
  // Lấy dữ liệu chi tiêu theo danh mục để vẽ biểu đồ tròn
  Future<List<Map<String, dynamic>>> getExpenseByCategory(int month, int year) async {
    final db = await _dbHelper.database;
    final monthStr = month.toString().padLeft(2, '0');
    final pattern = '$year-$monthStr-%';

    return await db.rawQuery('''
      SELECT c.name, c.color, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.categoryId = c.id
      WHERE t.type = 'expense' AND t.date LIKE ?
      GROUP BY t.categoryId
      ORDER BY total DESC
    ''', [pattern]);
  }
  
  }
