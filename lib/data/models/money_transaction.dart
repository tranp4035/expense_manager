class MoneyTransaction {
  final int? id;
  final int amount; // VND
  final String type; // 'income' hoặc 'expense'
  final int categoryId;
  final String date; //
  final String? note;
  final String? imagePath;

  const MoneyTransaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'date': date,
      'note': note,
      'imagePath': imagePath,
    };
  }

  factory MoneyTransaction.fromMap(Map<String, dynamic> map) {
    return MoneyTransaction(
      id: map['id'] as int?,
      amount: map['amount'] as int,
      type: map['type'] as String,
      categoryId: map['categoryId'] as int,
      date: map['date'] as String,
      note: map['note'] as String?,
      imagePath: map['imagePath'] as String?,
    );
  }

  MoneyTransaction copyWith({
    int? id,
    int? amount,
    String? type,
    int? categoryId,
    String? date,
    String? note,
    String? imagePath,
  }) {
    return MoneyTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}