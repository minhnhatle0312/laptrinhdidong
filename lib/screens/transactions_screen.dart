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
      appBar: AppBar(
        title: const Text('Giao dịch'),
      ),
      body: txs.isEmpty
          ? const Center(child: Text('Không có giao dịch nào'))
          : ListView.builder(
              itemCount: txs.length,
              itemBuilder: (context, index) {
                final transaction = txs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    title: Text('Giao dịch - ${transaction.method}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${transaction.amount} VNĐ'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                    onTap: () {},
                    hoverColor: Colors.teal.withOpacity(0.08),
                    splashColor: Colors.teal.withOpacity(0.15),
                  ),
                );
              },
            ),
    );
  }
}