import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/vehicles_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/firebase_storage_service.dart';
import 'vehicle_detail_screen.dart';

class VehiclesManagementScreen extends StatefulWidget {
  const VehiclesManagementScreen({super.key});

  @override
  State<VehiclesManagementScreen> createState() =>
      _VehiclesManagementScreenState();
}


class _VehiclesManagementScreenState extends State<VehiclesManagementScreen> {
  String _searchQuery = '';
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final Map<String, String> _vehicleImages = {};

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

    XFile? pickedImage;
    String? imageUrl = isEditing ? _vehicleImages[existing.id] : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(isEditing ? 'Sửa thông tin xe' : 'Thêm xe mới'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      pickedImage = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                      setStateDialog(() {});
                    },
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: pickedImage != null
                          ? FileImage(File(pickedImage!.path))
                          : (imageUrl != null ? NetworkImage(imageUrl) : null) as ImageProvider?,
                      child: pickedImage == null && imageUrl == null
                          ? const Icon(Icons.camera_alt, size: 32)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
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
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                String? uploadedUrl = imageUrl;
                if (pickedImage != null) {
                  uploadedUrl = await _storageService.uploadImage(File(pickedImage!.path), folder: 'vehicles');
                }
                final newVehicle = Vehicle(
                  id: isEditing ? existing.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  plate: plateCtrl.text.trim(),
                  model: modelCtrl.text.trim(),
                  ownerName: ownerCtrl.text.trim(),
                );
                if (uploadedUrl != null) {
                  setState(() {
                    _vehicleImages[newVehicle.id] = uploadedUrl!;
                  });
                }
                Navigator.pop(ctx);
                if (isEditing) {
                  provider.updateVehicle(newVehicle);
                } else {
                  provider.addVehicle(newVehicle);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã ${isEditing ? 'cập nhật' : 'thêm'} xe: ${newVehicle.plate}'),
                  ),
                );
              },
              child: Text(isEditing ? 'Lưu' : 'Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehiclesProvider>();
    final vehicles = provider.vehicles.where((v) {
      final q = _searchQuery.toLowerCase();
      return v.plate.toLowerCase().contains(q) ||
             v.model.toLowerCase().contains(q) ||
             v.ownerName.toLowerCase().contains(q);
    }).toList();

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo biển số, model, chủ xe...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadVehicles,
              child: vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('Không tìm thấy xe nào'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showAddEditDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm xe mới'),
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
                          itemCount: vehicles.length,
                          itemBuilder: (ctx, idx) {
                            final v = vehicles[idx];
                            return Dismissible(
                              key: ValueKey(v.id),
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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VehicleDetailScreen(
                                          vehicle: v,
                                          imageUrl: _vehicleImages[v.id],
                                        ),
                                      ),
                                    );
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
                                          backgroundImage: _vehicleImages[v.id] != null
                                              ? NetworkImage(_vehicleImages[v.id]!)
                                              : null,
                                          child: _vehicleImages[v.id] == null
                                              ? const Icon(Icons.directions_car, size: 32)
                                              : null,
                                        ),
                                        const SizedBox(width: 18),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(v.plate, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 4),
                                              Text('Model: ${v.model}', style: Theme.of(context).textTheme.bodyMedium),
                                              Text('Chủ: ${v.ownerName}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                              tooltip: 'Sửa',
                                              onPressed: () => _showAddEditDialog(context, v),
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
                                                );
                                                if (confirm == true) {
                                                  provider.deleteVehicle(v.id);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Đã xóa xe: ${v.plate}')),
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