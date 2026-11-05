# Ứng dụng Quản lý Chi tiêu Cá nhân (Flutter)

**Môn học:** Các Công nghệ Lập trình Hiện đại  
**Sinh viên thực hiện:** 
1. Trần Tiến Phát - 3122410298
2. Nguyễn Phước Hòa Lâm - 3123410193
3. Trần Ngọc Thái Sơn - 3122410361
4. Phạm Anh Thư - 3120410518
**Giảng viên hướng dẫn:** Phạm Thi Vương

---

## 1. Giới thiệu
Ứng dụng Quản lý Chi tiêu Cá nhân là một ứng dụng di động được phát triển bằng **Flutter**, giúp người dùng dễ dàng ghi chép, theo dõi và quản lý các khoản thu/chi hàng ngày. Ứng dụng hoạt động hoàn toàn ngoại tuyến (offline), lưu trữ dữ liệu cục bộ trên thiết bị, đảm bảo tính riêng tư và tốc độ phản hồi nhanh.

### Các chức năng chính:
- **Tổng quan:** Xem tổng thu, tổng chi, chênh lệch theo tháng. Biểu đồ tròn phân bổ chi tiêu.
- **Giao dịch:** Thêm/Xóa giao dịch, đính kèm ảnh hóa đơn. Lọc theo tháng.
- **Ngân sách:** Đặt hạn mức chi tiêu theo danh mục, hiển thị thanh tiến độ đổi màu và cảnh báo khi vượt hạn mức.
- **Cài đặt:** Quản lý danh mục thu/chi (Thêm/Xóa).

---

## 2. Công nghệ sử dụng
- **Framework:** Flutter (Dart)
- **Quản lý trạng thái:** Riverpod (cho dữ liệu toàn cục) + setState (cho form cục bộ)
- **Cơ sở dữ liệu:** SQLite (`sqflite`)
- **Điều hướng:** `go_router` (StatefulShellRoute)
- **Biểu đồ:** `fl_chart`
- **Xử lý phần cứng:** `image_picker`, `permission_handler`

---

## 3. Yêu cầu hệ thống
- **Flutter SDK:** `>=3.44.0` (hoặc phiên bản bạn đang dùng)
- **Dart SDK:** `>=3.12.0`
- **Hệ điều hành:** Windows, macOS, Linux, Android hoặc iOS.

---

## 4. Hướng dẫn cài đặt và chạy

### Bước 1: Cài đặt thư viện
Mở terminal tại thư mục gốc của dự án và chạy:
```bash
flutter pub get
```

### Bước 2: Chạy ứng dụng

Chạy trên Windows (khuyên dùng khi lập trình):
```bash
flutter run -d windows
```

Chạy trên Android (máy ảo hoặc điện thoại thật):
```bash
flutter run
```

### Bước 3: Chạy kiểm thử (Test)

Dự án có sẵn Unit Test và Widget Test. Chạy lệnh sau để kiểm tra:
```bash
flutter test
```

## 5. Kiến trúc dự án
Dự án được tổ chức theo mô hình phân lớp rõ ràng (Clean Architecture thu gọn):

```text
lib/
├── core/           # Database, Router, Theme, Utils (hàm thuần)
├── data/           # Models và Repositories (Giao tiếp SQLite)
├── providers/      # Riverpod (Quản lý trạng thái)
├── features/       # Giao diện (Dashboard, Transactions, Budgets, Settings)
├── widgets/        # Các widget dùng chung
└── main.dart       # Điểm khởi chạy ứng dụng
```

## 6. Bảng phủ yêu cầu môn học

Các tính năng dưới đây là minh chứng cho những yêu cầu Tầng 1, 2 và 3 của môn học.

### Tầng 1A — Lõi bắt buộc

| Yêu cầu | Minh chứng trong dự án |
|---|---|
| **Widget tree và giao diện khai báo** | `transaction_form_screen.dart` dùng `StatefulWidget` cho form và `StatelessWidget` cho các tile. |
| **Quản lý trạng thái và rebuild** | `flutter_riverpod` trong `lib/providers/` kết hợp `setState` trong form; `ref.watch` tự động rebuild khi dữ liệu thay đổi. |
| **Điều hướng** | `go_router` trong `lib/core/router/app_router.dart`; `StatefulShellRoute` giúp giữ trạng thái các tab. |

