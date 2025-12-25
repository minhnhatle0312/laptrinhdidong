import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../services/product_firestore.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _importPriceCtrl = TextEditingController();
  final _sellPriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  
  final _firestore = ProductFirestore();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _codeCtrl.text = p.code;
      _importPriceCtrl.text = p.importPrice.toStringAsFixed(0);
      _sellPriceCtrl.text = p.sellPrice.toStringAsFixed(0);
      _quantityCtrl.text = p.quantity.toString();
      _unitCtrl.text = p.unit;
    }
  }

  Future<void> _save() async {
    // Validate cơ bản
    if (_nameCtrl.text.isEmpty || _sellPriceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Tên và Giá bán')),
      );
      return;
    }

    final product = Product(
      id: widget.product?.id ?? _uuid.v4(),
      name: _nameCtrl.text,
      // Nếu không nhập mã, tự sinh mã ngẫu nhiên
      code: _codeCtrl.text.isEmpty ? 'AUTO-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}' : _codeCtrl.text,
      importPrice: double.tryParse(_importPriceCtrl.text) ?? 0,
      sellPrice: double.tryParse(_sellPriceCtrl.text) ?? 0,
      quantity: int.tryParse(_quantityCtrl.text) ?? 0,
      unit: _unitCtrl.text.isEmpty ? 'Cái' : _unitCtrl.text,
    );

    if (widget.product == null) {
      await _firestore.addProduct(product);
    } else {
      await _firestore.updateProduct(product);
    }

    if (mounted) context.pop();
  }

  // Nút xóa (chỉ hiện khi đang sửa)
  Future<void> _delete() async {
    if (widget.product == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa sản phẩm này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _firestore.deleteProduct(widget.product!.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Nhập hàng mới' : 'Sửa sản phẩm'),
        actions: [
          if (widget.product != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _delete,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput('Tên sản phẩm *', _nameCtrl, Icons.shopping_bag_outlined),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInput('Mã SP', _codeCtrl, Icons.qr_code)),
                const SizedBox(width: 16),
                Expanded(child: _buildInput('Đơn vị (Cái/Lít)', _unitCtrl, Icons.straighten)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInput('Giá nhập', _importPriceCtrl, Icons.arrow_downward, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildInput('Giá bán *', _sellPriceCtrl, Icons.arrow_upward, isNumber: true)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInput('Số lượng tồn *', _quantityCtrl, Icons.inventory, isNumber: true),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Lưu Kho'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}