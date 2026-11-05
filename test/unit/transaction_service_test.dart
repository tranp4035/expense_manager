import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager/data/models/money_transaction.dart';
import 'package:expense_manager/data/repositories/budget_repository.dart';
import 'package:expense_manager/data/repositories/transaction_repository.dart';
import 'package:expense_manager/data/services/transaction_service.dart';

void main() {
  group('TransactionService.saveTransaction', () {
    late _RecordingTransactionRepository transactionRepository;
    late _RecordingBudgetRepository budgetRepository;
    late TransactionService service;

    setUp(() {
      transactionRepository = _RecordingTransactionRepository();
      budgetRepository = _RecordingBudgetRepository();
      service = TransactionService(
        transactionRepository: transactionRepository,
        budgetRepository: budgetRepository,
      );
    });

    test(
      'inserts a new transaction and skips budget lookup when disabled',
      () async {
        final transaction = _transaction();

        final warning = await service.saveTransaction(
          transaction: transaction,
          month: 11,
          year: 2026,
          checkBudget: false,
        );

        expect(warning, isNull);
        expect(transactionRepository.inserted, same(transaction));
        expect(transactionRepository.updated, isNull);
        expect(budgetRepository.queryCount, 0);
      },
    );

    test('updates an existing transaction', () async {
      final transaction = _transaction(id: 42);

      final warning = await service.saveTransaction(
        transaction: transaction,
        month: 11,
        year: 2026,
        checkBudget: false,
      );

      expect(warning, isNull);
      expect(transactionRepository.updated, same(transaction));
      expect(transactionRepository.inserted, isNull);
    });

    test(
      'returns the matching category when spending exceeds its limit',
      () async {
        final transaction = _transaction(categoryId: 7);
        budgetRepository.budgets = [
          {
            'categoryId': 7,
            'categoryName': 'Ăn uống',
            'spentAmount': 1200000,
            'limitAmount': 1000000,
          },
        ];

        final warning = await service.saveTransaction(
          transaction: transaction,
          month: 11,
          year: 2026,
          checkBudget: true,
        );

        expect(warning, 'Ăn uống');
        expect(budgetRepository.requestedMonth, 11);
        expect(budgetRepository.requestedYear, 2026);
      },
    );

    test('does not warn when spending equals the limit or belongs to another category', () async {
      final transaction = _transaction(categoryId: 7);
      budgetRepository.budgets = [
        {
          'categoryId': 7,
          'categoryName': 'Ăn uống',
          'spentAmount': 1000000,
          'limitAmount': 1000000,
        },
        {
          'categoryId': 8,
          'categoryName': 'Di chuyển',
          'spentAmount': 2000000,
          'limitAmount': 1000000,
        },
      ];

      final warning = await service.saveTransaction(
        transaction: transaction,
        month: 11,
        year: 2026,
        checkBudget: true,
      );

      expect(warning, isNull);
      expect(budgetRepository.queryCount, 1);
    });
  });
}

MoneyTransaction _transaction({int? id, int categoryId = 7}) {
  return MoneyTransaction(
    id: id,
    amount: 100000,
    type: 'expense',
    categoryId: categoryId,
    date: '2026-11-05T00:00:00.000',
  );
}

class _RecordingTransactionRepository extends TransactionRepository {
  MoneyTransaction? inserted;
  MoneyTransaction? updated;

  @override
  Future<int> insertTransaction(MoneyTransaction transaction) async {
    inserted = transaction;
    return 1;
  }

  @override
  Future<int> updateTransaction(MoneyTransaction transaction) async {
    updated = transaction;
    return 1;
  }
}

class _RecordingBudgetRepository extends BudgetRepository {
  List<Map<String, dynamic>> budgets = [];
  int queryCount = 0;
  int? requestedMonth;
  int? requestedYear;

  @override
  Future<List<Map<String, dynamic>>> getBudgetsWithSpent(
    int month,
    int year,
  ) async {
    queryCount++;
    requestedMonth = month;
    requestedYear = year;
    return budgets;
  }
}
