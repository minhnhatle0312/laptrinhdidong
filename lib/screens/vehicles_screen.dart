import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ĐÃ SỬA: Đổi từ cars_provider.dart sang vehicles_provider.dart
import '../providers/vehicles_provider.dart'; 
import '../models/vehicle.dart';

// ĐÃ SỬA: Chuyển thành StatefulWidget để quản lý vòng đời và tải dữ liệu
class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  
  @override
  void initState() {
    super.initState();
    // THÊM LOGIC: Tải dữ liệu khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehiclesProvider>(context, listen: false).loadVehicles();
    });
  }

  // Giữ nguyên phương thức hiển thị dialog thêm xe
  Future<void> _showAddVehicle(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final plateCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final ownerCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm xe mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: plateCtrl,
              decoration: const InputDecoration(labelText: 'Biển số'),
            ),
            TextField(
              controller: modelCtrl,
              decoration: const InputDecoration(labelText: 'Model'),
            ),
            TextField(
              controller: ownerCtrl,
              decoration: const InputDecoration(labelText: 'Chủ sở hữu'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final plate = plateCtrl.text.trim();
              final model = modelCtrl.text.trim();
              final owner = ownerCtrl.text.trim();
              if (plate.isEmpty) return;
              final v = Vehicle(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                plate: plate,
                model: model,
                ownerName: owner,
              );
              // LƯU Ý: addVehicle hiện tại là logic mock (local)
              Provider.of<VehiclesProvider>(
                context,
                listen: false,
              ).addVehicle(v);
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result == true) {
      messenger.showSnackBar(const SnackBar(content: Text('Đã thêm xe')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<VehiclesProvider>(context);
    final vehicles = prov.vehicles;

    // THÊM LOGIC: Hiển thị CircularProgressIndicator khi đang tải dữ liệu
    if (prov.isLoading && vehicles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quản lý xe')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // THÊM LOGIC: Xử lý trường hợp không có dữ liệu sau khi tải xong
    if (!prov.isLoading && vehicles.isEmpty) {
        return Scaffold(
        appBar: AppBar(title: const Text('Quản lý xe')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Chưa có xe nào. Vui lòng thêm xe để quản lý.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showAddVehicle(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm xe ngay'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý xe')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text('Xe đã lưu: ${vehicles.length}')),
                ElevatedButton.icon(
                  onPressed: () => _showAddVehicle(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm xe'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (ctx, i) {
                  final v = vehicles[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text(v.plate),
                      subtitle: Text('${v.model} — ${v.ownerName}'),
                      // TODO: Thêm các nút Edit/Delete tại đây
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}