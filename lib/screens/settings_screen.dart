import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set initial value once dependencies are available
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _controller.text = settings.baseUrl;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      settings.setBaseUrl(_controller.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cấu hình API!')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _testApi() async {
    setState(() => _saving = true);
    try {
      // TODO: Thực hiện kiểm tra API thực tế ở đây
      await Future.delayed(const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kết nối API thành công!')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API Base URL',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'https://api.example.com',
                    ),
                    keyboardType: TextInputType.url,
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Vui lòng nhập API base URL';
                      final uri = Uri.tryParse(s);
                      if (uri == null || (!uri.hasScheme && !s.startsWith('http'))) {
                        return 'URL không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Lưu'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _saving ? null : _testApi,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Kiểm tra API'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: Colors.blueGrey.shade50,
                    title: const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Quản lý thông tin người dùng'),
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: Colors.blueGrey.shade50,
                    title: const Text('Thanh toán', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Cấu hình cổng thanh toán (Stripe, VNPay...)'),
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: Colors.blueGrey.shade50,
                    title: const Text('Giới thiệu', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Phiên bản & thông tin ứng dụng'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