### Tầng 1B — Lưu trữ và plugin

| Yêu cầu | Minh chứng trong dự án |
|---|---|
| **Lưu trữ cục bộ** | `sqflite` với ba bảng `categories`, `transactions`, `budgets` và xử lý ràng buộc khóa ngoại. |
| **Future/Stream** | `AsyncNotifier` và `AsyncValue.when` xử lý ba trạng thái giao diện: Loading, Error và Data. |
| **Plugin** | Tích hợp `image_picker` để chụp ảnh và `permission_handler` để xin quyền. |

### Tầng 2 — Kỹ nghệ phần mềm

| Yêu cầu | Minh chứng trong dự án |
|---|---|
| **Git** | Quản lý mã nguồn với các nhánh tính năng (`feature/...`) và commit message rõ ràng. |
| **CI/CD** | GitHub Actions tự động hóa kiểm thử tại `.github/workflows/flutter_ci.yml`. |
| **Kiểm thử** | Unit Test cho `BudgetUtils` và `TransactionService`; Widget Test cho form giao dịch và kiểm tra responsive ở `test/widget/responsive_layout_test.dart`. |
| **Tài liệu** | README hướng dẫn và giới thiệu dự án. |

### Kiểm tra vòng đời và responsive

**Rà soát tài nguyên giao diện:**

| Tài nguyên | Vị trí | Cách giải phóng |
|---|---|---|
| `_amountController`, `_noteController` | `lib/features/transactions/transaction_form_screen.dart` | Hủy trong `State.dispose()`. |
| `_amountController` | `lib/features/budgets/budget_form_bottom_sheet.dart` | Hủy trong `State.dispose()`. |
| `nameController` | `lib/features/settings/category_management_screen.dart` | Hủy trong `finally` sau khi dialog đóng. |

Đã rà soát `lib/`: không có `AnimationController`, `ScrollController`, `PageController`, `FocusNode`, `StreamSubscription` hoặc đăng ký `.listen()` cần dọn dẹp.

**Kiểm tra co giãn giao diện:** widget test đặt chiều rộng màn hình ở 320, 768 và 1440 logical pixels. Trên màn hình hẹp, thẻ tổng quan xếp dọc, tiêu đề và nút xem tất cả chuyển thành hai hàng, còn nhãn ngân sách xếp dọc; trên tablet/desktop các nội dung này dùng hàng ngang. Form vẫn cuộn được và chú giải biểu đồ rút gọn số tiền dài để tránh tràn.

| Màn hình/kiểm tra | Test | Kích thước |
|---|---|---|
| Dashboard, thẻ tổng quan và giao dịch gần đây | `test/widget/responsive_layout_test.dart` | 320, 768, 1440 px |
| Thanh tiến độ ngân sách | `test/widget/responsive_layout_test.dart` | 320, 768, 1440 px |
| Form giao dịch và khả năng cuộn | `test/widget/responsive_layout_test.dart` | 320, 768, 1440 px |

**Kết quả kiểm tra ngày 05/11/2026:** `flutter test` pass toàn bộ 12 test; `flutter analyze` không có issue. Kiểm tra kích thước là widget test trong Flutter test runner, không thay thế việc chụp ảnh QA trên thiết bị thật.

### Tầng 3 — Phần cứng và quyền

**Xử lý quyền camera** trong `transaction_form_screen.dart`:

| Trạng thái | Hành vi |
|---|---|
| **Granted** | Mở camera để chụp ảnh. |
| **Denied** | Hiện hộp thoại giải thích và cho phép thử lại. |
| **Permanently denied** | Hiện hướng dẫn mở Cài đặt hệ thống bằng `openAppSettings`. |

---

## 7. Tài khoản và dữ liệu mẫu

- **Dữ liệu mẫu:** Ứng dụng tự động tạo sẵn các danh mục cơ bản như Ăn uống, Di chuyển và Lương trong lần chạy đầu tiên.
- **Tài khoản:** Không yêu cầu đăng nhập.
