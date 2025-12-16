import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expenses_provider.dart';
import '../models/expense.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ExpensesProvider>(context, listen: false).fetchExpenses());
  }

  void _showAddExpenseDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final noteController = TextEditingController();
    File? pickedImage;
    final picker = ImagePicker();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thêm chi tiêu'),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Đóng',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                    if (picked != null) {
                      setState(() => pickedImage = File(picked.path));
                    }
                  },
                  child: pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(pickedImage!, width: 100, height: 100, fit: BoxFit.cover),
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                        ),
                ),
                const SizedBox(height: 12),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tên khoản chi')),
                TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Số tiền'), keyboardType: TextInputType.number),
                TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Loại chi tiêu')),
                TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Ghi chú')),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Lưu'),
              onPressed: () async {
                final provider = Provider.of<ExpensesProvider>(context, listen: false);
                final expenseId = DateTime.now().millisecondsSinceEpoch.toString();
                String? imageUrl;
                if (pickedImage != null) {
                  imageUrl = await provider.uploadExpenseImage(pickedImage!, expenseId);
                }
                final expense = Expense(
                  id: expenseId,
                  title: titleController.text,
                  amount: double.tryParse(amountController.text) ?? 0,
                  date: DateTime.now(),
                  category: categoryController.text,
                  note: noteController.text,
                  imageUrl: imageUrl,
                );
                await provider.addExpense(expense);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Báo cáo chi tiêu'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddExpenseDialog(context),
                tooltip: 'Thêm chi tiêu',
              ),
            ],
          ),
          body: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: const Text('Tổng chi tiêu'),
                  trailing: Text(NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(provider.totalExpense)),
                ),
              ),
              SizedBox(
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: provider.expenseByCategory.values.isEmpty ? 1 : provider.expenseByCategory.values.reduce((a, b) => a > b ? a : b) * 1.2,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final keys = provider.expenseByCategory.keys.toList();
                              if (value.toInt() < 0 || value.toInt() >= keys.length) return const SizedBox();
                              return Text(keys[value.toInt()], style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      barGroups: List.generate(
                        provider.expenseByCategory.length,
                        (i) => BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: provider.expenseByCategory.values.elementAt(i),
                              color: Colors.redAccent,
                              width: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.expenses.length,
                  itemBuilder: (ctx, i) {
                    final e = provider.expenses[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: e.imageUrl != null && e.imageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  e.imageUrl!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, url, error) => const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                                ),
                              )
                            : const Icon(Icons.receipt_long, size: 36, color: Colors.grey),
                        title: Text(e.title),
                        subtitle: Text('${e.category} • ${DateFormat('dd/MM/yyyy').format(e.date)}${e.note != null && e.note!.isNotEmpty ? '\n${e.note}' : ''}'),
                        trailing: Text(NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(e.amount)),
                        onLongPress: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xóa chi tiêu?'),
                              content: const Text('Bạn có chắc muốn xóa khoản chi này?'),
                              actions: [
                                TextButton(child: const Text('Hủy'), onPressed: () => Navigator.of(ctx).pop(false)),
                                ElevatedButton(child: const Text('Xóa'), onPressed: () => Navigator.of(ctx).pop(true)),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await provider.deleteExpense(e.id);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
