import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/transactions/transaction_list_screen.dart';
import '../../features/budgets/budget_list_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/transactions/transaction_form_screen.dart';
import '../../features/settings/category_management_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Tổng quan
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Tab 2: Giao dịch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionListScreen(),
              routes: [
                // Route Thêm giao dịch
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const TransactionFormScreen(),
                ),
                // Route Sửa giao dịch
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) {
                    final id = state.pathParameters['id'];
                    // Tạm thời truyền ID vào, xử lý lấy data ở trong form
                    return TransactionFormScreen(transactionId: int.parse(id!));
                  },
                ),
              ],
            ),
          ],
        ),

        // Tab 3: Ngân sách
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/budgets',
              builder: (context, state) => const BudgetListScreen(),
            ),
          ],
        ),
        // Tab 4: Cài đặt
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            routes: [
                // Thêm route con này để mở màn hình Quản lý danh mục
                GoRoute(
                  path: 'categories',
                  builder: (context, state) => const CategoryManagementScreen(),
                ),
              ],  
            ),
          ],
        ),
      ],
    ),
  ],
);

// Widget chứa Bottom Navigation Bar
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          // Điều hướng đến tab được chọn
          navigationShell.goBranch(
            index,
            // Nếu đang ở tab đó mà bấm lại thì reset về màn hình gốc của tab
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Tổng quan'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Ngân sách'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}