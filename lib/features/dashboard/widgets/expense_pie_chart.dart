import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class ExpensePieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const ExpensePieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu chi tiêu tháng này', style: TextStyle(color: Colors.grey)));
    }

    // Tính tổng chi tiêu
    final total = data.fold<int>(0, (sum, item) => sum + (item['total'] as int));

    return Row(
      children: [
        // Biểu đồ tròn bên trái
        Expanded(
          flex: 4,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: data.map((item) {
                final percent = (item['total'] as int) / total * 100;
                // Parse màu từ HEX string (VD: #FF5722) sang Color
                final colorHex = (item['color'] as String?) ?? '#9E9E9E';
                final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

                return PieChartSectionData(
                  value: (item['total'] as int).toDouble(),
                  title: '${percent.toStringAsFixed(0)}%',
                  color: color,
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),

        Expanded(
          flex: 5,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final colorHex = (item['color'] as String?) ?? '#9E9E9E';
              final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(item['total'] as int),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}