// screens/management/customers_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/animated_scaffold.dart';
import '../../providers/customers_provider.dart';
import '../../models/customer.dart';

class CustomersManagementScreen extends StatefulWidget {
  const CustomersManagementScreen({super.key});

  @override
  State<CustomersManagementScreen> createState() =>
      _CustomersManagementScreenState();
}

class _CustomersManagementScreenState extends State<CustomersManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Tải dữ liệu khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersProvider>().loadCustomers();
    });
  }

  // Phương thức hiển thị Dialog Thêm/Sửa Khách hàng
  void _showAddEditDialog(BuildContext context, [Customer? existingCustomer]) {
    final provider = context.read<CustomersProvider>();
    final isEditing = existingCustomer != null;

    final nameCtrl = TextEditingController(text: existingCustomer?.name ?? '');
    final phoneCtrl = TextEditingController(text: existingCustomer?.phone ?? '');
    final emailCtrl = TextEditingController(text: existingCustomer?.email ?? '');
    final addressCtrl =
        TextEditingController(text: existingCustomer?.address ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa thông tin Khách hàng' : 'Thêm Khách hàng mới'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Họ và tên'),
                  validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập SĐT' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập Email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Địa chỉ'),
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

              final Customer customerData = Customer(
                // SỬA: Nếu đang sửa, giữ nguyên ID; nếu thêm mới, dùng ID rỗng
                id: isEditing ? existingCustomer.id : '',
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                address: addressCtrl.text.trim(),
              );

              Navigator.pop(ctx);
              
              if (isEditing) {
                await provider.updateCustomer(customerData);
              } else {
                await provider.addCustomer(customerData);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${isEditing ? 'Cập nhật' : 'Thêm mới'} khách hàng ${customerData.name} thành công!',
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
  void _confirmDelete(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Xóa'),
        content: Text('Bạn có chắc chắn muốn xóa khách hàng "${customer.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<CustomersProvider>().deleteCustomer(customer.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa khách hàng: ${customer.name}'),
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
    final provider = context.watch<CustomersProvider>();

    return AnimatedScaffold(
      title: 'QL Khách hàng',
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: provider.loadCustomers,
        ),
        IconButton(
          icon: const Icon(Icons.person_add_alt),
          onPressed: () => _showAddEditDialog(context),
        ),
      ],
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.customers.isEmpty
              ? const Center(child: Text('Chưa có khách hàng nào trong hệ thống.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.customers.length,
                  itemBuilder: (ctx, index) {
                    final customer = provider.customers[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(customer.name.isNotEmpty ? customer.name.substring(0, 1) : '?'),
                        ),
                        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SĐT: ${customer.phone}'),
                            if (customer.email.isNotEmpty) 
                              Text(
                                'Email: ${customer.email}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                              ),
                            if (customer.address.isNotEmpty)
                              Text(
                                'Địa chỉ: ${customer.address}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddEditDialog(context, customer);
                            } else if (value == 'delete') {
                              _confirmDelete(context, customer);
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
                          // TODO: Điều hướng đến màn hình chi tiết Khách hàng (nếu cần)
                        },
                      ),
                    );
                  },
                ),
    );
  }
}