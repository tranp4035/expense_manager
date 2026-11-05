import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Quản lý danh mục'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Điều hướng sang màn hình quản lý danh mục
              context.push('/settings/categories');
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Phiên bản ứng dụng'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}