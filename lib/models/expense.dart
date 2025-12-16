class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? note;
  final String? imageUrl;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
    this.imageUrl,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        date: DateTime.parse(json['date']),
        category: json['category'] ?? '',
        note: json['note'],
        imageUrl: json['imageUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
        'note': note,
        'imageUrl': imageUrl,
      };
}
