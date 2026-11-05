import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDate {
  final int month;
  final int year;
  const SelectedDate({required this.month, required this.year});
}

class SelectedMonthNotifier extends Notifier<SelectedDate> {
  @override
  SelectedDate build() {
    final now = DateTime.now();
    return SelectedDate(month: now.month, year: now.year);
  }

  void changeMonth(int month, int year) {
    state = SelectedDate(month: month, year: year);
  }
}

final selectedMonthProvider = NotifierProvider<SelectedMonthNotifier, SelectedDate>(SelectedMonthNotifier.new);