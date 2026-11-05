import 'package:flutter/material.dart';
import '../../../data/models/money_transaction.dart';
import '../../../core/utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final MoneyTransaction transaction;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    
    return ListTile(
      onTap: onTap,
      leading: Hero(
        tag: 'tx-icon-${transaction.id}',
        child: CircleAvatar(
          backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),

      title: Text(
        transaction.note?.isNotEmpty == true ? transaction.note! : 'Không có ghi chú',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('Danh mục ${transaction.categoryId} • ${Formatters.formatDate(transaction.date)}'),
      trailing: Text(
        '${isIncome ? '+' : '-'}${Formatters.formatCurrency(transaction.amount)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}