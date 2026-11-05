import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_manager/features/transactions/transaction_form_screen.dart';

void main() {
  testWidgets('Kiểm tra Form báo lỗi khi để trống số tiền', (WidgetTester tester) async {
    // 1. Dựng màn hình Form trong môi trường test
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TransactionFormScreen(),
        ),
      ),
    );

    // 2. Tìm nút "LƯU GIAO DỊCH" và bấm vào
    final saveButton = find.text('LƯU GIAO DỊCH');
    expect(saveButton, findsOneWidget); // Đảm bảo nút có tồn tại
    
    await tester.tap(saveButton);
    await tester.pumpAndSettle(); // Chờ UI cập nhật sau khi bấm

    // 3. Kiểm tra xem dòng chữ báo lỗi có xuất hiện không
    expect(find.text('Vui lòng nhập số tiền'), findsOneWidget);
  });

  testWidgets('Kiểm tra Form báo lỗi khi nhập số tiền âm', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TransactionFormScreen(),
        ),
      ),
    );

    // 1. Nhập số tiền âm vào ô TextFormField đầu tiên (ô số tiền)
    // Lưu ý: Cần tìm chính xác ô nhập tiền, ở đây ta tìm theo label hoặc vị trí
    final amountField = find.byType(TextFormField).first;
    await tester.enterText(amountField, '-50000');

    // 2. Bấm nút Lưu
    await tester.tap(find.text('LƯU GIAO DỊCH'));
    await tester.pumpAndSettle();

    // 3. Kiểm tra thông báo lỗi
    expect(find.text('Số tiền phải lớn hơn 0'), findsOneWidget);
  });
}