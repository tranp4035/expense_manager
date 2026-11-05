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
    required TransactionRepository transactionRepository,
    required BudgetRepository budgetRepository,
  }) : _transactionRepository = transactionRepository,
       _budgetRepository = budgetRepository;

  final TransactionRepository _transactionRepository;
  final BudgetRepository _budgetRepository;

  /// Saves a transaction and returns the exceeded budget category, if any.
  Future<String?> saveTransaction({
    required MoneyTransaction transaction,
    required int month,
    required int year,
    required bool checkBudget,
  }) async {
    if (transaction.id == null) {
      await _transactionRepository.insertTransaction(transaction);
    } else {
      await _transactionRepository.updateTransaction(transaction);
    }

    if (!checkBudget) return null;

    final budgets = await _budgetRepository.getBudgetsWithSpent(month, year);
    for (final budget in budgets) {
      if (budget['categoryId'] == transaction.categoryId &&
          (budget['spentAmount'] as int) > (budget['limitAmount'] as int)) {
        return budget['categoryName'] as String;
      }
    }
    return null;
  }
}
