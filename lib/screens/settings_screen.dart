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
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    await settings.setBaseUrl(_controller.text.trim());
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu cấu hình')));
  }

  Future<void> _testApi() async {
    setState(() => _saving = true);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    try {
      final spots = await settings.api.fetchParkingSpots();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kết nối OK — ${spots.length} bãi xe trả về')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Kết nối thất bại: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'API Base URL',
                style: TextStyle(fontWeight: FontWeight.bold),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
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
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: _saving ? null : _testApi,
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
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Tài khoản'),
                subtitle: const Text('Quản lý thông tin người dùng'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Thanh toán'),
                subtitle: const Text(
                  'Cấu hình cổng thanh toán (Stripe, VNPay...)',
                ),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Giới thiệu'),
                subtitle: const Text('Phiên bản & thông tin ứng dụng'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
