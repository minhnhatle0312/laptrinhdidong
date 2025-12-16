import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parking_spot.dart';
import '../providers/parking_provider.dart';

class ParkingLocationsManagementScreen extends StatefulWidget {
  const ParkingLocationsManagementScreen({super.key});

  @override
  State<ParkingLocationsManagementScreen> createState() =>
      _ParkingLocationsManagementScreenState();
}

class _ParkingLocationsManagementScreenState
    extends State<ParkingLocationsManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Đảm bảo tải dữ liệu khi màn hình khởi tạo
      context.read<ParkingProvider>().loadSpots();
    });
  }

  void _showAddEditDialog(BuildContext context, [ParkingSpot? existing]) {
    final provider = context.read<ParkingProvider>();
    final isEditing = existing != null;
    final formKey = GlobalKey<FormState>();

    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final latCtrl = TextEditingController(text: existing?.lat.toString() ?? '');
    final lngCtrl = TextEditingController(text: existing?.lng.toString() ?? '');
    final priceCtrl = TextEditingController(
      text: existing?.pricePerHour.toStringAsFixed(0) ?? '',
    );
    // Trạng thái khả dụng (chỉ có thể sửa khi đang chỉnh sửa)
    bool isAvailable = existing?.isAvailable ?? true; 

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Sửa vị trí đỗ xe' : 'Thêm vị trí đỗ xe mới'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên bãi đỗ'),
                  validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập tên' : null,
                ),
                TextFormField(
                  controller: latCtrl,
                  decoration: const InputDecoration(labelText: 'Vĩ độ'),
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Vĩ độ không hợp lệ' : null,
                ),
                TextFormField(
                  controller: lngCtrl,
                  decoration: const InputDecoration(labelText: 'Kinh độ'),
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Kinh độ không hợp lệ' : null,
                ),
                TextFormField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Giá/giờ (VND)',
                    prefixText: 'đ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Giá không hợp lệ' : null,
                ),
                if (isEditing)
                  StatefulBuilder(builder: (sCtx, setState) {
                    return SwitchListTile(
                      title: const Text('Trạng thái Khả dụng'),
                      value: isAvailable,
                      onChanged: (val) {
                        setState(() => isAvailable = val);
                      },
                    );
                  }),
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
              
              final newSpot = ParkingSpot(
                id: isEditing ? existing!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text.trim(),
                lat: double.parse(latCtrl.text.trim()),
                lng: double.parse(lngCtrl.text.trim()),
                pricePerHour: double.parse(priceCtrl.text.trim()),
                isAvailable: isAvailable,
              );

              Navigator.pop(ctx);
              
              if (isEditing) {
                // SỬA: Gọi hàm update thực tế
                await provider.updateParkingSpot(newSpot); 
              } else {
                // SỬA: Gọi hàm add thực tế
                await provider.addParkingSpot(newSpot);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã ${isEditing ? 'cập nhật' : 'thêm'} bãi đỗ: ${newSpot.name}',
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
  void _confirmDelete(BuildContext context, ParkingSpot spot) {
    final provider = context.read<ParkingProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Xóa'),
        content: Text('Bạn có chắc chắn muốn xóa bãi đỗ "${spot.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              // SỬA: Gọi hàm delete thực tế
              await provider.deleteParkingSpot(spot.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa bãi đỗ: ${spot.name}'),
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
    final provider = context.watch<ParkingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý vị trí đỗ xe'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadSpots,
              child: provider.spots.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('Chưa có vị trí đỗ xe nào'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm bãi đỗ xe mới'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: provider.spots.length,
                      itemBuilder: (ctx, idx) {
                        final spot = provider.spots[idx];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(
                              Icons.location_on,
                              color: spot.isAvailable ? Colors.green : Colors.red,
                              size: 30,
                            ),
                            title: Text(spot.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${spot.lat.toStringAsFixed(4)}, ${spot.lng.toStringAsFixed(4)}'),
                                Text(
                                  'Giá: ${spot.pricePerHour.toStringAsFixed(0)}đ/h - Trạng thái: ${spot.isAvailable ? "Trống" : "Đã đặt"}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: spot.isAvailable ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showAddEditDialog(context, spot);
                                } else if (value == 'delete') {
                                  _confirmDelete(context, spot);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}