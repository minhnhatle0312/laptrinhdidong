// models/PartUsage.dart

class PartUsage {
  final String partId;
  final String partName; // Tên phụ tùng tại thời điểm sử dụng
  final double unitPrice; // Giá bán tại thời điểm sử dụng
  final int quantityUsed; // Số lượng đã dùng

  PartUsage({
    required this.partId,
    required this.partName,
    required this.unitPrice,
    required this.quantityUsed,
  });

  factory PartUsage.fromJson(Map<String, dynamic> json) {
    return PartUsage(
      partId: json['partId'] as String,
      partName: json['partName'] as String? ?? 'N/A',
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantityUsed: json['quantityUsed'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partId': partId,
      'partName': partName,
      'unitPrice': unitPrice,
      'quantityUsed': quantityUsed,
    };
  }

  // Tính tổng chi phí cho mục phụ tùng này
  double get totalCost => unitPrice * quantityUsed;
}