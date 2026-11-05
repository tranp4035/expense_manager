import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/transaction_provider.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final int transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionByIdProvider(transactionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Giao dịch')),
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (tx) {
          if (tx == null) return const Center(child: Text('Không tìm thấy giao dịch'));

          final isIncome = tx.type == 'income';
          final color = isIncome ? Colors.green : Colors.red;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HERO ANIMATION CHO ICON
                Center(
                  child: Hero(
                    tag: 'tx-icon-${tx.id}',
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: color.withValues(alpha: 0.2),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: color,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // SỐ TIỀN
                Text(
                  '${isIncome ? '+' : '-'}${Formatters.formatCurrency(tx.amount)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 32),

                // THÔNG TIN CHI TIẾT
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Ngày giao dịch'),
                  subtitle: Text(Formatters.formatDate(tx.date)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text('Ghi chú'),
                  subtitle: Text(tx.note?.isNotEmpty == true ? tx.note! : 'Không có'),
                ),
                const Divider(),
                
                // HÌNH ẢNH HÓA ĐƠN (Nếu có)
                if (tx.imagePath != null) ...[
                  const SizedBox(height: 16),
                  const Text('Hóa đơn đính kèm:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Hero Animation cho Hình ảnh (nếu có)
                  Hero(
                    tag: 'tx-image-${tx.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(tx.imagePath!), height: 200, fit: BoxFit.cover),
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}