class TransactionRecord {
  final String id;
  final double amount;
  final DateTime date;
  final String method; // cash, card, online
  final String status;

  TransactionRecord({
    required this.id,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      TransactionRecord(
        id: json['id'].toString(),
        amount: (json['amount'] ?? 0).toDouble(),
        date: DateTime.parse(json['date']),
        method: json['method'] ?? 'cash',
        status: json['status'] ?? 'completed',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'date': date.toIso8601String(),
    'method': method,
    'status': status,
  };
}
