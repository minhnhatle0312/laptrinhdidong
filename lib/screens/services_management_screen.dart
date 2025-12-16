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
          title: const Text('Quản lý Dịch vụ'),
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
                        itemCount: provider.services.length,
                        itemBuilder: (ctx, idx) {
                          final s = provider.services[idx];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {},
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
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.build, color: Colors.blue, size: 32),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Text('${s.price} VNĐ', style: Theme.of(context).textTheme.bodyMedium),
                                          if (s.description != null && s.description!.isNotEmpty)
                                            Text(s.description ?? '', style: Theme.of(context).textTheme.bodySmall),
                                          Text(s.isActive ? 'Trạng thái: Đang hoạt động' : 'Trạng thái: Ngừng hoạt động',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: s.isActive ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                          onPressed: () => _showAddEditDialog(context, s),
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
                                                content: Text('Bạn có chắc chắn muốn xóa dịch vụ "${s.name}" không?'),
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
                                              provider.deleteService(s.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Đã xóa dịch vụ: ${s.name}')),
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
                          );
                        },
                      );
                    },
                  ),
    );
  }
}
