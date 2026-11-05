import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/selected_month_provider.dart';
import '../transactions/widgets/transaction_tile.dart';
import 'widgets/expense_pie_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedMonthProvider);
    final summaryAsync = ref.watch(transactionSummaryProvider);
    final txListAsync = ref.watch(transactionListProvider);
    final chartDataAsync = ref.watch(expenseChartDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tổng quan Tháng ${selectedDate.month}/${selectedDate.year}'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Kéo xuống để làm mới dữ liệu
          ref.invalidate(transactionSummaryProvider);
          ref.invalidate(transactionListProvider);
          ref.invalidate(expenseChartDataProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. THẺ TỔNG THU / TỔNG CHI
              summaryAsync.when(
                data: (summary) {
                  final income = summary['income'] ?? 0;
                  final expense = summary['expense'] ?? 0;
                  final balance = income - expense;

                  return Row(
                    children: [
                      _buildSummaryCard('Thu nhập', income, Colors.green, Icons.arrow_downward),
                      const SizedBox(width: 8),
                      _buildSummaryCard('Chi tiêu', expense, Colors.red, Icons.arrow_upward),
                      const SizedBox(width: 8),
                      _buildSummaryCard('Chênh lệch', balance, balance >= 0 ? Colors.blue : Colors.orange, Icons.account_balance_wallet),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Lỗi: $e'),
              ),
              const SizedBox(height: 24),

              // 2. BIỂU ĐỒ TRÒN
              const Text('Phân bổ chi tiêu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: chartDataAsync.when(
                  data: (data) => ExpensePieChart(data: data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Lỗi biểu đồ: $e')),
                ),
              ),
              const SizedBox(height: 24),

              // 3. 5 GIAO DỊCH GẦN NHẤT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Giao dịch gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => context.go('/transactions'), // Chuyển sang tab Giao dịch
                    child: const Text('Xem tất cả'),
                  )
                ],
              ),
              txListAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.grey))),
                    );
                  }
                  // Chỉ lấy 5 giao dịch đầu tiên
                  final recentTx = transactions.take(5).toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentTx.length,
                    itemBuilder: (context, index) {
                      return TransactionTile(
                        transaction: recentTx[index],
                        onTap: () {}, // Tạm thời chưa làm chi tiết
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Lỗi: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget phụ trợ để vẽ các thẻ tóm tắt
  Widget _buildSummaryCard(String title, int amount, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.formatCurrency(amount),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}