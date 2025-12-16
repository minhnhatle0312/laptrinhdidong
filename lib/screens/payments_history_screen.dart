// screens/payments_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/payments_provider.dart';

class PaymentsHistoryScreen extends StatefulWidget {
  const PaymentsHistoryScreen({super.key});

  @override
  State<PaymentsHistoryScreen> createState() => _PaymentsHistoryScreenState();
}

class _PaymentsHistoryScreenState extends State<PaymentsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Đảm bảo tải dữ liệu khi màn hình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentsProvider>().loadPayments();
    });
  }

  // Helper: Lấy màu sắc dựa trên phương thức thanh toán
  Color _getMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return Colors.blue;
      case 'cash':
        return Colors.green.shade700;
      case 'transfer':
      case 'momo':
      case 'zalopay':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PaymentsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử thanh toán'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadPayments,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.payments.isEmpty
              ? const Center(child: Text('Chưa có giao dịch'))
              : ListView.builder(
                  itemCount: provider.payments.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final p = provider.payments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: Icon(
                          Icons.credit_card,
                          color: _getMethodColor(p.method),
                        ),
                        title: Text(
                          'Thanh toán #${p.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phiếu bảo dưỡng: ${p.ticketId}'),
                            Text('Phương thức: ${p.method}'),
                            Text(
                              'Trạng thái: ${p.status}',
                              style: TextStyle(color: p.status == 'success' ? Colors.green : Colors.red),
                            ),
                          ],
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${p.amount.toStringAsFixed(0)} đ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            Text(
                              '${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          // TODO: Điều hướng đến chi tiết thanh toán
                        },
                        hoverColor: Colors.deepPurple.withOpacity(0.08),
                        splashColor: Colors.deepPurple.withOpacity(0.15),
                      ),
                    );
                  },
                ),
    );
  }
}