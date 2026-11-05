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
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              // Mở hộp thoại chọn ngày (người dùng chọn ngày nào cũng được, ta chỉ lấy tháng/năm)
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime(selectedDate.year, selectedDate.month, 1),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                helpText: 'Chọn tháng muốn xem',
              );
              
              if (pickedDate != null) {
                ref.read(selectedMonthProvider.notifier).changeMonth(pickedDate.month, pickedDate.year);
              }
            },
          ),
        ],
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

                  final cards = [
                    _buildSummaryCard('Thu nhập', income, Colors.green, Icons.arrow_downward),
                    _buildSummaryCard('Chi tiêu', expense, Colors.red, Icons.arrow_upward),
                    _buildSummaryCard('Chênh lệch', balance, balance >= 0 ? Colors.blue : Colors.orange, Icons.account_balance_wallet),
                  ];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 520) {
                        return Column(
                          key: const ValueKey('dashboard-summary-column'),
                          children: cards
                              .map((card) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: SizedBox(width: double.infinity, child: card),
                                  ))
                              .toList(),
                        );
                      }
                      return Row(
                        key: const ValueKey('dashboard-summary-row'),
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 8),
                          Expanded(child: cards[1]),
                          const SizedBox(width: 8),
                          Expanded(child: cards[2]),
                        ],
                      );
                    },
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final viewAllButton = TextButton(
                    onPressed: () => context.go('/transactions'),
                    child: const Text('Xem tất cả'),
                  );
                  if (constraints.maxWidth < 360) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Giao dịch gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Align(alignment: Alignment.centerRight, child: viewAllButton),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      const Expanded(
                        child: Text('Giao dịch gần đây', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      viewAllButton,
                    ],
                  );
                },
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
    return Container(
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
    );
  }
}
