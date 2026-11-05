import 'package:flutter/material.dart';
import '../../../core/utils/budget_utils.dart';
import '../../../core/utils/formatters.dart';

class BudgetProgressBar extends StatelessWidget {
  final int limitAmount;
  final int spentAmount;

  const BudgetProgressBar({super.key, required this.limitAmount, required this.spentAmount});

  @override
  Widget build(BuildContext context) {
    // Tính % (giới hạn tối đa là 1.0 để thanh tiến độ không bị tràn)
    final percent = limitAmount > 0 ? (spentAmount / limitAmount) : 0.0;
    final displayPercent = percent > 1.0 ? 1.0 : percent;
    final color = BudgetUtils.getBudgetColor(percent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final spentLabel = Text(
              'Đã chi: ${Formatters.formatCurrency(spentAmount)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            );
            final limitLabel = Text(
              'Hạn mức: ${Formatters.formatCurrency(limitAmount)}',
              style: const TextStyle(color: Colors.grey),
            );
            if (constraints.maxWidth < 380) {
              return Column(
                key: const ValueKey('budget-progress-stacked'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [spentLabel, const SizedBox(height: 4), limitLabel],
              );
            }
            return Row(
              key: const ValueKey('budget-progress-inline'),
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [spentLabel, limitLabel],
            );
          },
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: displayPercent,
            color: color,
            backgroundColor: color.withValues(alpha: 0.2),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text('${(percent * 100).toStringAsFixed(1)}%', style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
