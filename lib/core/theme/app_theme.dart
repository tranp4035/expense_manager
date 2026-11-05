import 'package:flutter/material.dart';

class AppTheme {
  // Định nghĩa màu xanh biển nhạt chủ đạo
  static const Color primaryLightBlue = Color(0xFF00ACC1); // Màu Cyan/Teal nhạt
  static const Color backgroundWhite = Colors.white;

  static ThemeData get lightTheme {
    // Khởi tạo ColorScheme từ màu chủ đạo
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLightBlue,
      brightness: Brightness.light,
      // Ghi đè nền trắng để đảm bảo không bị ám màu xám
      surface: backgroundWhite, 
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundWhite, // Nền trắng sáng

      // Tùy chỉnh AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundWhite,
        foregroundColor: primaryLightBlue, // Chữ và icon màu xanh biển nhạt
        elevation: 0, // Phẳng, hiện đại
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryLightBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Tùy chỉnh Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: backgroundWhite,
        indicatorColor: primaryLightBlue.withValues(alpha: 0.15), // Vệt sáng khi chọn tab
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryLightBlue);
          }
          return const IconThemeData(color: Colors.grey);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primaryLightBlue, fontWeight: FontWeight.bold);
          }
          return const TextStyle(color: Colors.grey);
        }),
      ),

      // Tùy chỉnh các nút bấm (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLightBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Tùy chỉnh viền các ô nhập liệu
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLightBlue, width: 2),
        ),
      ),
    );
  }
}