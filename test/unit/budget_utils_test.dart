import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager/core/utils/budget_utils.dart';

void main() {
  group('Kiểm tra hàm getBudgetColor', () {
    test('Trả về màu xanh lá khi phần trăm dưới 70%', () {
      expect(BudgetUtils.getBudgetColor(0.0), Colors.green);
      expect(BudgetUtils.getBudgetColor(0.5), Colors.green);
      expect(BudgetUtils.getBudgetColor(0.69), Colors.green);
    });

    test('Trả về màu cam khi phần trăm từ 70% đến 90%', () {
      expect(BudgetUtils.getBudgetColor(0.7), Colors.orange);
      expect(BudgetUtils.getBudgetColor(0.8), Colors.orange);
      expect(BudgetUtils.getBudgetColor(0.9), Colors.orange);
    });

    test('Trả về màu đỏ khi phần trăm trên 90%', () {
      expect(BudgetUtils.getBudgetColor(0.91), Colors.red);
      expect(BudgetUtils.getBudgetColor(1.0), Colors.red);
      expect(BudgetUtils.getBudgetColor(1.5), Colors.red);
    });
  });
}