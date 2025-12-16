// ignore_for_file: file_names

class Payment {
  final String id;
  final String ticketId;
  final String customerId;
  final double amount;
  final String method; // cash, transfer, momo, zalopay
  final String status; // pending, success, failed, refunded
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? notes;

  Payment({
    required this.id,
    required this.ticketId,
    required this.customerId,
    required this.amount,
    required this.method,
    this.status = 'pending',
    required this.createdAt,
    this.paidAt,
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String,
      customerId: json['customerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'customerId': customerId,
      'amount': amount,
      'method': method,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'notes': notes,
    };
  }
}
