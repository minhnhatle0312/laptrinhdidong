// screens/management/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/repair_tickets_provider.dart';
import '../../widgets/animated_scaffold.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    // Đảm bảo tải dữ liệu cần thiết
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepairTicketsProvider>().loadAllTickets();
      // Phụ tùng cũng cần được tải để tính COGS, đã được tải trong main.dart
    });
  }
  
  // Widget hiển thị thẻ thống kê tài chính
  Widget _buildReportStatCard(
    BuildContext context,
    String label,
    double value,
    IconData icon,
    Color color,
    bool isPercent,
  ) {
    final displayValue = isPercent ? '${value.toStringAsFixed(1)}%' : '${value.toStringAsFixed(0)} đ';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2), 
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 12),
            Text(
              displayValue,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepairTicketsProvider>();
    final report = provider.getReportOverview();

    return AnimatedScaffold(
      title: 'Báo cáo Tài chính',
      automaticallyImplyLeading: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: provider.loadAllTickets,
        ),
      ],
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadAllTickets,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phân tích Tổng quan (Phiếu đã Hoàn thành)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildReportStatCard(
                          context,
                          'Tổng Doanh thu',
                          report['totalRevenue']!,
                          Icons.trending_up,
                          Colors.green.shade600,
                          false,
                        ),
                        _buildReportStatCard(
                          context,
                          'Tổng Chi phí (COGS)',
                          report['totalCogs']!,
                          Icons.shopping_cart,
                          Colors.red.shade600,
                          false,
                        ),
                        _buildReportStatCard(
                          context,
                          'Lợi nhuận Ròng',
                          report['netProfit']!,
                          Icons.attach_money,
                          Colors.indigo,
                          false,
                        ),
                        _buildReportStatCard(
                          context,
                          'Tỷ lệ Lợi nhuận',
                          report['profitMargin']!,
                          Icons.percent,
                          Colors.purple,
                          true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    Text(
                      'Chi tiết Phiếu Bảo dưỡng',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    // TODO: Thêm danh sách chi tiết các phiếu để xem lợi nhuận từng phiếu
                    Center(child: Text('Danh sách chi tiết phiếu sẽ được thêm tại đây.')),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}