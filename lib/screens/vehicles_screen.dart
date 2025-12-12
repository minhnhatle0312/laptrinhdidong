import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicles_provider.dart';
import '../models/vehicle.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

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
              child: vehicles.isEmpty
                  ? const Center(
                      child: Text('Chưa có xe nào. Thêm xe để tiếp tục.'),
                    )
                  : ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (ctx, i) {
                        final v = vehicles[i];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.directions_car),
                            title: Text(v.plate),
                            subtitle: Text('${v.model} — ${v.ownerName}'),
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
