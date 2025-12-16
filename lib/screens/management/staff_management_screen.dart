// screens/management/staff_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/animated_scaffold.dart';
import '../../providers/staff_provider.dart';
import '../../models/Staff.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/firebase_storage_service.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}


class _StaffManagementScreenState extends State<StaffManagementScreen> {
  // Danh sách vị trí (position) cố định cho Staff
  final List<String> positions = ['mechanic', 'manager', 'admin'];
  // Danh sách chuyên môn (specialization) cố định
  final List<String> specializations = ['engine', 'transmission', 'electrical', 'bodywork', 'management', 'general'];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Tải dữ liệu khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StaffProvider>().loadStaff();
    });
  }

  // Phương thức hiển thị Dialog Thêm/Sửa Nhân viên
  void _showAddEditDialog(BuildContext context, [Staff? existingStaff]) {
    final provider = context.read<StaffProvider>();
    final isEditing = existingStaff != null;
    final formKey = GlobalKey<FormState>();

    final nameCtrl = TextEditingController(text: existingStaff?.name ?? '');
    final emailCtrl = TextEditingController(text: existingStaff?.email ?? '');
    final phoneCtrl = TextEditingController(text: existingStaff?.phone ?? '');

    String? photoUrl = existingStaff?.photoUrl;
    File? pickedImage;

    // Khởi tạo giá trị ban đầu cho Dropdown
    String currentPosition = existingStaff?.position ?? positions.first;
    String currentSpecialization = existingStaff?.specialization ?? specializations.first;
    bool isActive = existingStaff?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, setState) {
          Future<void> pickImage() async {
            final picker = ImagePicker();
            final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
            if (picked != null) {
              setState(() {
                pickedImage = File(picked.path);
              });
            }
          }

          Future<String?> uploadImage(File file) async {
            final storage = FirebaseStorageService();
            return await storage.uploadImage(file, folder: 'staff_avatars');
          }

          return AlertDialog(
            title: Text(isEditing ? 'Sửa thông tin Nhân viên' : 'Thêm Nhân viên mới'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: pickedImage != null
                            ? FileImage(pickedImage!)
                            : (photoUrl != null ? NetworkImage(photoUrl) as ImageProvider : null),
                        child: pickedImage == null && (photoUrl == null || photoUrl.isEmpty)
                            ? const Icon(Icons.camera_alt, size: 32)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Họ và tên'),
                      validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập tên' : null,
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
                      controller: phoneCtrl,
                      decoration: const InputDecoration(labelText: 'Số điện thoại'),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập SĐT' : null,
                    ),
                    const SizedBox(height: 12),
                    // Dropdown Vị trí
                    DropdownButtonFormField<String>(
                      initialValue: currentPosition,
                      decoration: const InputDecoration(labelText: 'Vị trí'),
                      items: positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => currentPosition = v!),
                    ),
                    const SizedBox(height: 12),
                    // Dropdown Chuyên môn
                    DropdownButtonFormField<String>(
                      initialValue: currentSpecialization,
                      decoration: const InputDecoration(labelText: 'Chuyên môn'),
                      items: specializations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => currentSpecialization = v!),
                    ),
                    const SizedBox(height: 12),
                    // Switch Trạng thái hoạt động
                    SwitchListTile(
                      title: const Text('Hoạt động'),
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
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

                  String? uploadedUrl = photoUrl;
                  if (pickedImage != null) {
                    uploadedUrl = await uploadImage(pickedImage!);
                  }

                  final Staff staffData = Staff(
                    id: isEditing ? existingStaff.id : '', // ID rỗng, Provider sẽ xử lý
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    position: currentPosition,
                    specialization: currentSpecialization,
                    isActive: isActive,
                    joinedAt: existingStaff?.joinedAt ?? DateTime.now(),
                    photoUrl: uploadedUrl,
                  );

                  Navigator.pop(ctx);
                  
                  bool success;
                  if (isEditing) {
                    success = await provider.updateStaff(staffData);
                  } else {
                    success = await provider.createStaff(staffData);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? '${isEditing ? 'Cập nhật' : 'Thêm mới'} nhân viên ${staffData.name} thành công!'
                            : provider.errorMessage ?? 'Thao tác thất bại!',
                      ),
                    ),
                  );
                },
                child: Text(isEditing ? 'Lưu' : 'Thêm'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Phương thức xác nhận Xóa
  void _confirmDelete(BuildContext context, Staff staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Xóa Nhân viên'),
        content: Text('Bạn có chắc chắn muốn xóa nhân viên "${staff.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<StaffProvider>().deleteStaff(staff.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success 
                        ? 'Đã xóa nhân viên: ${staff.name}' 
                        : context.read<StaffProvider>().errorMessage ?? 'Xóa nhân viên thất bại!',
                  ),
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Helper để hiển thị Vị trí/Chuyên môn rõ ràng hơn
  String _getDisplayPosition(String position) {
    switch (position) {
      case 'mechanic': return 'Kỹ thuật viên';
      case 'manager': return 'Quản lý';
      case 'admin': return 'Quản trị viên';
      default: return position;
    }
  }

  // Helper để hiển thị Chuyên môn rõ ràng hơn
  String _getDisplaySpecialization(String specialization) {
    switch (specialization) {
      case 'engine': return 'Máy (Engine)';
      case 'transmission': return 'Hộp số';
      case 'electrical': return 'Điện/Điện tử';
      case 'bodywork': return 'Đồng sơn';
      case 'management': return 'Quản lý chung';
      default: return 'Khác/Chung';
    }
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffProvider>();
    final staffList = provider.staff.where((staff) {
      final q = _searchQuery.toLowerCase();
      return staff.name.toLowerCase().contains(q) ||
             staff.email.toLowerCase().contains(q) ||
             staff.phone.toLowerCase().contains(q) ||
             staff.position.toLowerCase().contains(q) ||
             staff.specialization.toLowerCase().contains(q);
    }).toList();

    return AnimatedScaffold(
      title: 'QL Nhân viên',
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: provider.loadStaff,
        ),
        IconButton(
          icon: const Icon(Icons.person_add_alt),
          onPressed: () => _showAddEditDialog(context),
        ),
      ],
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên, email, SĐT, vị trí, chuyên môn...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: staffList.isEmpty
                      ? const Center(child: Text('Không tìm thấy nhân viên nào.'))
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
                              itemCount: staffList.length,
                              itemBuilder: (ctx, index) {
                                final staff = staffList[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      // TODO: Điều hướng đến màn hình chi tiết Nhân viên
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
                                            backgroundColor: staff.isActive ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
                                            backgroundImage: staff.photoUrl != null && staff.photoUrl!.isNotEmpty
                                                ? NetworkImage(staff.photoUrl!)
                                                : null,
                                            child: (staff.photoUrl == null || staff.photoUrl!.isEmpty)
                                                ? Text(staff.name.isNotEmpty ? staff.name.substring(0, 1).toUpperCase() : '?',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22))
                                                : null,
                                          ),
                                          const SizedBox(width: 18),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(staff.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 4),
                                                Text(_getDisplayPosition(staff.position), style: Theme.of(context).textTheme.bodyMedium),
                                                Text('Chuyên môn: ${_getDisplaySpecialization(staff.specialization)}', style: Theme.of(context).textTheme.bodyMedium),
                                                Text('SĐT: ${staff.phone}', style: Theme.of(context).textTheme.bodySmall),
                                                Text(staff.isActive ? 'Trạng thái: Đang hoạt động' : 'Trạng thái: Đã nghỉ',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: staff.isActive ? Colors.green : Colors.red,
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
                                                onPressed: () => _showAddEditDialog(context, staff),
                                              ),
                                              const SizedBox(height: 4),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                                tooltip: 'Xóa',
                                                onPressed: () => _confirmDelete(context, staff),
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
                ),
              ],
            ),
    );
  }
}