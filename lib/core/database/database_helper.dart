import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Bảng categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
        icon TEXT,
        color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL CHECK(amount > 0),
        type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
        categoryId INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        imagePath TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');

    // Bảng budgets
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId INTEGER NOT NULL,
        limitAmount INTEGER NOT NULL CHECK(limitAmount > 0),
        month INTEGER NOT NULL CHECK(month BETWEEN 1 AND 12),
        year INTEGER NOT NULL,
        UNIQUE(categoryId, month, year),
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');

    // Seed danh mục mặc định
    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    final defaultCategories = [
      // Chi tiêu
      {'name': 'Ăn uống', 'type': 'expense', 'icon': 'restaurant', 'color': '#FF5722'},
      {'name': 'Di chuyển', 'type': 'expense', 'icon': 'directions_bus', 'color': '#2196F3'},
      {'name': 'Mua sắm', 'type': 'expense', 'icon': 'shopping_bag', 'color': '#9C27B0'},
      {'name': 'Giải trí', 'type': 'expense', 'icon': 'movie', 'color': '#FF9800'},
      {'name': 'Hóa đơn', 'type': 'expense', 'icon': 'receipt', 'color': '#607D8B'},
      // Thu nhập
      {'name': 'Lương', 'type': 'income', 'icon': 'payments', 'color': '#4CAF50'},
      {'name': 'Thưởng', 'type': 'income', 'icon': 'card_giftcard', 'color': '#8BC34A'},
    ];

    for (final cat in defaultCategories) {
      await db.insert('categories', cat);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}