import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/services/vehicle_firestore.dart';
import 'package:flutter_application/services/customer_firestore.dart';
import 'package:uuid/uuid.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;
  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();

  final firestore = VehicleFirestore();
  final customerFirestore = CustomerFirestore();
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    if (v != null) {
      _brandCtrl.text = v.brand;
      _modelCtrl.text = v.model;
      _yearCtrl.text = v.year.toString();
      _plateCtrl.text = v.plateNumber;
      _colorCtrl.text = v.color ?? '';
      _ownerPhoneCtrl.text = v.ownerPhoneNumber ?? '';
    }
  }

  // LOGIC GIỮ NGUYÊN
  Future<void> _save() async {
    final id = widget.vehicle?.id ?? uuid.v4();
    String? customerId = widget.vehicle?.customerId;
    if (_ownerPhoneCtrl.text.isNotEmpty && customerId == null) {
      final customer = await customerFirestore.getCustomerByPhoneNumber(
        _ownerPhoneCtrl.text,
      );
      if (customer != null) {
        customerId = customer.id;
      }
    }
    final vehicle = Vehicle(
      id: id,
      brand: _brandCtrl.text,
      model: _modelCtrl.text,
      year: int.tryParse(_yearCtrl.text) ?? 0,
      plateNumber: _plateCtrl.text,
      color: _colorCtrl.text.isEmpty ? null : _colorCtrl.text,
      ownerPhoneNumber: _ownerPhoneCtrl.text.isEmpty
          ? null
          : _ownerPhoneCtrl.text,
      customerId: customerId,
    );

    if (widget.vehicle == null) {
      await firestore.addVehicle(vehicle);
    } else {
      await firestore.updateVehicle(vehicle);
    }

    if (!mounted) return;
    context.pop();
  }

  // LOGIC GIỮ NGUYÊN
  Future<void> _saveAndContinue() async {
    final id = widget.vehicle?.id ?? uuid.v4();
    String? customerId = widget.vehicle?.customerId;
    if (_ownerPhoneCtrl.text.isNotEmpty && customerId == null) {
      final customer = await customerFirestore.getCustomerByPhoneNumber(
        _ownerPhoneCtrl.text,
      );
      if (customer != null) {
        customerId = customer.id;
      }
    }
    final vehicle = Vehicle(
      id: id,
      brand: _brandCtrl.text,
      model: _modelCtrl.text,
      year: int.tryParse(_yearCtrl.text) ?? 0,
      plateNumber: _plateCtrl.text,
      color: _colorCtrl.text.isEmpty ? null : _colorCtrl.text,
      ownerPhoneNumber: _ownerPhoneCtrl.text.isEmpty
          ? null
          : _ownerPhoneCtrl.text,
      customerId: customerId,
    );

    if (widget.vehicle == null) {
      await firestore.addVehicle(vehicle);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu xe thành công')));
      _brandCtrl.clear();
      _modelCtrl.clear();
      _yearCtrl.clear();
      _plateCtrl.clear();
      _colorCtrl.clear();
      _ownerPhoneCtrl.clear();
    } else {
      await firestore.updateVehicle(vehicle);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
    }
  }

  // Helper để tạo style cho TextField đẹp hơn
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vehicle != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa phương tiện' : 'Thêm phương tiện'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Thông tin xe'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _brandCtrl,
                      decoration: _buildInputDecoration('Hãng xe', Icons.branding_watermark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _modelCtrl,
                      decoration: _buildInputDecoration('Model', Icons.model_training),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _plateCtrl,
                      decoration: _buildInputDecoration('Biển số', Icons.confirmation_number),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _yearCtrl,
                      decoration: _buildInputDecoration('Năm SX', Icons.calendar_today),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _colorCtrl,
                decoration: _buildInputDecoration('Màu sắc', Icons.palette),
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Thông tin chủ sở hữu'),
              const SizedBox(height: 16),
              
              TextField(
                controller: _ownerPhoneCtrl,
                decoration: _buildInputDecoration('Số điện thoại', Icons.phone),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 32),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Lưu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Lưu & Thêm tiếp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}