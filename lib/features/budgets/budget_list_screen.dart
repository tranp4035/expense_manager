import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/selected_month_provider.dart';
import 'widgets/budget_progress_bar.dart';
import 'budget_form_bottom_sheet.dart';

class BudgetListScreen extends ConsumerWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedMonthProvider);
    final budgetsAsync = ref.watch(budgetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ngân sách Tháng ${selectedDate.month}/${selectedDate.year}'),
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (budgets) {
          if (budgets.isEmpty) {
            return const Center(child: Text('Chưa thiết lập ngân sách nào', style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final b = budgets[index];
              final colorHex = b['categoryColor'] as String? ?? '#9E9E9E';
              final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(backgroundColor: color.withValues(alpha: 0.2), radius: 8),
                          const SizedBox(width: 8),
                          Text(b['categoryName'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () async {
                              await ref.read(budgetRepositoryProvider).deleteBudget(b['id']);
                              ref.invalidate(budgetListProvider);
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      BudgetProgressBar(
                        limitAmount: b['limitAmount'] as int,
                        spentAmount: b['spentAmount'] as int,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const BudgetFormBottomSheet(),
          );
        },
      ),
    );
  }
}