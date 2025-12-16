// screens/management/staff_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/animated_scaffold.dart';
import '../../providers/staff_provider.dart';
import '../../models/Staff.dart';

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
    
    // Khởi tạo giá trị ban đầu cho Dropdown
    String currentPosition = existingStaff?.position ?? positions.first;
    String currentSpecialization = existingStaff?.specialization ?? specializations.first;
    bool isActive = existingStaff?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Sửa thông tin Nhân viên' : 'Thêm Nhân viên mới'),
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
                      value: currentPosition,
                      decoration: const InputDecoration(labelText: 'Vị trí'),
                      items: positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => currentPosition = v!),
                    ),
                    const SizedBox(height: 12),
                    // Dropdown Chuyên môn
                    DropdownButtonFormField<String>(
                      value: currentSpecialization,
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

                  final Staff staffData = Staff(
                    id: isEditing ? existingStaff!.id : '', // ID rỗng, Provider sẽ xử lý
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    position: currentPosition,
                    specialization: currentSpecialization,
                    isActive: isActive,
                    joinedAt: existingStaff?.joinedAt ?? DateTime.now(),
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
          : provider.staff.isEmpty
              ? const Center(child: Text('Chưa có nhân viên nào trong hệ thống.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.staff.length,
                  itemBuilder: (ctx, index) {
                    final staff = provider.staff[index];
                    
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: staff.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          foregroundColor: staff.isActive ? Colors.green : Colors.red,
                          child: staff.photoUrl != null
                              ? Image.network(staff.photoUrl!) // Nếu có ảnh đại diện
                              : Text(staff.name.substring(0, 1)),
                        ),
                        title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getDisplayPosition(staff.position),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text('Chuyên môn: ${_getDisplaySpecialization(staff.specialization)}'),
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
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showAddEditDialog(context, staff);
                            } else if (value == 'delete') {
                              _confirmDelete(context, staff);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Sửa'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Xóa', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // TODO: Điều hướng đến màn hình chi tiết Nhân viên
                        },
                      ),
                    );
                  },
                ),
    );
  }
}