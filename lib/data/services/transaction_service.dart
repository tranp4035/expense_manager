import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/money_transaction.dart';
import '../repositories/budget_repository.dart';
import '../repositories/transaction_repository.dart';

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(
    transactionRepository: TransactionRepository(),
    budgetRepository: BudgetRepository(),
  );
});

/// Holds transaction write and budget-warning rules outside the presentation layer.
class TransactionService {
  const TransactionService({
    required this.transactionRepository,
    required this.budgetRepository,
  });

  final TransactionRepository transactionRepository;
  final BudgetRepository budgetRepository;

  /// Saves a transaction and returns the exceeded budget category, if any.
  Future<String?> saveTransaction({
    required MoneyTransaction transaction,
    required int month,
    required int year,
    required bool checkBudget,
  }) async {
    if (transaction.id == null) {
      await transactionRepository.insertTransaction(transaction);
    } else {
      await transactionRepository.updateTransaction(transaction);
    }

    if (!checkBudget) return null;

    final budgets = await budgetRepository.getBudgetsWithSpent(month, year);
    for (final budget in budgets) {
      if (budget['categoryId'] == transaction.categoryId &&
          (budget['spentAmount'] as int) > (budget['limitAmount'] as int)) {
        return budget['categoryName'] as String;
      }
    }
    return null;
  }
}
