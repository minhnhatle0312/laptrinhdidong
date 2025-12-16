// screens/transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transactions_provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  // Helper để hiển thị màu sắc trạng thái
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hoàn tất':
      case 'completed':
        return Colors.green;
      case 'thất bại':
      case 'failed':
        return Colors.red;
      case 'đang chờ':
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final txProv = Provider.of<TransactionsProvider>(context);
    final txs = txProv.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử Giao dịch')),
      body: txs.isEmpty
          ? const Center(child: Text('Chưa có giao dịch'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: txs.length,
              itemBuilder: (context, index) {
                final t = txs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: ListTile(
                    leading: Icon(
                      Icons.receipt_long,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      'Mã giao dịch: ${t.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phương thức: ${t.method}', style: const TextStyle(fontSize: 12)),
                        Text(
                          'Trạng thái: ${t.status}',
                          style: TextStyle(
                            color: _getStatusColor(t.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${t.amount.toStringAsFixed(0)} đ',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                        Text(
                          '${t.date.day}/${t.date.month}/${t.date.year}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () {
                      // TODO: Điều hướng đến chi tiết giao dịch
                    },
                  ),
                );
              },
            ),
    );
  }
}