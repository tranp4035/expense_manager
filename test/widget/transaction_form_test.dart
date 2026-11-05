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
    // 1. Tăng kích thước màn hình ảo để không bị tràn
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TransactionFormScreen(),
        ),
      ),
    );

    // 2. Nhập số tiền âm
    final amountField = find.byType(TextFormField).first;
    await tester.enterText(amountField, '-50000');
    
    // 3. Ẩn bàn phím ảo đi để không che nút bấm (Rất quan trọng)
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // 4. Cuộn xuống nút Lưu (nếu cần) và bấm
    final saveButton = find.text('LƯU GIAO DỊCH');
    await tester.scrollUntilVisible(
      saveButton,
      500.0,
      scrollable: find.byType(Scrollable).first,
    );
    
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // 5. Kiểm tra lỗi
    expect(find.text('Số tiền phải lớn hơn 0'), findsOneWidget);
  });
}