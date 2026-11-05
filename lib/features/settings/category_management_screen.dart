import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category.dart';
import '../../providers/category_provider.dart';

// Provider lấy TẤT CẢ danh mục (cả thu nhập và chi tiêu)
final allCategoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final income = await repo.getCategoriesByType('income');
  final expense = await repo.getCategoriesByType('expense');
  return [...expense, ...income]; // Gộp chung lại thành 1 danh sách
});

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Danh mục')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('Chưa có danh mục nào'));
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isIncome = cat.type == 'income';
              final colorHex = cat.color ?? '#9E9E9E';
              final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.2),
                  child: Icon(isIncome ? Icons.add_circle : Icons.remove_circle, color: color),
                ),
                title: Text(cat.name),
                subtitle: Text(isIncome ? 'Thu nhập' : 'Chi tiêu'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref, cat),
                ),
              );
            },
          );
        },
      ),
      // Nút thêm danh mục mới
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddCategoryDialog(context, ref),
      ),
    );
  }

  // === HÀM XỬ LÝ XÓA (CÓ KIỂM TRA RÀNG BUỘC) ===
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Category cat) async {
    final repo = ref.read(categoryRepositoryProvider);
    
    // 1. Kiểm tra xem danh mục có đang được giao dịch nào tham chiếu không
    final hasTx = await repo.hasTransactions(cat.id!);
    
    if (hasTx) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Không thể xóa'),
            content: Text('Danh mục "${cat.name}" đang có giao dịch tham chiếu. Vui lòng xóa các giao dịch liên quan trước.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đã hiểu'))
            ],
          ),
        );
      }
      return; // Dừng lại, không cho xóa
    }

    // 2. Nếu không có giao dịch, hỏi xác nhận xóa
    if (!context.mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa danh mục "${cat.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Xóa', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      await repo.deleteCategory(cat.id!);
      // Load lại danh sách danh mục
      ref.invalidate(allCategoriesProvider);
      ref.invalidate(categoriesByTypeProvider); 
    }
  }

  // === HÀM HIỂN THỊ DIALOG THÊM DANH MỤC ===
  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String type = 'expense'; // Mặc định là chi tiêu

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Thêm Danh mục'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController, 
                  decoration: const InputDecoration(labelText: 'Tên danh mục')
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'expense', label: Text('Chi tiêu')),
                    ButtonSegment(value: 'income', label: Text('Thu nhập')),
                  ],
                  selected: {type},
                  onSelectionChanged: (val) => setState(() => type = val.first),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return; // Không cho lưu nếu tên trống

                  // Tạo danh mục mới với màu mặc định tùy theo loại
                  final newCat = Category(
                    name: name, 
                    type: type, 
                    color: type == 'income' ? '#4CAF50' : '#F44336' // Xanh cho thu, Đỏ cho chi
                  );
                  
                  await ref.read(categoryRepositoryProvider).insertCategory(newCat);
                  ref.invalidate(allCategoriesProvider); // Cập nhật lại list
                  if (context.mounted) Navigator.pop(context); // Đóng dialog
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        }
      ),
    );
  }
}