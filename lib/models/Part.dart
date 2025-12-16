// models/Part.dart

class Part {
  final String id;
  final String name;
  final String sku; // Mã SKU hoặc Part Number
  final double costPrice; // Giá nhập
  final double sellingPrice; // Giá bán
  final int stockQuantity; // Số lượng tồn kho
  final String supplier; // Nhà cung cấp
  final bool isActive;

  Part({
    required this.id,
    required this.name,
    required this.sku,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    this.supplier = '',
    this.isActive = true,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      costPrice: (json['costPrice'] as num).toDouble(),
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] as int,
      supplier: json['supplier'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'stockQuantity': stockQuantity,
      'supplier': supplier,
      'isActive': isActive,
    };
  }
  
  Part copyWith({
    String? id,
    String? name,
    String? sku,
    double? costPrice,
    double? sellingPrice,
    int? stockQuantity,
    String? supplier,
    bool? isActive,
  }) {
    return Part(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      supplier: supplier ?? this.supplier,
      isActive: isActive ?? this.isActive,
    );
  }
}