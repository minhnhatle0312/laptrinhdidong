import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/vehicles_provider.dart';

class VehiclesManagementScreen extends StatefulWidget {
  const VehiclesManagementScreen({super.key});

  @override
  State<VehiclesManagementScreen> createState() =>
      _VehiclesManagementScreenState();
}

class _VehiclesManagementScreenState extends State<VehiclesManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiclesProvider>().loadVehicles();
    });
  }

  // Giữ nguyên phương thức _showAddEditDialog
  void _showAddEditDialog(BuildContext context, [Vehicle? existing]) {
    final provider = context.read<VehiclesProvider>();
    final isEditing = existing != null;
    final formKey = GlobalKey<FormState>();

    final plateCtrl = TextEditingController(text: existing?.plate ?? '');
    final modelCtrl = TextEditingController(text: existing?.model ?? '');
    final ownerCtrl = TextEditingController(text: existing?.ownerName ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa thông tin xe' : 'Thêm xe mới'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: plateCtrl,
                  decoration: const InputDecoration(labelText: 'Biển số xe'),
                  validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập biển số' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: modelCtrl,
                  decoration: const InputDecoration(labelText: 'Loại xe / Model'),
                  validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập loại xe' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ownerCtrl,
                  decoration: const InputDecoration(labelText: 'Chủ sở hữu'),
                  validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập tên chủ sở hữu' : null,
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
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              
              final newVehicle = Vehicle(
                id: isEditing ? existing!.id : DateTime.now().millisecondsSinceEpoch.toString(), 
                plate: plateCtrl.text.trim(),
                model: modelCtrl.text.trim(),
                ownerName: ownerCtrl.text.trim(),
              );

              Navigator.pop(ctx);
              
              if (isEditing) {
                provider.updateVehicle(newVehicle); 
              } else {
                provider.addVehicle(newVehicle);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã ${isEditing ? 'cập nhật' : 'thêm'} xe: ${newVehicle.plate}',
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
  
  // Giữ nguyên phương thức _confirmDelete
  void _confirmDelete(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Xóa Phương tiện'),
        content: Text('Bạn có chắc chắn muốn xóa xe "${vehicle.plate}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<VehiclesProvider>().deleteVehicle(vehicle.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa xe: ${vehicle.plate}'),
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
    final provider = context.watch<VehiclesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý xe'),
        elevation: 0,
        actions: [
           IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadVehicles,
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
              onRefresh: provider.loadVehicles,
              child: provider.vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('Chưa có xe nào'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm xe mới'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.vehicles.length,
                      itemBuilder: (ctx, idx) {
                        final v = provider.vehicles[idx];
                        return Dismissible(
                          key: ValueKey(v.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận Xóa'),
                                content: Text('Bạn có chắc chắn muốn xóa xe "${v.plate}" không?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ) ?? false;
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              provider.deleteVehicle(v.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã xóa xe: ${v.plate}')),
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                foregroundColor: Theme.of(context).primaryColor,
                                radius: 24,
                                child: const Icon(Icons.directions_car),
                              ),
                              title: Text(v.plate, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Model: ${v.model}'),
                                  Text('Chủ: ${v.ownerName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showAddEditDialog(context, v),
                              ),
                              onTap: () {
                                // TODO: Điều hướng đến chi tiết xe hoặc phiếu bảo dưỡng liên quan
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