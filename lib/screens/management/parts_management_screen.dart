// screens/management/parts_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/Part.dart';
import '../../providers/parts_provider.dart';

class PartsManagementScreen extends StatefulWidget {
  const PartsManagementScreen({super.key});

  @override
  State<PartsManagementScreen> createState() => _PartsManagementScreenState();
}

class _PartsManagementScreenState extends State<PartsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartsProvider>().loadParts();
    });
  }

  void _showAddEditDialog(BuildContext context, [Part? existingPart]) {
    final provider = context.read<PartsProvider>();
    final isEditing = existingPart != null;
    final formKey = GlobalKey<FormState>();

    final nameCtrl = TextEditingController(text: existingPart?.name ?? '');
    final skuCtrl = TextEditingController(text: existingPart?.sku ?? '');
    final costPriceCtrl = TextEditingController(text: existingPart?.costPrice.toStringAsFixed(0) ?? '');
    final sellingPriceCtrl = TextEditingController(text: existingPart?.sellingPrice.toStringAsFixed(0) ?? '');
    final stockCtrl = TextEditingController(text: existingPart?.stockQuantity.toString() ?? '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa thông tin Phụ tùng' : 'Thêm Phụ tùng mới'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên Phụ tùng'),
                  validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: skuCtrl,
                  decoration: const InputDecoration(labelText: 'Mã SKU/Part Number'),
                  validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập mã SKU' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: costPriceCtrl,
                  decoration: const InputDecoration(labelText: 'Giá nhập (VND)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Giá nhập không hợp lệ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: sellingPriceCtrl,
                  decoration: const InputDecoration(labelText: 'Giá bán (VND)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Giá bán không hợp lệ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: 'Số lượng Tồn kho'),
                  keyboardType: TextInputType.number,
                  validator: (v) => int.tryParse(v ?? '') == null ? 'Số lượng không hợp lệ' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              final newPart = Part(
                id: isEditing ? existingPart!.id : '', 
                name: nameCtrl.text.trim(),
                sku: skuCtrl.text.trim(),
                costPrice: double.parse(costPriceCtrl.text.trim()),
                sellingPrice: double.parse(sellingPriceCtrl.text.trim()),
                stockQuantity: int.parse(stockCtrl.text.trim()),
                isActive: existingPart?.isActive ?? true,
                supplier: existingPart?.supplier ?? '',
              );

              Navigator.pop(ctx);
              
              bool success;
              if (isEditing) {
                success = await provider.updatePart(newPart);
              } else {
                success = await provider.createPart(newPart);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Đã ${isEditing ? 'cập nhật' : 'thêm'} phụ tùng: ${newPart.name}'
                        : provider.errorMessage ?? 'Thao tác thất bại!',
                  ),
                ),
              );
            },
            child: Text(isEditing ? 'Lưu' : 'Thêm'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Part part) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Xóa'),
        content: Text('Bạn có chắc chắn muốn xóa phụ tùng "${part.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<PartsProvider>().deletePart(part.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa phụ tùng: ${part.name}')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PartsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Phụ tùng/Tồn kho'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadParts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadParts,
              child: provider.parts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('Kho không có phụ tùng nào.'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm Phụ tùng mới'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.parts.length,
                      itemBuilder: (ctx, idx) {
                        final part = provider.parts[idx];
                        final stockColor = part.stockQuantity < 10 
                            ? (part.stockQuantity == 0 ? Colors.red : Colors.orange)
                            : Colors.green;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: stockColor.withValues(alpha: 0.1),
                              foregroundColor: stockColor,
                              radius: 24,
                              child: const Icon(Icons.category),
                            ),
                            title: Text(part.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mã SKU: ${part.sku}', style: const TextStyle(fontSize: 12)),
                                Text('Giá bán: ${part.sellingPrice.toStringAsFixed(0)} đ'),
                                Text(
                                  'Tồn kho: ${part.stockQuantity}',
                                  style: TextStyle(color: stockColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showAddEditDialog(context, part);
                                } else if (value == 'delete') {
                                  _confirmDelete(context, part);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                                const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                            onTap: () {
                              // TODO: Điều hướng đến chi tiết phụ tùng/lịch sử nhập xuất
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}