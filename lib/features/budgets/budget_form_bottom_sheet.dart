import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/budget.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/selected_month_provider.dart';

class BudgetFormBottomSheet extends ConsumerStatefulWidget {
  const BudgetFormBottomSheet({super.key});

  @override
  ConsumerState<BudgetFormBottomSheet> createState() => _BudgetFormBottomSheetState();
}

class _BudgetFormBottomSheetState extends ConsumerState<BudgetFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _selectedCategoryId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider('expense'));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Thêm Ngân sách', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            
            categoriesAsync.when(
              data: (cats) => DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Chọn danh mục chi tiêu'),
                items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (val) => val == null ? 'Bắt buộc chọn danh mục' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Lỗi: $e'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Hạn mức (VND)'),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Nhập hạn mức';
                final amount = int.tryParse(val);
                if (amount == null || amount <= 0) return 'Hạn mức phải lớn hơn 0';
                return null;
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _saveBudget,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('LƯU NGÂN SÁCH'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final selectedDate = ref.read(selectedMonthProvider);
      final budget = Budget(
        categoryId: _selectedCategoryId!,
        limitAmount: int.parse(_amountController.text),
        month: selectedDate.month,
        year: selectedDate.year,
      );

      await ref.read(budgetRepositoryProvider).insertBudget(budget);
      
      ref.invalidate(budgetListProvider); // Load lại danh sách
      if (mounted) Navigator.pop(context); // Đóng bottom sheet
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}