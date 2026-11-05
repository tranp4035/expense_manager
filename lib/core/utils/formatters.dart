import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
  
  static String formatCurrency(int amount) {
    return _currencyFormat.format(amount);
  }

  static String formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return DateFormat('dd/MM/yyyy').format(date);
  }
}