// File: lib/screens/staff/staff_form_ui.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/staff.dart';
import '../../models/position.dart';
import 'staff_form_controller.dart';

class StaffFormScreen extends StatefulWidget {
  final Staff? staff;
  const StaffFormScreen({super.key, this.staff});

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  late StaffFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StaffFormController(widget.staff);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng ListenableBuilder để lắng nghe thay đổi từ Controller
    // Khi controller gọi notifyListeners(), builder này sẽ chạy lại
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final isEdit = widget.staff != null;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(isEdit ? 'Sửa nhân viên' : 'Thêm nhân viên'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Thông tin cá nhân'),
                        const SizedBox(height: 16),
                        
                        // Tên nhân viên
                        TextField(
                          controller: _controller.nameController,
                          decoration: _buildInputDecoration(
                            'Họ và Tên',
                            Icons.person_outline,
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        
                        const SizedBox(height: 24),
                        _buildSectionTitle('Công việc & Lương'),
                        const SizedBox(height: 16),

                        // Chọn vị trí (Dropdown)
                        DropdownButtonFormField<Position>(
                          value: _controller.selectedPosition,
                          decoration: _buildInputDecoration(
                            'Vị trí công việc',
                            Icons.work_outline,
                          ),
                          hint: const Text('Chọn vị trí'),
                          isExpanded: true,
                          items: _controller.positions.map((position) {
                            return DropdownMenuItem(
                              value: position,
                              child: Text(
                                position.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: _controller.onPositionChanged,
                        ),
                        
                        const SizedBox(height: 16),

                        // Nhập lương
                        TextField(
                          controller: _controller.salaryController,
                          decoration: _buildInputDecoration(
                            'Mức lương',
                            Icons.attach_money,
                            suffix: 'VNĐ',
                          ),
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 40),

                        // Buttons Area
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final success = await _controller.save(context: context);
                                  if (success && context.mounted) {
                                    context.pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Lưu',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            if (!isEdit) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await _controller.save(context: context, continueAdding: true);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    side: const BorderSide(color: Colors.blue),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Lưu & Thêm tiếp',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {String? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
      suffixText: suffix,
      suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}