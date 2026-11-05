class MoneyTransaction {
  final int? id;
  final int amount; 
  final String type; 
  final int categoryId;
  final String date; // ISO8601
  final String? note;
  final String? imagePath;
    final String? categoryName; 

  const MoneyTransaction({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.imagePath,
    this.categoryName, 
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
      categoryName: map['categoryName'] as String?, // Lấy từ SQL
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
    String? categoryName,
  }) {
    return MoneyTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}