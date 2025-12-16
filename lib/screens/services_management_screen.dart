import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Service.dart';
import '../providers/services_provider.dart';

class ServicesManagementScreen extends StatefulWidget {
  const ServicesManagementScreen({super.key});

  @override
  State<ServicesManagementScreen> createState() => _ServicesManagementScreenState();
}

class _ServicesManagementScreenState extends State<ServicesManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesProvider>().loadServices();
    });
  }

  void _showAddEditDialog(BuildContext context, [Service? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(text: existing?.price.toString() ?? '');
    final durationCtrl = TextEditingController(text: existing?.durationMinutes.toString() ?? '60');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    bool isActive = existing?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing != null ? 'Sửa dịch vụ' : 'Thêm dịch vụ mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên dịch vụ'),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Giá (đ)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: durationCtrl,
                  decoration: const InputDecoration(labelText: 'Thời gian (phút)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: isActive,
                  onChanged: (val) => setState(() => isActive = val ?? false),
                  title: const Text('Hoạt động'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                final provider = context.read<ServicesProvider>();
                final newService = Service(
                  id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? 0,
                  durationMinutes: int.tryParse(durationCtrl.text) ?? 60,
                  description: descCtrl.text,
                  isActive: isActive,
                );

                if (existing != null) {
                  provider.updateService(newService);
                } else {
                  provider.createService(newService);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ServicesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý dịch vụ'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.miscellaneous_services, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Chưa có dịch vụ nào'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: provider.services.length,
                  itemBuilder: (ctx, idx) {
                    final s = provider.services[idx];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.build, color: Colors.blue),
                        ),
                        title: Text(s.name),
                        subtitle: Text('${s.price.toStringAsFixed(0)}đ | ${s.durationMinutes}p'),
                        trailing: PopupMenuButton(
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              child: const Text('Sửa'),
                              onTap: () => _showAddEditDialog(context, s),
                            ),
                            PopupMenuItem(
                              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                              onTap: () {
                                provider.deleteService(s.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
