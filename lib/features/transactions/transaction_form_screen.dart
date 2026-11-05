import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

import '../../data/models/money_transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart'; // Sẽ tạo ở dưới
import '../../providers/budget_provider.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  final int? transactionId; // Null nếu là Thêm mới
  const TransactionFormScreen({super.key, this.transactionId});

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  // State cục bộ (setState)
  String _type = 'expense';
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _loadTransactionData();
    }
  }

  Future<void> _loadTransactionData() async {
    final tx = await ref.read(transactionByIdProvider(widget.transactionId!).future);
    if (tx != null) {
      setState(() {
        _amountController.text = tx.amount.toString();
        _noteController.text = tx.note ?? '';
        _type = tx.type;
        _selectedCategoryId = tx.categoryId;
        _selectedDate = DateTime.parse(tx.date);
        _imagePath = tx.imagePath;
      });
    }
  }

  // === TẦNG 3: XỬ LÝ QUYỀN VÀ CAMERA ===
  Future<void> _handleTakePhoto() async {
    // 1. Xin quyền camera
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      // Đã cấp quyền -> Mở camera
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() => _imagePath = photo.path);
      }
    } else if (status.isDenied) {
      // Từ chối (nhưng chưa chọn "Không hỏi lại")
      if (mounted) {
        _showPermissionDialog(
          title: 'Cần quyền Camera',
          message: 'Ứng dụng cần quyền Camera để chụp hóa đơn. Bạn có muốn thử lại?',
          onRetry: _handleTakePhoto,
        );
      }
    } else if (status.isPermanentlyDenied) {
      // Từ chối vĩnh viễn -> Phải vào Cài đặt hệ thống
      if (mounted) {
        _showPermissionDialog(
          title: 'Quyền bị từ chối',
          message: 'Bạn đã từ chối quyền Camera. Vui lòng mở Cài đặt để bật lại.',
          onRetry: () => openAppSettings(),
          retryLabel: 'Mở Cài đặt',
        );
      }
    }
  }

  void _showPermissionDialog({required String title, required String message, required VoidCallback onRetry, String retryLabel = 'Thử lại'}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(onPressed: () { Navigator.pop(context); onRetry(); }, child: Text(retryLabel)),
        ],
      ),
    );
  }

  // Chọn ảnh từ thư viện (Không cần quyền Camera)
  Future<void> _handlePickFromGallery() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() => _imagePath = photo.path);
    }
  }

  // === LƯU GIAO DỊCH ===
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tx = MoneyTransaction(
        id: widget.transactionId,
        amount: int.parse(_amountController.text),
        type: _type,
        categoryId: _selectedCategoryId!,
        date: _selectedDate.toIso8601String(),
        note: _noteController.text.trim(),
        imagePath: _imagePath,
      );

      final repo = ref.read(transactionRepositoryProvider);
      if (widget.transactionId == null) {
        await repo.insertTransaction(tx);
      } else {
        await repo.updateTransaction(tx); // Cần thêm hàm này vào Repo
      }

      // Load lại danh sách
      ref.invalidate(transactionListProvider);
      ref.invalidate(transactionSummaryProvider);
      ref.invalidate(budgetListProvider); // Update luôn màn ngân sách

      // === KIỂM TRA CẢNH BÁO VƯỢT NGÂN SÁCH ===
      if (_type == 'expense') {
        final budgetData = await ref.read(budgetListProvider.future);
        for (var b in budgetData) {
          if (b['categoryId'] == _selectedCategoryId) {
            // Nếu tổng chi > hạn mức
            if ((b['spentAmount'] as int) > (b['limitAmount'] as int)) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('CẢNH BÁO: Danh mục "${b['categoryName']}" đã vượt hạn mức ngân sách!'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
              break;
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công!'), backgroundColor: Colors.green));
        context.pop(); // Quay lại màn hình trước
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_type));

    return Scaffold(
      appBar: AppBar(title: Text(widget.transactionId == null ? 'Thêm giao dịch' : 'Sửa giao dịch')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Chọn Thu nhập / Chi tiêu
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Chi tiêu'), icon: Icon(Icons.remove_circle)),
                ButtonSegment(value: 'income', label: Text('Thu nhập'), icon: Icon(Icons.add_circle)),
              ],
              selected: {_type},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _type = newSelection.first;
                  _selectedCategoryId = null; // Reset danh mục khi đổi loại
                });
              },
            ),
            const SizedBox(height: 16),

            // 2. Số tiền
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số tiền (VND)', prefixIcon: Icon(Icons.attach_money)),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền';
                final amount = int.tryParse(value);
                if (amount == null || amount <= 0) return 'Số tiền phải lớn hơn 0';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 3. Danh mục (Load động theo Thu/Chi)
            categoriesAsync.when(
              data: (cats) => DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Danh mục', prefixIcon: Icon(Icons.category)),
                items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
                validator: (val) => val == null ? 'Vui lòng chọn danh mục' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Lỗi tải danh mục: $e'),
            ),
            const SizedBox(height: 16),

            // 4. Ngày tháng
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Ngày giao dịch', prefixIcon: Icon(Icons.calendar_today)),
                child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),

            // 5. Ghi chú
            TextFormField(
              controller: _noteController,
              maxLength: 200,
              decoration: const InputDecoration(labelText: 'Ghi chú (tùy chọn)', prefixIcon: Icon(Icons.note)),
            ),
            const SizedBox(height: 16),

            // 6. Hình ảnh hóa đơn (Tầng 3)
            const Text('Hóa đơn đính kèm:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_imagePath != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_imagePath!), height: 150, width: double.infinity, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => setState(() => _imagePath = null),
                  ),
                ],
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Chụp ảnh'),
                    onPressed: _handleTakePhoto,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Thư viện'),
                    onPressed: _handlePickFromGallery,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 7. Nút Lưu
            ElevatedButton(
              onPressed: _isLoading ? null : _saveTransaction,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('LƯU GIAO DỊCH'),
            ),
          ],
        ),
      ),
    );
  }
}