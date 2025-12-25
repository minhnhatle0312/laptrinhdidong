// File: lib/screens/customer/customer_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/models/customer.dart';
import 'package:flutter_application/screens/customer/customer_form_controller.dart';
import 'package:flutter_application/screens/customer/customer_form_ui.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;
  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  late CustomerFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomerFormController(customer: widget.customer);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền sáng
      appBar: AppBar(
        title: Text(
          _controller.isEdit ? 'Sửa hồ sơ khách hàng' : 'Thêm khách hàng mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return CustomerFormUI(controller: _controller);
        },
      ),
    );
  }
}