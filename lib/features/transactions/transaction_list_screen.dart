import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/selected_month_provider.dart';
import 'widgets/transaction_tile.dart';

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
          // Nút đổi tháng (sẽ làm logic sau, tạm thời in ra console)
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              // Hiển thị DatePicker, mặc định chọn ngày đầu tháng hiện tại
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime(selectedDate.year, selectedDate.month, 1),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                helpText: 'Chọn tháng muốn xem',
              );
              
              if (pickedDate != null) {
                // Cập nhật Provider, toàn bộ app sẽ tự load lại theo tháng mới
                ref.read(selectedMonthProvider.notifier).changeMonth(pickedDate.month, pickedDate.year);
              }
            },
          )

        ],
      ),
      body: txAsync.when(
        // 1. TRẠNG THÁI LOADING
        loading: () => const Center(child: CircularProgressIndicator()),
        
        // 2. TRẠNG THÁI ERROR
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
        
        // 3. TRẠNG THÁI DATA (Có dữ liệu hoặc Rỗng)
        data: (transactions) {
          if (transactions.isEmpty) {
            // TRẠNG THÁI EMPTY
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
              return TransactionTile(
                transaction: tx,
                onTap: () {
                  context.push('/transactions/${tx.id}');
                },
              );
            },
          );
        },
      ),
      // Nút Thêm giao dịch (+)
            floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/transactions/add');
        },
        child: const Icon(Icons.add),
      ),

    );
  }
}