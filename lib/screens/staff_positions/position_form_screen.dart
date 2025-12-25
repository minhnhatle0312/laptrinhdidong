// File: lib/screens/position/position_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/position.dart';
import '../../services/position_firestore.dart';
import 'package:uuid/uuid.dart';

class PositionFormScreen extends StatefulWidget {
  final Position? position;

  const PositionFormScreen({super.key, this.position});

  @override
  State<PositionFormScreen> createState() => _PositionFormScreenState();
}

class _PositionFormScreenState extends State<PositionFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();

  final _firestore = PositionFirestore();
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.position != null) {
      _nameController.text = widget.position!.name;
      _descriptionController.text = widget.position!.description ?? '';
      _salaryController.text = widget.position!.baseSalary?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên vị trí'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String id = widget.position?.id ?? _uuid.v4();
    double? salary;
    if (_salaryController.text.trim().isNotEmpty) {
      salary = double.tryParse(_salaryController.text);
      if (salary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lương không hợp lệ'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final position = Position(
      id: id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      baseSalary: salary,
    );

    try {
      if (widget.position == null) {
        await _firestore.addPosition(position);
      } else {
        await _firestore.updatePosition(position);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(widget.position == null
                  ? 'Đã thêm vị trí mới'
                  : 'Đã cập nhật vị trí'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {String? suffix}) {
    return InputDecoration(
      labelText: label,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, size: 22, color: Colors.grey[600]),
      suffixText: suffix,
      suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
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

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.position != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa vị trí' : 'Thêm vị trí'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin chi tiết',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              
              TextField(
                controller: _nameController,
                decoration: _buildInputDecoration('Tên vị trí *', Icons.work_outline),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _salaryController,
                decoration: _buildInputDecoration('Lương cơ bản', Icons.attach_money, suffix: 'VNĐ'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                decoration: _buildInputDecoration('Mô tả công việc', Icons.description_outlined).copyWith(
                  alignLabelWithHint: true, // Để label nằm trên cùng khi multiline
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.4),
                  ),
                  child: Text(
                    isEdit ? 'Cập nhật' : 'Lưu vị trí',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}