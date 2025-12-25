// File: lib/screens/customer/customer_form_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/customer/customer_form_controller.dart';

class CustomerFormUI extends StatelessWidget {
  final CustomerFormController controller;

  const CustomerFormUI({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Thông tin cá nhân', Icons.person_outline),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                _buildTextField(
                  controller.nameCtrl,
                  'Họ và tên *',
                  Icons.account_circle_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller.phoneCtrl,
                  'Số điện thoại *',
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller.emailCtrl,
                  'Email',
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller.addressCtrl,
                  'Địa chỉ',
                  Icons.location_on_outlined,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Thông tin phương tiện', Icons.directions_car_outlined),
          const SizedBox(height: 16),
          
          Container(
            decoration: _cardDecoration(),
            child: Column(
              children: [
                // Toggle Switch
                SwitchListTile(
                  title: const Text(
                    'Thêm xe ngay',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Tạo kèm hồ sơ xe cho khách hàng này'),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: controller.addVehicle ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      color: controller.addVehicle ? Colors.blue : Colors.grey,
                    ),
                  ),
                  value: controller.addVehicle,
                  onChanged: controller.toggleAddVehicle,
                  activeColor: Colors.blue,
                ),
                
                // Animated Form Section
                AnimatedCrossFade(
                  firstChild: Container(),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller.brandCtrl, 'Hãng xe', Icons.branding_watermark_outlined
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller.modelCtrl, 'Model', Icons.model_training
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller.plateNumberCtrl, 'Biển số', Icons.featured_video_outlined
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller.yearCtrl, 'Năm SX', Icons.calendar_today_outlined,
                                keyboardType: TextInputType.number
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller.colorCtrl, 'Màu sắc', Icons.color_lens_outlined
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: controller.addVehicle
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleSave(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('Lưu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleSaveAndContinue(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Lưu & Thêm tiếp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {TextInputType? keyboardType}
  ) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: Colors.grey.shade100),
    );
  }

  // Logic handlers (Giữ nguyên)
  Future<void> _handleSave(BuildContext context) async {
    await controller.save();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSaveAndContinue(BuildContext context) async {
    await controller.saveAndContinue();
    if (context.mounted) {
      final message = controller.isEdit ? 'Đã cập nhật' : 'Đã lưu thành công';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}