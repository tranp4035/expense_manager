import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/money_transaction.dart';
import '../data/repositories/transaction_repository.dart';
import 'selected_month_provider.dart';

// Provider cho Repository
final transactionRepositoryProvider = Provider((ref) => TransactionRepository());

// Provider lấy danh sách giao dịch theo tháng đang chọn
final transactionListProvider = FutureProvider.autoDispose<List<MoneyTransaction>>((ref) async {
  final selectedDate = ref.watch(selectedMonthProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionsByMonth(selectedDate.month, selectedDate.year);
});

// Provider lấy tổng thu/chi cho Dashboard
final transactionSummaryProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final selectedDate = ref.watch(selectedMonthProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getSummary(selectedDate.month, selectedDate.year);
});

final transactionByIdProvider = FutureProvider.autoDispose.family<MoneyTransaction?, int>((ref, id) async {
  final repo = ref.watch(transactionRepositoryProvider);
  final db = await repo.getDb(); // Cần thêm hàm này vào Repository
  final maps = await db.query('transactions', where: 'id = ?', whereArgs: [id]);
  if (maps.isEmpty) return null;
  return MoneyTransaction.fromMap(maps.first);
});
// Provider lấy dữ liệu chi tiêu theo danh mục cho biểu đồ
final expenseChartDataProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final selectedDate = ref.watch(selectedMonthProvider);
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getExpenseByCategory(selectedDate.month, selectedDate.year);
});
