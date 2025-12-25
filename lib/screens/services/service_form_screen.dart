import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/service.dart';
import 'package:flutter_application/models/position.dart';
import '../../services/service_firestore.dart';
import '../../services/position_firestore.dart';
import 'package:uuid/uuid.dart';

class ServiceFormScreen extends StatefulWidget {
  final Service? service;

  const ServiceFormScreen({super.key, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // Selected position
  Position? _selectedPosition;

  // Loading
  bool _isLoadingPositions = true;
  List<Position> _positions = [];

  // Services
  final _serviceFirestore = ServiceFirestore();
  final _positionFirestore = PositionFirestore();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadPositions();

    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description ?? '';
      _priceController.text = widget.service!.price.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadPositions() async {
    try {
      final positions = await _positionFirestore.getAllPositions();
      setState(() {
        _positions = positions;
        _isLoadingPositions = false;
        if (widget.service != null) {
          _selectedPosition = positions.firstWhere(
            (p) => p.id == widget.service!.positionId,
            orElse: () => positions.first,
          );
        }
      });
    } catch (e) {
      setState(() => _isLoadingPositions = false);
    }
  }

  Future<void> _save() async {
    // Validate Logic giữ nguyên
    if (_nameController.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập tên dịch vụ', isError: true);
      return;
    }

    if (_selectedPosition == null) {
      _showSnack('Vui lòng chọn vị trí phụ trách', isError: true);
      return;
    }

    final price = double.tryParse(_priceController.text.replaceAll(',', ''));
    if (price == null || price <= 0) {
      _showSnack('Vui lòng nhập giá hợp lệ', isError: true);
      return;
    }

    String id = widget.service?.id ?? _uuid.v4();

    final service = Service(
      id: id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      price: price,
      positionId: _selectedPosition!.id,
      positionName: _selectedPosition!.name,
    );

    try {
      if (widget.service == null) {
        await _serviceFirestore.addService(service);
      } else {
        await _serviceFirestore.updateService(service);
      }

      if (!mounted) return;
      _showSnack(widget.service == null ? 'Đã thêm dịch vụ' : 'Đã cập nhật dịch vụ');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Lỗi: ${e.toString()}', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.service != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa dịch vụ' : 'Thêm dịch vụ'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoadingPositions
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Thông tin cơ bản'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Tên dịch vụ *', Icons.build_circle_outlined),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _priceController,
                      decoration: _buildInputDecoration('Đơn giá *', Icons.attach_money, suffix: 'VND'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: _buildInputDecoration('Mô tả chi tiết', Icons.description_outlined).copyWith(
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader('Cấu hình nhân sự'),
                    const SizedBox(height: 8),
                    const Text(
                      'Chọn vị trí chuyên môn phụ trách dịch vụ này.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    if (_positions.isEmpty)
                      _buildEmptyPositionWarning()
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonFormField<Position>(
                          value: _selectedPosition,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          hint: const Text('Chọn vị trí'),
                          isExpanded: true,
                          items: _positions.map((position) {
                            return DropdownMenuItem(
                              value: position,
                              child: Text(
                                position.name,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            );
                          }).toList(),
                          onChanged: (position) => setState(() => _selectedPosition = position),
                        ),
                      ),

                    if (_selectedPosition != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Dịch vụ này sẽ được gán cho nhân viên thuộc nhóm: "${_selectedPosition!.name}"',
                                style: TextStyle(fontSize: 13, color: Colors.green.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: const Text('Lưu Dịch Vụ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildEmptyPositionWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chưa có vị trí nào. Vui lòng tạo vị trí trước khi thêm dịch vụ!',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}