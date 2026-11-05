import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/selected_month_provider.dart';
import 'widgets/transaction_tile.dart';
import '../../../providers/budget_provider.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedMonthProvider);
    final txAsync = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Giao dịch (Tháng ${selectedDate.month}/${selectedDate.year})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
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
          )
        ],
      ),
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Đã xảy ra lỗi: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(transactionListProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Chưa có giao dịch nào trong tháng này', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          // CÓ DỮ LIỆU -> Hiển thị danh sách
          return ListView.separated(
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              
              // BỌC TRONG DISMISSIBLE ĐỂ VUỐT XÓA
              return Dismissible(
                key: Key(tx.id.toString()),
                direction: DismissDirection.endToStart, // Chỉ vuốt từ phải sang trái
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  // Hỏi xác nhận trước khi xóa
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false), 
                          child: const Text('Hủy')
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true), 
                          child: const Text('Xóa', style: TextStyle(color: Colors.red))
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  // Thực hiện xóa trong Database
                  final repo = ref.read(transactionRepositoryProvider);
                  await repo.deleteTransaction(tx.id!);
                  
                  // Load lại UI
                  ref.invalidate(transactionListProvider);
                  ref.invalidate(transactionSummaryProvider);
                  ref.invalidate(budgetListProvider); // Cập nhật cả ngân sách
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa giao dịch'), backgroundColor: Colors.green)
                    );
                  }
                },
                child: TransactionTile(
                  transaction: tx,
                  onTap: () {
                    // Chuyển sang màn hình chi tiết (Hero Animation)
                    context.push('/transactions/${tx.id}');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/transactions/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}