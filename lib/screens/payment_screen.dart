import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // THÊM IMPORT

class PaymentScreen extends StatefulWidget {
  final double amount;

  const PaymentScreen({super.key, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'card'; 
  bool _processing = false;

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 1)); // Giả lập thanh toán
    if (!mounted) return;
    
    // SỬA: Dùng GoRouter context.pop để trả về kết quả thành công
    context.pop({
      'success': true,
      'transactionId': 'tx_${DateTime.now().millisecondsSinceEpoch}',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Số tiền: ${widget.amount} VND',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Phương thức thanh toán:'),
            DropdownButton<String>(
              value: _method,
              items: const [
                DropdownMenuItem(value: 'card', child: Text('Thẻ (Card)')),
                DropdownMenuItem(value: 'online', child: Text('Online (VNPay/Momo)')),
              ],
              onChanged: (v) => setState(() => _method = v ?? 'card'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing ? null : _pay,
                child: _processing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Xác nhận Thanh toán'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                // Trả về false khi Hủy giao dịch
                onPressed: _processing ? null : () => context.pop({'success': false}), 
                child: const Text('Hủy'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}