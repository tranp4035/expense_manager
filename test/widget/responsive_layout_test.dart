import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager/data/models/category.dart';
import 'package:expense_manager/features/budgets/widgets/budget_progress_bar.dart';
import 'package:expense_manager/features/dashboard/dashboard_screen.dart';
import 'package:expense_manager/features/transactions/transaction_form_screen.dart';
import 'package:expense_manager/providers/category_provider.dart';
import 'package:expense_manager/providers/transaction_provider.dart';

void main() {
  group('Responsive layouts', () {
    testWidgets(
      'dashboard stacks summary cards on phone and rows them on tablet/desktop',
      (tester) async {
        for (final width in [320.0, 768.0, 1440.0]) {
          await _setViewport(tester, width: width, height: 900);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                transactionSummaryProvider.overrideWith(
                  (ref) async => {'income': 25000000, 'expense': 12500000},
                ),
                transactionListProvider.overrideWith((ref) async => []),
                expenseChartDataProvider.overrideWith(
                  (ref) async => [
                    {
                      'name': 'Danh mục chi tiêu có tên rất dài',
                      'color': '#F44336',
                      'total': 9876543210,
                    },
                    {
                      'name': 'Di chuyển',
                      'color': '#2196F3',
                      'total': 123456789,
                    },
                  ],
                ),
              ],
              child: const MaterialApp(home: DashboardScreen()),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Thu nhập'), findsOneWidget, reason: 'width=$width');
          expect(find.text('Chi tiêu'), findsOneWidget, reason: 'width=$width');
          expect(
            find.text('Chênh lệch'),
            findsOneWidget,
            reason: 'width=$width',
          );
          if (width < 520) {
            expect(
              find.byKey(const ValueKey('dashboard-summary-column')),
              findsOneWidget,
            );
          } else {
            expect(
              find.byKey(const ValueKey('dashboard-summary-row')),
              findsOneWidget,
            );
          }
          expect(
            tester.takeException(),
            isNull,
            reason: 'dashboard overflow at width=$width',
          );
        }
        _resetViewport(tester);
      },
    );

    testWidgets(
      'budget progress labels stack on phones and share a row on wider screens',
      (tester) async {
        for (final width in [320.0, 768.0, 1440.0]) {
          await _setViewport(tester, width: width, height: 600);
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(16),
                  child: BudgetProgressBar(
                    limitAmount: 123456789,
                    spentAmount: 98765432,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          if (width < 396) {
            expect(
              find.byKey(const ValueKey('budget-progress-stacked')),
              findsOneWidget,
            );
          } else {
            expect(
              find.byKey(const ValueKey('budget-progress-inline')),
              findsOneWidget,
            );
          }
          expect(
            tester.takeException(),
            isNull,
            reason: 'budget progress overflow at width=$width',
          );
        }
        _resetViewport(tester);
      },
    );

    testWidgets(
      'transaction form remains scrollable without overflow on phone, tablet, and desktop',
      (tester) async {
        for (final width in [320.0, 768.0, 1440.0]) {
          await _setViewport(tester, width: width, height: 720);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                categoriesByTypeProvider('expense').overrideWith(
                  (ref) async => const [
                    Category(id: 1, name: 'Ăn uống', type: 'expense'),
                  ],
                ),
              ],
              child: const MaterialApp(home: TransactionFormScreen()),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('LƯU GIAO DỊCH'),
            findsOneWidget,
            reason: 'width=$width',
          );
          expect(find.byType(Scrollable), findsWidgets);
          expect(
            tester.takeException(),
            isNull,
            reason: 'transaction form overflow at width=$width',
          );
        }
        _resetViewport(tester);
      },
    );
  });
}

Future<void> _setViewport(
  WidgetTester tester, {
  required double width,
  required double height,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  await tester.pump();
}

void _resetViewport(WidgetTester tester) {
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}
