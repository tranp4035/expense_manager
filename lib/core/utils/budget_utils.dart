import 'package:flutter/material.dart';

class BudgetUtils {
  // Trả về màu sắc dựa trên phần trăm sử dụng
  static Color getBudgetColor(double percent) {
    if (percent < 0.7) return Colors.green;
    if (percent <= 0.9) return Colors.orange;
    return Colors.red;
  }
}