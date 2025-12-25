class Product {
  final String id;
  final String name;       // Tên sản phẩm
  final String code;       // Mã sản phẩm (SKU)
  final double importPrice;// Giá nhập
  final double sellPrice;  // Giá bán
  final int quantity;      // Số lượng tồn kho
  final String unit;       // Đơn vị tính (Cái, Lít...)

  Product({
    required this.id,
    required this.name,
    required this.code,
    required this.importPrice,
    required this.sellPrice,
    required this.quantity,
    required this.unit,
  });

  // Chuyển đổi từ Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'importPrice': importPrice,
      'sellPrice': sellPrice,
      'quantity': quantity,
      'unit': unit,
    };
  }

  // Chuyển đổi từ Map (Firestore) về Object
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      importPrice: (map['importPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      unit: map['unit'] ?? '',
    );
  }

  // Helper để kiểm tra trạng thái kho
  bool get isOutOfStock => quantity <= 0;
  bool get isLowStock => quantity > 0 && quantity <= 5;
}