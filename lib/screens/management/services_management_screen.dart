// screens/management/services_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/animated_scaffold.dart';
import '../../providers/services_provider.dart';
import '../../models/Service.dart';

class ServicesManagementScreen extends StatefulWidget {
  const ServicesManagementScreen({super.key});

  @override
  State<ServicesManagementScreen> createState() => _ServicesManagementScreenState();
}

class _ServicesManagementScreenState extends State<ServicesManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Tải dữ liệu khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().loadServices();
    });
  }

  // Phương thức hiển thị Dialog Thêm/Sửa Dịch vụ
  void _showAddEditDialog(BuildContext context, [Service? existingService]) {
    final provider = context.read<ServicesProvider>();
    final isEditing = existingService != null;

    final nameCtrl = TextEditingController(text: existingService?.name ?? '');
    final priceCtrl = TextEditingController(text: existingService?.price.toStringAsFixed(0) ?? '');
    final durationCtrl = TextEditingController(text: existingService?.durationMinutes.toString() ?? '');
    final descCtrl = TextEditingController(text: existingService?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa thông tin Dịch vụ' : 'Thêm Dịch vụ mới'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên Dịch vụ'),
                  validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập tên dịch vụ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Giá (VND)',
                    prefixText: 'đ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v?.isEmpty ?? true) || double.tryParse(v!) == null ? 'Vui lòng nhập giá hợp lệ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: durationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Thời gian thực hiện (Phút)',
                    suffixText: 'phút',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v?.isEmpty ?? true) || int.tryParse(v!) == null ? 'Vui lòng nhập thời gian hợp lệ' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả (Tùy chọn)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final Service serviceData = Service(
                id: isEditing ? existingService.id : '', // Firestore sẽ tạo ID nếu là thêm mới
                name: nameCtrl.text.trim(),
                price: double.parse(priceCtrl.text.trim()),
                durationMinutes: int.parse(durationCtrl.text.trim()),
                description: descCtrl.text.trim(),
              );

              Navigator.pop(ctx);
              
              bool success = false;
              if (isEditing) {
                success = await provider.updateService(serviceData);
              } else {
                success = await provider.createService(serviceData);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? '${isEditing ? 'Cập nhật' : 'Thêm mới'} dịch vụ ${serviceData.name} thành công.'
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

  // Phương thức xác nhận Xóa
  void _confirmDelete(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Xóa Dịch vụ'),
        content: Text('Bạn có chắc chắn muốn xóa dịch vụ "${service.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<ServicesProvider>().deleteService(service.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success 
                        ? 'Đã xóa dịch vụ: ${service.name}' 
                        : context.read<ServicesProvider>().errorMessage ?? 'Xóa dịch vụ thất bại!',
                  ),
                ),
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
    final provider = context.watch<ServicesProvider>();

    return AnimatedScaffold(
      title: 'QL Dịch vụ',
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: provider.loadServices,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _showAddEditDialog(context),
        ),
      ],
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.services.isEmpty
              ? const Center(child: Text('Chưa có dịch vụ nào trong hệ thống.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.services.length,
                  itemBuilder: (ctx, index) {
                    final service = provider.services[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                          foregroundColor: Theme.of(context).colorScheme.secondary,
                          child: const Icon(Icons.build),
                        ),
                        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giá: ${service.price.toStringAsFixed(0)} đ', 
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text('Thời gian: ${service.durationMinutes} phút'),
                            if (service.description?.isNotEmpty ?? false)
                              Text(
                                'Mô tả: ${service.description}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddEditDialog(context, service);
                            } else if (value == 'delete') {
                              _confirmDelete(context, service);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Sửa'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Xóa', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Tạm thời không làm gì
                        },
                      ),
                    );
                  },
                ),
    );
  }
}