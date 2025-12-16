// screens/management/customers_management_screen.dart (Tối ưu hóa UI/UX)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customers_provider.dart';

class CustomersManagementScreen extends StatefulWidget {
  const CustomersManagementScreen({super.key});

  @override
  State<CustomersManagementScreen> createState() =>
      _CustomersManagementScreenState();
}

class _CustomersManagementScreenState extends State<CustomersManagementScreen> {
  void _showAddEditDialog(BuildContext context, [dynamic customer]) {
    // TODO: Implement add/edit dialog
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomersProvider>().loadCustomers();
    });
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
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        return GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 2 : 1,
                            childAspectRatio: isWide ? 2.8 : 1.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: provider.customers.length,
                          itemBuilder: (ctx, idx) {
                            final customer = provider.customers[idx];
                            return Dismissible(
                              key: ValueKey(customer.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xác nhận Xóa'),
                                    content: Text('Bạn có chắc chắn muốn xóa khách hàng "${customer.name}" không?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('Hủy'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                ) ?? false;
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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    // TODO: Điều hướng đến màn hình chi tiết Khách hàng
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.07),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 32,
                                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.08),
                                          child: Text(
                                            customer.name.isNotEmpty ? customer.name.substring(0, 1).toUpperCase() : '?',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                                          ),
                                        ),
                                        const SizedBox(width: 18),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(customer.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.phone, size: 15, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(customer.phone, style: Theme.of(context).textTheme.bodyMedium),
                                                ],
                                              ),
                                              if (customer.email.isNotEmpty)
                                                Row(
                                                  children: [
                                                    const Icon(Icons.email, size: 15, color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(customer.email, style: Theme.of(context).textTheme.bodyMedium),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                              tooltip: 'Sửa',
                                              onPressed: () => _showAddEditDialog(context, customer),
                                            ),
                                            const SizedBox(height: 4),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                              tooltip: 'Xóa',
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
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
                                                if (confirm == true) {
                                                  await provider.deleteCustomer(customer.id);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Đã xóa khách hàng: ${customer.name}')),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }
}