import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transactions_provider.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProv = Provider.of<TransactionsProvider>(context);
    final txs = txProv.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Giao dịch')),
      body: txs.isEmpty
          ? const Center(child: Text('Chưa có giao dịch'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: txs.length,
              itemBuilder: (context, index) {
                final t = txs[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(t.id),
                    subtitle: Text('${t.amount} VND — ${t.status}'),
                    trailing: Text(
                      '${t.date.day}/${t.date.month}/${t.date.year}',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
