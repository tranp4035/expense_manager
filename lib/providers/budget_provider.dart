import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/budget_repository.dart';
import 'selected_month_provider.dart';

final budgetRepositoryProvider = Provider((ref) => BudgetRepository());

// Provider lấy danh sách ngân sách kèm số đã chi
final budgetListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final selectedDate = ref.watch(selectedMonthProvider);
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getBudgetsWithSpent(selectedDate.month, selectedDate.year);
});