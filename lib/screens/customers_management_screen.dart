// screens/management/customers_management_screen.dart (Tối ưu hóa UI/UX)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customers_provider.dart';
import '../models/customer.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersProvider>().loadCustomers();
    });
  }

  // --- Các phương thức _showAddEditDialog và _confirmDelete giữ nguyên (đã cung cấp ở Bước 2) ---
  
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
                id: isEditing ? existingCustomer!.id : '', 
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('QL Khách hàng'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadCustomers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.person_add_alt),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadCustomers,
              child: provider.customers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('Chưa có khách hàng nào trong hệ thống.'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditDialog(context),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Thêm Khách hàng'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.customers.length,
                      itemBuilder: (ctx, index) {
                        final customer = provider.customers[index];
                        
                        // Sử dụng Dismissible (vuốt để xóa)
                        return Dismissible(
                          key: ValueKey(customer.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận Xóa'),
                                content: Text('Bạn có chắc chắn muốn xóa khách hàng "${customer.name}" không?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(ctx).pop(true), 
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              await provider.deleteCustomer(customer.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đã xóa khách hàng: ${customer.name}'),
                                ),
                              );
                            }
                          },
                          child: Card(
                            elevation: 4, // Đổ bóng nhẹ
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                radius: 24,
                                child: Text(customer.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              title: Text(customer.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(customer.phone),
                                    ],
                                  ),
                                  if (customer.email.isNotEmpty) 
                                    Row(
                                      children: [
                                        const Icon(Icons.email, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(customer.email),
                                      ],
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showAddEditDialog(context, customer),
                              ),
                              onTap: () {
                                // TODO: Điều hướng đến màn hình chi tiết Khách hàng
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}